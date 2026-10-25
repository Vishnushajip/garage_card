class GarageModel {
  const GarageModel({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.address,
    required this.phone,
    required this.email,
    this.currencyCode = 'INR',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.city = '',
    this.rating = 4.8,
    this.openHours = '9:00 AM - 7:00 PM',
    this.isVerified = true,
    required this.ownerUid,
    this.taxNumber = '',
    this.servicesOffered = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String address;
  final String phone;
  final String email;
  final String currencyCode;
  final double latitude;
  final double longitude;
  final String city;
  final double rating;
  final String openHours;
  final bool isVerified;
  final String ownerUid;
  final String taxNumber;
  final List<String> servicesOffered;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'address': address,
      'phone': phone,
      'email': email,
      'currencyCode': currencyCode,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'rating': rating,
      'openHours': openHours,
      'isVerified': isVerified,
      'ownerUid': ownerUid,
      'taxNumber': taxNumber,
      'servicesOffered': servicesOffered,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory GarageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return GarageModel(
      id: id,
      name: data['name'] as String? ?? 'Garage',
      logoUrl: data['logoUrl'] as String?,
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      email: data['email'] as String? ?? '',
      currencyCode: data['currencyCode'] as String? ?? 'INR',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      city: data['city'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      openHours: data['openHours'] as String? ?? '9:00 AM - 7:00 PM',
      isVerified: data['isVerified'] as bool? ?? true,
      ownerUid: data['ownerUid'] as String? ?? '',
      taxNumber: data['taxNumber'] as String? ?? '',
      servicesOffered:
          (data['servicesOffered'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  GarageModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? address,
    String? phone,
    String? email,
    String? currencyCode,
    double? latitude,
    double? longitude,
    String? city,
    double? rating,
    String? openHours,
    bool? isVerified,
    String? ownerUid,
    String? taxNumber,
    List<String>? servicesOffered,
    DateTime? createdAt,
  }) {
    return GarageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      currencyCode: currencyCode ?? this.currencyCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      openHours: openHours ?? this.openHours,
      isVerified: isVerified ?? this.isVerified,
      ownerUid: ownerUid ?? this.ownerUid,
      taxNumber: taxNumber ?? this.taxNumber,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
