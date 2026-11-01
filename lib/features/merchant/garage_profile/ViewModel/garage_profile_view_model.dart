import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      final effectiveUid = user != null && user.uid.isNotEmpty
          ? user.uid
          : authUid;

      GarageModel? garage;
      if (user?.garageId != null && user!.garageId!.isNotEmpty) {
        garage = await repo.getGarageDetails(user.garageId!);
      } else if (effectiveUid != null && effectiveUid.isNotEmpty) {
        garage = await repo.getGarageByOwnerUid(effectiveUid);
      }
      if (garage == null) {
        final list = await repo.getNearbyGarages(
          latitude: 9.9674,
          longitude: 76.2891,
          limit: 1,
        );
        if (list.isNotEmpty) {
          garage = list.first;
        }
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
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      final ownerUid = (current != null && current.ownerUid.isNotEmpty)
          ? current.ownerUid
          : (user != null && user.uid.isNotEmpty
                ? user.uid
                : (authUid != null && authUid.isNotEmpty
                      ? authUid
                      : 'owner_merchant'));

      final garageId = (current != null && current.id.isNotEmpty)
          ? current.id
          : (user?.garageId != null && user!.garageId!.isNotEmpty)
          ? user.garageId!
          : (ownerUid.isNotEmpty && ownerUid != 'owner_merchant'
                ? 'garage_$ownerUid'
                : 'garage_primary');

      final updated = GarageModel(
        id: garageId,
        name: name,
        logoUrl: current?.logoUrl,
        coverImageUrl: current?.coverImageUrl,
        description: current?.description ?? '',
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
        ownerUid: ownerUid,
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
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('members')
            .doc(ownerUid)
            .set({
              'uid': ownerUid,
              'role': 'owner',
              'name': name,
              'joinedAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true))
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
      if (user != null && (user.garageId == null || user.garageId!.isEmpty)) {
        try {
          await ref
              .read(authViewModelProvider.notifier)
              .updateGarageId(garageId);
        } catch (_) {}
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
    try {
      await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
    } catch (_) {}
  }

  Future<void> setRoadsideAssistance(bool value) async {
    final current = state.garage;
    if (current == null) return;
    final updated = current.copyWith(isRoadsideAssistanceAvailable: value);
    state = state.copyWith(garage: updated);
    try {
      await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
    } catch (_) {}
  }

  Future<String?> uploadGarageLogo(XFile file) async {
    final user = ref.read(authViewModelProvider).userProfile;
    final current = state.garage;
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final ownerUid = (current != null && current.ownerUid.isNotEmpty)
        ? current.ownerUid
        : (user != null && user.uid.isNotEmpty
              ? user.uid
              : (authUid != null && authUid.isNotEmpty
                    ? authUid
                    : 'owner_merchant'));
    final garageId = (current != null && current.id.isNotEmpty)
        ? current.id
        : (user?.garageId != null && user!.garageId!.isNotEmpty)
        ? user.garageId!
        : (ownerUid.isNotEmpty && ownerUid != 'owner_merchant'
              ? 'garage_$ownerUid'
              : 'garage_primary');

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final imageService = ref.read(imageUploadServiceProvider);
      final uploaded = await imageService.uploadImage(
        file: file,
        folder: 'garages/$garageId/branding',
        entityId: 'logo',
        profile: ImageProfile.thumbnail,
        previousImageUrl: current?.logoUrl,
      );

      final base =
          current ??
          GarageModel(
            id: garageId,
            name: 'Garage Workshop',
            address: '',
            phone: '',
            email: user?.email ?? '',
            currencyCode: 'INR',
            latitude: 9.9674,
            longitude: 76.2891,
            city: 'Kochi',
            openHours: 'Mon-Sat: 09:00 AM - 07:00 PM',
            ownerUid: ownerUid,
          );

      final updated = base.copyWith(logoUrl: uploaded.downloadUrl);
      state = state.copyWith(isSaving: false, garage: updated);
      try {
        await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
      } catch (_) {
        unawaited(
          ref.read(garageRepositoryProvider).updateGarageProfile(updated),
        );
      }
      return null;
    } catch (e) {
      final err = e.toString();
      state = state.copyWith(isSaving: false, errorMessage: err);
      return err;
    }
  }

  Future<String?> uploadGarageCover(XFile file) async {
    final user = ref.read(authViewModelProvider).userProfile;
    final current = state.garage;
    final authUid = FirebaseAuth.instance.currentUser?.uid;
    final ownerUid = (current != null && current.ownerUid.isNotEmpty)
        ? current.ownerUid
        : (user != null && user.uid.isNotEmpty
              ? user.uid
              : (authUid != null && authUid.isNotEmpty
                    ? authUid
                    : 'owner_merchant'));
    final garageId = (current != null && current.id.isNotEmpty)
        ? current.id
        : (user?.garageId != null && user!.garageId!.isNotEmpty)
        ? user.garageId!
        : (ownerUid.isNotEmpty && ownerUid != 'owner_merchant'
              ? 'garage_$ownerUid'
              : 'garage_primary');

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final imageService = ref.read(imageUploadServiceProvider);
      final uploaded = await imageService.uploadImage(
        file: file,
        folder: 'garages/$garageId/branding',
        entityId: 'cover',
        profile: ImageProfile.standard,
        previousImageUrl: current?.coverImageUrl,
      );

      final base =
          current ??
          GarageModel(
            id: garageId,
            name: 'Garage Workshop',
            address: '',
            phone: '',
            email: user?.email ?? '',
            currencyCode: 'INR',
            latitude: 9.9674,
            longitude: 76.2891,
            city: 'Kochi',
            openHours: 'Mon-Sat: 09:00 AM - 07:00 PM',
            ownerUid: ownerUid,
          );

      final updated = base.copyWith(coverImageUrl: uploaded.downloadUrl);
      state = state.copyWith(isSaving: false, garage: updated);
      try {
        await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
      } catch (_) {
        unawaited(
          ref.read(garageRepositoryProvider).updateGarageProfile(updated),
        );
      }
      return null;
    } catch (e) {
      final err = e.toString();
      state = state.copyWith(isSaving: false, errorMessage: err);
      return err;
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
