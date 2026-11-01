import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:garage_card/core/services/image_upload_service.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/subscription_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/garage_profile_state.dart';

class GarageProfileViewModel extends Notifier<GarageProfileState> {
  @override
  GarageProfileState build() {
    Future.microtask(_loadProfile);
    return const GarageProfileState(isLoading: true);
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = ref.read(authViewModelProvider).userProfile;
      final repo = ref.read(garageRepositoryProvider);

      GarageModel? garage;
      if (user?.garageId != null && user!.garageId!.isNotEmpty) {
        garage = await repo.getGarageDetails(user.garageId!);
      } else if (user != null) {
        garage = await repo.getGarageByOwnerUid(user.uid);
      }

      final sub = SubscriptionModel(
        id: 'sub_1',
        garageId: garage?.id ?? 'sub_new',
        planId: 'pro',
        status: 'active',
        validUntil: DateTime.now().add(const Duration(days: 300)),
        createdAt: DateTime.now().subtract(const Duration(days: 65)),
      );

      state = state.copyWith(
        isLoading: false,
        garage: garage,
        subscription: sub,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String taxNumber,
    required String currencyCode,
    required String openHours,
    List<Map<String, dynamic>>? dailyWorkingHours,
    String? googleAddress,
    String? googleMapsUrl,
    double? latitude,
    double? longitude,
    bool? isDoorstepRepairAvailable,
    bool? isRoadsideAssistanceAvailable,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final user = ref.read(authViewModelProvider).userProfile;
      final current = state.garage;
      final garageId =
          current?.id ??
          (user != null && user.uid.isNotEmpty ? 'garage_${user.uid}' : '');

      final updated = GarageModel(
        id: garageId,
        name: name,
        logoUrl: current?.logoUrl,
        address: address,
        googleAddress: googleAddress ?? current?.googleAddress,
        googleMapsUrl: googleMapsUrl ?? current?.googleMapsUrl,
        phone: phone,
        email: email,
        currencyCode: currencyCode,
        latitude: latitude ?? current?.latitude ?? 9.9674,
        longitude: longitude ?? current?.longitude ?? 76.2891,
        city: current?.city ?? 'Kochi',
        rating: current?.rating ?? 5.0,
        openHours: openHours,
        dailyWorkingHours: dailyWorkingHours ?? current?.dailyWorkingHours,
        isVerified: true,
        ownerUid: current?.ownerUid ?? user?.uid ?? 'owner_unknown',
        taxNumber: taxNumber,
        servicesOffered:
            current?.servicesOffered ??
            const [
              'Periodic Maintenance',
              'Brake System Overhaul',
              'Engine Diagnostic & Tuning',
            ],
        createdAt: current?.createdAt ?? DateTime.now(),
        isDoorstepRepairAvailable:
            isDoorstepRepairAvailable ??
            current?.isDoorstepRepairAvailable ??
            false,
        isRoadsideAssistanceAvailable:
            isRoadsideAssistanceAvailable ??
            current?.isRoadsideAssistanceAvailable ??
            false,
      );

      await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
      if (user != null && (user.garageId == null || user.garageId!.isEmpty)) {
        await ref.read(authViewModelProvider.notifier).updateGarageId(garageId);
      }
      state = state.copyWith(isSaving: false, garage: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> setDoorstepRepair(bool value) async {
    final current = state.garage;
    if (current == null) return;
    final updated = current.copyWith(isDoorstepRepairAvailable: value);
    state = state.copyWith(garage: updated);
    await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
  }

  Future<void> setRoadsideAssistance(bool value) async {
    final current = state.garage;
    if (current == null) return;
    final updated = current.copyWith(isRoadsideAssistanceAvailable: value);
    state = state.copyWith(garage: updated);
    await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
  }

  Future<bool> uploadGarageLogo(XFile file) async {
    final current = state.garage;
    if (current == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final imageService = ref.read(imageUploadServiceProvider);
      final uploaded = await imageService.uploadImage(
        file: file,
        folder: 'garages/${current.id}/branding',
        entityId: 'logo',
        profile: ImageProfile.thumbnail,
        previousImageUrl: current.logoUrl,
      );

      final updated = current.copyWith(logoUrl: uploaded.downloadUrl);
      await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
      state = state.copyWith(isSaving: false, garage: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> uploadGarageCover(XFile file) async {
    final current = state.garage;
    if (current == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final imageService = ref.read(imageUploadServiceProvider);
      final uploaded = await imageService.uploadImage(
        file: file,
        folder: 'garages/${current.id}/branding',
        entityId: 'cover',
        profile: ImageProfile.standard,
        previousImageUrl: current.coverImageUrl,
      );

      final updated = current.copyWith(coverImageUrl: uploaded.downloadUrl);
      await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
      state = state.copyWith(isSaving: false, garage: updated);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    await _loadProfile();
  }
}

final garageProfileViewModelProvider =
    NotifierProvider<GarageProfileViewModel, GarageProfileState>(
      GarageProfileViewModel.new,
    );
