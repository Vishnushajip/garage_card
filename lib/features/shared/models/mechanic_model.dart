class MechanicModel {
  const MechanicModel({
    required this.id,
    required this.garageId,
    required this.name,
    this.phone = '',
    this.specialization = '',
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String name;
  final String phone;
  final String specialization;
  final bool isActive;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'name': name,
      'phone': phone,
      'specialization': specialization,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory MechanicModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MechanicModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      specialization: data['specialization'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  MechanicModel copyWith({
    String? id,
    String? garageId,
    String? name,
    String? phone,
    String? specialization,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return MechanicModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
