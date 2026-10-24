class InspectionItemModel {
  const InspectionItemModel({
    required this.id,
    required this.category,
    required this.itemName,
    this.condition = 'good',
    this.notes = '',
    this.photoUrl,
    this.estimatedCost = 0.0,
  });

  final String id;
  final String category;
  final String itemName;
  final String condition;
  final String notes;
  final String? photoUrl;
  final double estimatedCost;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'itemName': itemName,
      'condition': condition,
      'notes': notes,
      'photoUrl': photoUrl,
      'estimatedCost': estimatedCost,
    };
  }

  factory InspectionItemModel.fromMap(Map<String, dynamic> map) {
    return InspectionItemModel(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      itemName: map['itemName'] as String? ?? '',
      condition: map['condition'] as String? ?? 'good',
      notes: map['notes'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      estimatedCost: (map['estimatedCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class VehicleInspectionModel {
  const VehicleInspectionModel({
    required this.id,
    required this.garageId,
    required this.jobId,
    required this.vehicleId,
    this.inspectorName = '',
    this.items = const [],
    this.summaryNotes = '',
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String jobId;
  final String vehicleId;
  final String inspectorName;
  final List<InspectionItemModel> items;
  final String summaryNotes;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'jobId': jobId,
      'vehicleId': vehicleId,
      'inspectorName': inspectorName,
      'items': items.map((e) => e.toMap()).toList(),
      'summaryNotes': summaryNotes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory VehicleInspectionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return VehicleInspectionModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      jobId: data['jobId'] as String? ?? '',
      vehicleId: data['vehicleId'] as String? ?? '',
      inspectorName: data['inspectorName'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((e) => InspectionItemModel.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      summaryNotes: data['summaryNotes'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }
}
