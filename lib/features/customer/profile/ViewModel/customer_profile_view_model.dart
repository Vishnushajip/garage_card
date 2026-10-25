import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

import '../Model/customer_profile_state.dart';

class CustomerProfileViewModel extends Notifier<CustomerProfileState> {
  @override
  CustomerProfileState build() {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.userProfile;
    return CustomerProfileState(
      userProfile: user,
      nameInput: user?.fullName ?? '',
      phoneInput: user?.phoneNumber ?? '',
    );
  }

  void setName(String name) {
    state = state.copyWith(
      nameInput: name,
      errorMessage: null,
      successMessage: null,
    );
  }

  void setPhone(String phone) {
    state = state.copyWith(
      phoneInput: phone,
      errorMessage: null,
      successMessage: null,
    );
  }

  Future<bool> saveProfile() async {
    final trimmedName = state.nameInput.trim();
    final trimmedPhone = state.phoneInput.trim();

    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your full name');
      return false;
    }
    if (trimmedPhone.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your phone number');
      return false;
    }

    state = state.copyWith(
      isSaving: true,
      errorMessage: null,
      successMessage: null,
    );
    try {
      final current = state.userProfile;
      if (current == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'User session not found',
        );
        return false;
      }

      final updated = current.copyWith(
        fullName: trimmedName,
        phoneNumber: trimmedPhone,
        updatedAt: DateTime.now(),
      );

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(current.uid)
            .set(updated.toFirestore(), SetOptions(merge: true));
      }

      ref.read(authViewModelProvider.notifier).updateUserProfile(updated);

      state = state.copyWith(
        isSaving: false,
        userProfile: updated,
        successMessage: 'Profile completed successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    setName(fullName);
    setPhone(phoneNumber);
    await saveProfile();
  }
}

final customerProfileViewModelProvider =
    NotifierProvider<CustomerProfileViewModel, CustomerProfileState>(
      CustomerProfileViewModel.new,
    );
