class PaginatedState<T> {
  const PaginatedState({
    this.items = const [],
    this.isInitialLoading = false,
    this.isFetchingNextPage = false,
    this.isRefreshing = false,
    this.hasMore = true,
    this.cursor,
    this.errorMessage,
    this.nextPageErrorMessage,
    this.searchQuery = '',
    this.activeFilter,
  });

  final List<T> items;
  final bool isInitialLoading;
  final bool isFetchingNextPage;
  final bool isRefreshing;
  final bool hasMore;
  final Object? cursor;
  final String? errorMessage;
  final String? nextPageErrorMessage;
  final String searchQuery;
  final String? activeFilter;

  PaginatedState<T> copyWith({
    List<T>? items,
    bool? isInitialLoading,
    bool? isFetchingNextPage,
    bool? isRefreshing,
    bool? hasMore,
    Object? cursor,
    String? errorMessage,
    String? nextPageErrorMessage,
    String? searchQuery,
    String? activeFilter,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isFetchingNextPage: isFetchingNextPage ?? this.isFetchingNextPage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      errorMessage: errorMessage,
      nextPageErrorMessage: nextPageErrorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }
}
