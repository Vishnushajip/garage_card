import 'package:garage_card/features/shared/models/estimate_model.dart';

class MerchantEstimatesState {
  const MerchantEstimatesState({
    this.estimates = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isConverting = false,
    this.errorMessage,
  });

  final List<EstimateModel> estimates;
  final bool isLoading;
  final bool isCreating;
  final bool isConverting;
  final String? errorMessage;

  MerchantEstimatesState copyWith({
    List<EstimateModel>? estimates,
    bool? isLoading,
    bool? isCreating,
    bool? isConverting,
    String? errorMessage,
  }) {
    return MerchantEstimatesState(
      estimates: estimates ?? this.estimates,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isConverting: isConverting ?? this.isConverting,
      errorMessage: errorMessage,
    );
  }
}
