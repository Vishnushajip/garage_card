import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final garage = await ref
          .read(garageRepositoryProvider)
          .getGarageDetails('garage_demo_1');

      final sub = SubscriptionModel(
        id: 'sub_1',
        garageId: 'garage_demo_1',
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
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final current = state.garage;
      if (current != null) {
        final updated = current.copyWith(
          name: name,
          address: address,
          phone: phone,
          email: email,
          taxNumber: taxNumber,
          currencyCode: currencyCode,
          openHours: openHours,
        );
        await ref.read(garageRepositoryProvider).updateGarageProfile(updated);
        state = state.copyWith(isSaving: false, garage: updated);
        return true;
      }
      state = state.copyWith(isSaving: false);
      return false;
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
