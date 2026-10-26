import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/review_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/customer_garage_detail_state.dart';

class CustomerGarageDetailViewModel
    extends Notifier<CustomerGarageDetailState> {
  CustomerGarageDetailViewModel(this.garageId);

  final String garageId;
  late final GarageRepository _repo;

  @override
  CustomerGarageDetailState build() {
    _repo = ref.watch(garageRepositoryProvider);
    Future.microtask(() => loadGarage(garageId));
    return const CustomerGarageDetailState(isLoading: true);
  }

  Future<void> loadGarage(String targetGarageId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final garage = await _repo.getGarageDetails(targetGarageId);
      final services = await _repo.getGarageServices(targetGarageId);
      final reviewsResult = await _repo.getGarageReviewsPaginated(
        targetGarageId,
      );

      final authUser = ref.read(authViewModelProvider).userProfile;
      final customerId = authUser?.uid ?? 'cust_demo_1';
      final vehicles = await _repo.getVehicles(customerId: customerId);

      final defaultVehicle = vehicles.isNotEmpty ? vehicles.first : null;

      state = state.copyWith(
        garage: garage,
        services: services,
        reviews: reviewsResult.items,
        customerVehicles: vehicles,
        selectedVehicle: defaultVehicle,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load garage profile: $e',
      );
    }
  }

  void selectVehicle(VehicleModel? vehicle) {
    if (vehicle == null) {
      state = state.copyWith(clearSelectedVehicle: true);
    } else {
      state = state.copyWith(selectedVehicle: vehicle);
    }
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<bool> submitReview({
    required double rating,
    required String reviewText,
    required bool consentSharePhoto,
    required bool consentShareName,
    String? photoUrl,
    String? jobId,
  }) async {
    if (state.garage == null) return false;

    state = state.copyWith(isSubmittingReview: true, errorMessage: null);
    try {
      final authUser = ref.read(authViewModelProvider).userProfile;
      final customerId = authUser?.uid ?? 'cust_demo_1';
      final customerName = authUser?.fullName ?? 'Customer';

      final review = ReviewModel(
        id: const Uuid().v4(),
        garageId: state.garage!.id,
        customerId: customerId,
        customerName: customerName,
        customerPhotoUrl: null,
        jobId: jobId,
        rating: rating,
        reviewText: reviewText,
        reviewImageUrl: photoUrl,
        consentSharePhoto: consentSharePhoto,
        consentShareName: consentShareName,
        createdAt: DateTime.now(),
      );

      await _repo.submitGarageReview(review);

      final updatedReviews = [review, ...state.reviews];
      final newCount = (state.garage!.reviewCount) + 1;
      final newRating =
          ((state.garage!.rating * state.garage!.reviewCount) + rating) /
          newCount;

      final updatedGarage = state.garage!.copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: newCount,
      );

      state = state.copyWith(
        garage: updatedGarage,
        reviews: updatedReviews,
        isSubmittingReview: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmittingReview: false,
        errorMessage: 'Failed to submit review: $e',
      );
      return false;
    }
  }
}

final customerGarageDetailViewModelProvider =
    NotifierProvider.family<
      CustomerGarageDetailViewModel,
      CustomerGarageDetailState,
      String
    >(CustomerGarageDetailViewModel.new);
