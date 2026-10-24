import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/errors/app_exception.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import '../Model/auth_state.dart';

class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(isLoading: false, isInitialized: true);
  }

  Future<bool> signIn({
    required String email,
    required String password,
    required String intendedRole,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final profile = UserProfileModel(
        uid: email.hashCode.abs().toString(),
        email: email,
        fullName: email.split('@').first.toUpperCase(),
        phoneNumber: '+91 98765 00000',
        role: intendedRole,
        garageId: intendedRole == 'merchant' ? 'garage_demo_1' : null,
        createdAt: DateTime.now(),
      );

      final authorizedExperience =
          profile.role == 'merchant' ? 'merchant' : 'customer';

      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        activeExperience: authorizedExperience,
      );
      return true;
    } catch (e) {
      final appEx = AppException.fromFirebase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String intendedRole,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final uid = const Uuid().v4();
      final garageId = intendedRole == 'merchant' ? 'garage_$uid' : null;

      final profile = UserProfileModel(
        uid: uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        role: intendedRole,
        garageId: garageId,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        userProfile: profile,
        activeExperience: intendedRole,
      );
      return true;
    } catch (e) {
      final appEx = AppException.fromFirebase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
      );
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final appEx = AppException.fromFirebase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
      );
      return false;
    }
  }

  void switchExperience(String targetExperience) {
    if (state.userProfile == null) return;
    if (targetExperience == 'merchant' && state.userProfile?.role != 'merchant') {
      state = state.copyWith(
        errorMessage:
            'Unauthorized: Your account does not have merchant privileges.',
      );
      return;
    }
    state = state.copyWith(activeExperience: targetExperience);
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = const AuthState(isInitialized: true);
  }
}

final authViewModelProvider =
    NotifierProvider<AuthViewModel, AuthState>(AuthViewModel.new);
