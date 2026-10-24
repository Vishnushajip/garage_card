import 'package:garage_card/features/shared/models/user_profile_model.dart';

class AuthState {
  const AuthState({
    this.userProfile,
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
    this.activeExperience = 'customer',
  });

  final UserProfileModel? userProfile;
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;
  final String activeExperience;

  bool get isAuthenticated => userProfile != null;
  bool get isCustomer => activeExperience == 'customer';
  bool get isMerchant => activeExperience == 'merchant';

  AuthState copyWith({
    UserProfileModel? userProfile,
    bool clearUserProfile = false,
    bool? isLoading,
    bool? isInitialized,
    String? errorMessage,
    String? activeExperience,
  }) {
    return AuthState(
      userProfile: clearUserProfile ? null : (userProfile ?? this.userProfile),
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage,
      activeExperience: activeExperience ?? this.activeExperience,
    );
  }
}
