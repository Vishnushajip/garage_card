import 'package:garage_card/features/shared/models/user_profile_model.dart';

class CustomerProfileState {
  const CustomerProfileState({
    this.userProfile,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final UserProfileModel? userProfile;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  CustomerProfileState copyWith({
    UserProfileModel? userProfile,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return CustomerProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
