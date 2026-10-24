class LineItemModel {
  const LineItemModel({
    required this.id,
    required this.description,
    this.type = 'part',
    this.quantity = 1,
    this.unitPrice = 0.0,
  });

  final String id;
  final String description;
  final String type;
  final int quantity;
  final double unitPrice;

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'type': type,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  factory LineItemModel.fromMap(Map<String, dynamic> map) {
    return LineItemModel(
      id: map['id'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: map['type'] as String? ?? 'part',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  LineItemModel copyWith({
    String? id,
    String? description,
    String? type,
    int? quantity,
    double? unitPrice,
  }) {
    return LineItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
