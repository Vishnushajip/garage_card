import 'package:garage_card/features/shared/models/user_profile_model.dart';

class CustomerProfileState {
  const CustomerProfileState({
    this.userProfile,
    this.nameInput = '',
    this.phoneInput = '',
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final UserProfileModel? userProfile;
  final String nameInput;
  final String phoneInput;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  bool get isProfileComplete {
    final name =
        (nameInput.isNotEmpty ? nameInput : userProfile?.fullName ?? '').trim();
    final phone =
        (phoneInput.isNotEmpty ? phoneInput : userProfile?.phoneNumber ?? '')
            .trim();
    return name.isNotEmpty && phone.isNotEmpty;
  }

  double get completionPercentage {
    final name =
        (nameInput.isNotEmpty ? nameInput : userProfile?.fullName ?? '').trim();
    final phone =
        (phoneInput.isNotEmpty ? phoneInput : userProfile?.phoneNumber ?? '')
            .trim();
    var completed = 0;
    if (userProfile?.email.isNotEmpty ?? false) completed++;
    if (name.isNotEmpty) completed++;
    if (phone.isNotEmpty) completed++;
    return completed / 3.0;
  }

  CustomerProfileState copyWith({
    UserProfileModel? userProfile,
    String? nameInput,
    String? phoneInput,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) {
    return CustomerProfileState(
      userProfile: userProfile ?? this.userProfile,
      nameInput: nameInput ?? this.nameInput,
      phoneInput: phoneInput ?? this.phoneInput,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
