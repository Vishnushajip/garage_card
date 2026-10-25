class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phoneNumber = '',
    this.role = 'customer',
    this.garageId,
    this.preferredLanguage = 'en',
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String? garageId;
  final String preferredLanguage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isMerchant => role == 'merchant';
  bool get isCustomer => role == 'customer';

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'garageId': garageId,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfileModel.fromFirestore(
    Map<String, dynamic> data,
    String uid,
  ) {
    return UserProfileModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? 'User',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      garageId: data['garageId'] as String?,
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'] as String)
          : null,
    );
  }

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    String? garageId,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      garageId: garageId ?? this.garageId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
