import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import '../Model/customer_profile_state.dart';

class CustomerProfileViewModel extends Notifier<CustomerProfileState> {
  @override
  CustomerProfileState build() {
    final authState = ref.watch(authViewModelProvider);
    return CustomerProfileState(userProfile: authState.userProfile);
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final current = state.userProfile;
      if (current != null) {
        final updated = current.copyWith(
          fullName: fullName,
          phoneNumber: phoneNumber,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(isSaving: false, userProfile: updated);
      }
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }
}

final customerProfileViewModelProvider =
    NotifierProvider<CustomerProfileViewModel, CustomerProfileState>(
  CustomerProfileViewModel.new,
);
