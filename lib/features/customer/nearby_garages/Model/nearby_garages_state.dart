import 'package:garage_card/features/shared/models/garage_model.dart';

class NearbyGaragesState {
  const NearbyGaragesState({
    this.garages = const [],
    this.isLoading = false,
    this.isFetchingNextPage = false,
    this.hasMore = true,
    this.errorMessage,
    this.searchQuery = '',
    this.userLatitude = 9.9312,
    this.userLongitude = 76.2673,
    this.page = 0,
  });

  final List<GarageModel> garages;
  final bool isLoading;
  final bool isFetchingNextPage;
  final bool hasMore;
  final String? errorMessage;
  final String searchQuery;
  final double userLatitude;
  final double userLongitude;
  final int page;

  NearbyGaragesState copyWith({
    List<GarageModel>? garages,
    bool? isLoading,
    bool? isFetchingNextPage,
    bool? hasMore,
    String? errorMessage,
    String? searchQuery,
    double? userLatitude,
    double? userLongitude,
    int? page,
  }) {
    return NearbyGaragesState(
      garages: garages ?? this.garages,
      isLoading: isLoading ?? this.isLoading,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      page: page ?? this.page,
    );
  }
}
