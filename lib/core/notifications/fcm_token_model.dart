class FcmTokenModel {
  const FcmTokenModel({
    required this.token,
    required this.userId,
    required this.platform,
    this.deviceId,
    required this.updatedAt,
    this.isActive = true,
  });

  final String token;
  final String userId;
  final String platform;
  final String? deviceId;
  final DateTime updatedAt;
  final bool isActive;

  Map<String, dynamic> toFirestore() {
    return {
      'token': token,
      'userId': userId,
      'platform': platform,
      'deviceId': deviceId,
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory FcmTokenModel.fromFirestore(Map<String, dynamic> data, String id) {
    return FcmTokenModel(
      token: id,
      userId: data['userId'] as String? ?? '',
      platform: data['platform'] as String? ?? 'unknown',
      deviceId: data['deviceId'] as String?,
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  FcmTokenModel copyWith({
    String? token,
    String? userId,
    String? platform,
    String? deviceId,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return FcmTokenModel(
      token: token ?? this.token,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      deviceId: deviceId ?? this.deviceId,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
