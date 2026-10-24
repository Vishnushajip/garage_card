import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/subscription_model.dart';

class GarageProfileState {
  const GarageProfileState({
    this.garage,
    this.subscription,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final GarageModel? garage;
  final SubscriptionModel? subscription;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  GarageProfileState copyWith({
    GarageModel? garage,
    SubscriptionModel? subscription,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return GarageProfileState(
      garage: garage ?? this.garage,
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
