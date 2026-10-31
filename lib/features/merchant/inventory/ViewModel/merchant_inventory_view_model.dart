import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/inventory_item_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_inventory_state.dart';

class MerchantInventoryViewModel extends Notifier<MerchantInventoryState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return 'garage_demo_1';
  }

  @override
  MerchantInventoryState build() {
    Future.microtask(loadInventory);
    return const MerchantInventoryState(isLoading: true);
  }

  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final garageId = _effectiveGarageId();
      final items = await repo.getInventory(garageId);
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> saveItem(InventoryItemModel item) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      final garageId = _effectiveGarageId();
      final saved = await repo.saveInventoryItem(garageId, item);
      final items = List<InventoryItemModel>.from(state.items);
      final idx = items.indexWhere((i) => i.id == saved.id);
      if (idx >= 0) {
        items[idx] = saved;
      } else {
        items.insert(0, saved);
      }
      state = state.copyWith(isSaving: false, items: items);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      final repo = ref.read(garageRepositoryProvider);
      final garageId = _effectiveGarageId();
      await repo.deleteInventoryItem(garageId, itemId);
      final items = state.items.where((i) => i.id != itemId).toList();
      state = state.copyWith(items: items);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> adjustStock(String itemId, int delta) async {
    try {
      final repo = ref.read(garageRepositoryProvider);
      final garageId = _effectiveGarageId();
      await repo.adjustInventoryStock(garageId, itemId, delta);
      final items = state.items.map((i) {
        if (i.id == itemId) {
          final newStock = (i.currentStock + delta).clamp(0, 999999);
          return i.copyWith(currentStock: newStock, updatedAt: DateTime.now());
        }
        return i;
      }).toList();
      state = state.copyWith(items: items);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> refresh() => loadInventory();
}

final merchantInventoryViewModelProvider =
    NotifierProvider<MerchantInventoryViewModel, MerchantInventoryState>(() {
      return MerchantInventoryViewModel();
    });

