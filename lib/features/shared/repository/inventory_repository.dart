import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';

import '../models/inventory_item_model.dart';
import 'garage_repository_store.dart';

mixin InventoryRepository on GarageRepositoryStore {
  Future<List<InventoryItemModel>> getInventory(
    String garageId, {
    String? category,
    String? query,
  }) async {
    if (garageId.isEmpty) return [];
    if (FirebaseConfig.isInitialized) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('inventory')
            .get()
            .timeout(const Duration(seconds: 4));
        var items = snap.docs
            .map((d) => InventoryItemModel.fromMap(d.data(), d.id))
            .toList();
        if (category != null && category.isNotEmpty && category != 'All') {
          items = items
              .where((i) => i.category.toLowerCase() == category.toLowerCase())
              .toList();
        }
        if (query != null && query.isNotEmpty) {
          final q = query.toLowerCase();
          items = items
              .where(
                (i) =>
                    i.name.toLowerCase().contains(q) ||
                    i.sku.toLowerCase().contains(q) ||
                    i.category.toLowerCase().contains(q),
              )
              .toList();
        }
        return items;
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_INVENTORY_ERROR: $e');
        return [];
      }
    }
    return inventoryItems.where((i) {
      if (i.garageId != garageId) return false;
      if (category != null &&
          category.isNotEmpty &&
          category != 'All' &&
          i.category.toLowerCase() != category.toLowerCase()) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        return i.name.toLowerCase().contains(q) ||
            i.sku.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Future<InventoryItemModel> saveInventoryItem(
    String garageId,
    InventoryItemModel item,
  ) async {
    final id = item.id.isNotEmpty ? item.id : const Uuid().v4();
    final updated = item.copyWith(
      id: id,
      garageId: garageId,
      updatedAt: DateTime.now(),
    );
    final idx = inventoryItems.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      inventoryItems[idx] = updated;
    } else {
      inventoryItems.insert(0, updated);
    }
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('inventory')
            .doc(id)
            .set(updated.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_SAVE_INVENTORY_ERROR: $e');
      }
    }
    return updated;
  }

  Future<void> deleteInventoryItem(String garageId, String itemId) async {
    inventoryItems.removeWhere((i) => i.id == itemId);
    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('inventory')
            .doc(itemId)
            .delete();
      } catch (e) {
        debugPrint('GARAGE_REPO_DELETE_INVENTORY_ERROR: $e');
      }
    }
  }

  Future<void> adjustInventoryStock(
    String garageId,
    String itemId,
    int quantityDelta,
  ) async {
    final idx = inventoryItems.indexWhere((i) => i.id == itemId);
    if (idx >= 0) {
      final current = inventoryItems[idx];
      final newStock = (current.currentStock + quantityDelta).clamp(0, 999999);
      final updated = current.copyWith(
        currentStock: newStock,
        updatedAt: DateTime.now(),
      );
      inventoryItems[idx] = updated;
      if (FirebaseConfig.isInitialized) {
        try {
          await FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('inventory')
              .doc(itemId)
              .update({
                'currentStock': newStock,
                'updatedAt': DateTime.now().toIso8601String(),
              });
        } catch (e) {
          debugPrint('GARAGE_REPO_ADJUST_STOCK_ERROR: $e');
        }
      }
    }
  }

  Future<List<InventoryItemModel>> getLowStockItems(String garageId) async {
    final all = await getInventory(garageId);
    return all.where((i) => i.isLowStock).toList();
  }
}
