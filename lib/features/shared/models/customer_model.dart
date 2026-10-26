class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.garageId,
    this.userId,
    required this.name,
    required this.phone,
    this.whatsappNumber = '',
    this.email = '',
    this.address = '',
    this.notes = '',
    this.vehicleIds = const [],
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String? userId;
  final String name;
  final String phone;
  final String whatsappNumber;
  final String email;
  final String address;
  final String notes;
  final List<String> vehicleIds;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'userId': userId,
      'name': name,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'address': address,
      'notes': notes,
      'vehicleIds': vehicleIds,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory CustomerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CustomerModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      userId: data['userId'] as String?,
      name: data['name'] as String? ?? 'Customer',
      phone: data['phone'] as String? ?? '',
      whatsappNumber: data['whatsappNumber'] as String? ?? '',
      email: data['email'] as String? ?? '',
      address: data['address'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      vehicleIds:
          (data['vehicleIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  CustomerModel copyWith({
    String? id,
    String? garageId,
    String? userId,
    String? name,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? address,
    String? notes,
    List<String>? vehicleIds,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
