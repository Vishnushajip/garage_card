import 'package:garage_card/features/shared/models/inventory_item_model.dart';

class MerchantInventoryState {
  const MerchantInventoryState({
    this.items = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  final List<InventoryItemModel> items;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;

  static const List<String> categories = [
    'All',
    'Fluids & Lubricants',
    'Filters',
    'Braking',
    'Electrical',
    'Engine Parts',
    'General Parts',
  ];

  int get lowStockCount => items.where((i) => i.isLowStock).length;

  double get totalValuation =>
      items.fold(0.0, (acc, item) => acc + item.totalStockValuation);

  List<InventoryItemModel> get filteredItems {
    var result = items;
    if (selectedCategory != 'All') {
      result = result
          .where(
            (i) => i.category.toLowerCase() == selectedCategory.toLowerCase(),
          )
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where(
            (i) =>
                i.name.toLowerCase().contains(q) ||
                i.sku.toLowerCase().contains(q) ||
                i.category.toLowerCase().contains(q),
          )
          .toList();
    }
    return result;
  }

  MerchantInventoryState copyWith({
    List<InventoryItemModel>? items,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return MerchantInventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
