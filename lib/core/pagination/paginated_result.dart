class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    this.lastDocument,
    required this.hasMore,
  });

  final List<T> items;
  final Object? lastDocument;
  final bool hasMore;
}
