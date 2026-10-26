import 'package:garage_card/core/formatting/date_formatter.dart';

class GarageModel {
  const GarageModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.coverImageUrl,
    this.description = '',
    required this.address,
    required this.phone,
    this.whatsappNumber,
    required this.email,
    this.currencyCode = 'INR',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.city = '',
    this.rating = 4.8,
    this.reviewCount = 0,
    this.openHours = '9:00 AM - 7:00 PM',
    this.isVerified = true,
    required this.ownerUid,
    this.taxNumber = '',
    this.servicesOffered = const [],
    this.supportedVehicleCategories = const ['motorcycle', 'scooter', 'car'],
    this.isDoorstepRepairAvailable = false,
    this.isRoadsideAssistanceAvailable = false,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? logoUrl;
  final String? coverImageUrl;
  final String description;
  final String address;
  final String phone;
  final String? whatsappNumber;
  final String email;
  final String currencyCode;
  final double latitude;
  final double longitude;
  final String city;
  final double rating;
  final int reviewCount;
  final String openHours;
  final bool isVerified;
  final String ownerUid;
  final String taxNumber;
  final List<String> servicesOffered;
  final List<String> supportedVehicleCategories;
  final bool isDoorstepRepairAvailable;
  final bool isRoadsideAssistanceAvailable;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'address': address,
      'phone': phone,
      'whatsappNumber': whatsappNumber,
      'email': email,
      'currencyCode': currencyCode,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'rating': rating,
      'reviewCount': reviewCount,
      'openHours': openHours,
      'isVerified': isVerified,
      'ownerUid': ownerUid,
      'taxNumber': taxNumber,
      'servicesOffered': servicesOffered,
      'supportedVehicleCategories': supportedVehicleCategories,
      'isDoorstepRepairAvailable': isDoorstepRepairAvailable,
      'isRoadsideAssistanceAvailable': isRoadsideAssistanceAvailable,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory GarageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return GarageModel(
      id: id,
      name: data['name'] as String? ?? 'Garage',
      logoUrl: data['logoUrl'] as String?,
      coverImageUrl: data['coverImageUrl'] as String?,
      description: data['description'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      whatsappNumber:
          data['whatsappNumber'] as String? ?? data['phone'] as String?,
      email: data['email'] as String? ?? '',
      currencyCode: data['currencyCode'] as String? ?? 'INR',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      city: data['city'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      openHours: data['openHours'] as String? ?? '9:00 AM - 7:00 PM',
      isVerified: data['isVerified'] as bool? ?? true,
      ownerUid: data['ownerUid'] as String? ?? '',
      taxNumber: data['taxNumber'] as String? ?? '',
      servicesOffered:
          (data['servicesOffered'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      supportedVehicleCategories:
          (data['supportedVehicleCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['motorcycle', 'scooter', 'car'],
      isDoorstepRepairAvailable:
          data['isDoorstepRepairAvailable'] as bool? ?? false,
      isRoadsideAssistanceAvailable:
          data['isRoadsideAssistanceAvailable'] as bool? ?? false,
      createdAt: DateFormatter.parse(data['createdAt']),
    );
  }

  GarageModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? coverImageUrl,
    String? description,
    String? address,
    String? phone,
    String? whatsappNumber,
    String? email,
    String? currencyCode,
    double? latitude,
    double? longitude,
    String? city,
    double? rating,
    int? reviewCount,
    String? openHours,
    bool? isVerified,
    String? ownerUid,
    String? taxNumber,
    List<String>? servicesOffered,
    List<String>? supportedVehicleCategories,
    bool? isDoorstepRepairAvailable,
    bool? isRoadsideAssistanceAvailable,
    DateTime? createdAt,
  }) {
    return GarageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      currencyCode: currencyCode ?? this.currencyCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openHours: openHours ?? this.openHours,
      isVerified: isVerified ?? this.isVerified,
      ownerUid: ownerUid ?? this.ownerUid,
      taxNumber: taxNumber ?? this.taxNumber,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      supportedVehicleCategories:
          supportedVehicleCategories ?? this.supportedVehicleCategories,
      isDoorstepRepairAvailable:
          isDoorstepRepairAvailable ?? this.isDoorstepRepairAvailable,
      isRoadsideAssistanceAvailable:
          isRoadsideAssistanceAvailable ?? this.isRoadsideAssistanceAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
