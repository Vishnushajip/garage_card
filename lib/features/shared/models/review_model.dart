import 'package:garage_card/core/formatting/date_formatter.dart';

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.garageId,
    required this.customerId,
    required this.customerName,
    this.customerPhotoUrl,
    this.jobId,
    required this.rating,
    required this.reviewText,
    this.reviewImageUrl,
    this.consentSharePhoto = false,
    this.consentShareName = true,
    this.isReported = false,
    this.createdAt,
  });

  final String id;
  final String garageId;
  final String customerId;
  final String customerName;
  final String? customerPhotoUrl;
  final String? jobId;
  final double rating;
  final String reviewText;
  final String? reviewImageUrl;
  final bool consentSharePhoto;
  final bool consentShareName;
  final bool isReported;
  final DateTime? createdAt;

  String get displayCustomerName {
    if (consentShareName && customerName.trim().isNotEmpty) {
      return customerName.trim();
    }
    return 'Verified Customer';
  }

  String? get publicPhotoUrl {
    if (consentSharePhoto) {
      return customerPhotoUrl;
    }
    return null;
  }

  String? get publicReviewImageUrl {
    if (consentSharePhoto) {
      return reviewImageUrl;
    }
    return null;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'garageId': garageId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhotoUrl': customerPhotoUrl,
      'jobId': jobId,
      'rating': rating,
      'reviewText': reviewText,
      'reviewImageUrl': reviewImageUrl,
      'consentSharePhoto': consentSharePhoto,
      'consentShareName': consentShareName,
      'isReported': isReported,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory ReviewModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      garageId: data['garageId'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhotoUrl: data['customerPhotoUrl'] as String?,
      jobId: data['jobId'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      reviewText: data['reviewText'] as String? ?? '',
      reviewImageUrl: data['reviewImageUrl'] as String?,
      consentSharePhoto: data['consentSharePhoto'] as bool? ?? false,
      consentShareName: data['consentShareName'] as bool? ?? true,
      isReported: data['isReported'] as bool? ?? false,
      createdAt: DateFormatter.parse(data['createdAt']),
    );
  }

  ReviewModel copyWith({
    String? id,
    String? garageId,
    String? customerId,
    String? customerName,
    String? customerPhotoUrl,
    String? jobId,
    double? rating,
    String? reviewText,
    String? reviewImageUrl,
    bool? consentSharePhoto,
    bool? consentShareName,
    bool? isReported,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhotoUrl: customerPhotoUrl ?? this.customerPhotoUrl,
      jobId: jobId ?? this.jobId,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      reviewImageUrl: reviewImageUrl ?? this.reviewImageUrl,
      consentSharePhoto: consentSharePhoto ?? this.consentSharePhoto,
      consentShareName: consentShareName ?? this.consentShareName,
      isReported: isReported ?? this.isReported,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
