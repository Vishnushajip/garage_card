import 'package:garage_card/core/formatting/date_formatter.dart';

class InventoryItemModel {
  const InventoryItemModel({
    required this.id,
    required this.garageId,
    required this.sku,
    required this.name,
    this.category = 'General Parts',
    this.unitCost = 0.0,
    this.sellingPrice = 0.0,
    this.currentStock = 0,
    this.minStockAlert = 5,
    this.unit = 'units',
    this.supplier,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String garageId;
  final String sku;
  final String name;
  final String category;
  final double unitCost;
  final double sellingPrice;
  final int currentStock;
  final int minStockAlert;
  final String unit;
  final String? supplier;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isLowStock => currentStock <= minStockAlert;
  double get profitMargin =>
      sellingPrice > 0 ? ((sellingPrice - unitCost) / sellingPrice) * 100 : 0.0;
  double get totalStockValuation => currentStock * unitCost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'garageId': garageId,
      'sku': sku,
      'name': name,
      'category': category,
      'unitCost': unitCost,
      'sellingPrice': sellingPrice,
      'currentStock': currentStock,
      'minStockAlert': minStockAlert,
      'unit': unit,
      'supplier': supplier,
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory InventoryItemModel.fromMap(Map<String, dynamic> map, String id) {
    return InventoryItemModel(
      id: id,
      garageId: map['garageId'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'General Parts',
      unitCost: (map['unitCost'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      currentStock: (map['currentStock'] as num?)?.toInt() ?? 0,
      minStockAlert: (map['minStockAlert'] as num?)?.toInt() ?? 5,
      unit: map['unit'] as String? ?? 'units',
      supplier: map['supplier'] as String?,
      location: map['location'] as String?,
      createdAt: DateFormatter.parse(map['createdAt']),
      updatedAt: DateFormatter.parse(map['updatedAt']),
    );
  }

  InventoryItemModel copyWith({
    String? id,
    String? garageId,
    String? sku,
    String? name,
    String? category,
    double? unitCost,
    double? sellingPrice,
    int? currentStock,
    int? minStockAlert,
    String? unit,
    String? supplier,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      category: category ?? this.category,
      unitCost: unitCost ?? this.unitCost,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      currentStock: currentStock ?? this.currentStock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      unit: unit ?? this.unit,
      supplier: supplier ?? this.supplier,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
