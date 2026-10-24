import 'package:garage_card/features/shared/models/estimate_model.dart';

class CustomerEstimatesState {
  const CustomerEstimatesState({
    this.estimates = const [],
    this.isLoading = false,
    this.isActionInProgress = false,
    this.errorMessage,
  });

  final List<EstimateModel> estimates;
  final bool isLoading;
  final bool isActionInProgress;
  final String? errorMessage;

  CustomerEstimatesState copyWith({
    List<EstimateModel>? estimates,
    bool? isLoading,
    bool? isActionInProgress,
    String? errorMessage,
  }) {
    return CustomerEstimatesState(
      estimates: estimates ?? this.estimates,
      isLoading: isLoading ?? this.isLoading,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      errorMessage: errorMessage,
    );
  }
}
