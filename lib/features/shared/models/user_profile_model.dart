import 'package:garage_card/core/formatting/date_formatter.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phoneNumber = '',
    this.whatsappNumber = '',
    this.role = 'customer',
    this.garageId,
    this.avatarUrl,
    this.preferredLanguage = 'en',
    this.fcmTokens = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String whatsappNumber;
  final String role;
  final String? garageId;
  final String? avatarUrl;
  final String preferredLanguage;
  final List<String> fcmTokens;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isMerchant => role == 'merchant';
  bool get isCustomer => role == 'customer';
  bool get isProfileComplete =>
      fullName.trim().isNotEmpty &&
      fullName.trim() != 'User' &&
      phoneNumber.trim().isNotEmpty &&
      whatsappNumber.trim().isNotEmpty;

  double get completionPercentage {
    var completed = 0;
    if (email.trim().isNotEmpty) completed++;
    if (fullName.trim().isNotEmpty && fullName.trim() != 'User') completed++;
    if (phoneNumber.trim().isNotEmpty) completed++;
    if (whatsappNumber.trim().isNotEmpty) completed++;
    return completed / 4.0;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'role': role,
      'garageId': garageId,
      'avatarUrl': avatarUrl,
      'preferredLanguage': preferredLanguage,
      'fcmTokens': fcmTokens,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserProfileModel.fromFirestore(
    Map<String, dynamic> data,
    String uid,
  ) {
    final rawTokens = data['fcmTokens'];
    final List<String> tokens = rawTokens is List
        ? rawTokens.map((e) => e.toString()).toList()
        : const [];

    return UserProfileModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? 'User',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      whatsappNumber: data['whatsappNumber'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      garageId: data['garageId'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      preferredLanguage: data['preferredLanguage'] as String? ?? 'en',
      fcmTokens: tokens,
      createdAt: DateFormatter.parse(data['createdAt']),
      updatedAt: DateFormatter.parse(data['updatedAt']),
    );
  }

  UserProfileModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? whatsappNumber,
    String? role,
    String? garageId,
    String? avatarUrl,
    String? preferredLanguage,
    List<String>? fcmTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      role: role ?? this.role,
      garageId: garageId ?? this.garageId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
