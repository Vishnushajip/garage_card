class UploadedImage {
  const UploadedImage({
    required this.downloadUrl,
    required this.storagePath,
    required this.fileName,
    required this.contentType,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.width,
    required this.height,
    this.checksum,
    required this.uploadedAt,
  });

  final String downloadUrl;
  final String storagePath;
  final String fileName;
  final String contentType;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final int width;
  final int height;
  final String? checksum;
  final DateTime uploadedAt;

  double get compressionRatio {
    if (originalSizeBytes <= 0) return 1.0;
    return compressedSizeBytes / originalSizeBytes;
  }

  int get savedBytes => originalSizeBytes > compressedSizeBytes
      ? originalSizeBytes - compressedSizeBytes
      : 0;

  double get savedPercentage {
    if (originalSizeBytes <= 0) return 0.0;
    return (savedBytes / originalSizeBytes) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'fileName': fileName,
      'contentType': contentType,
      'originalSizeBytes': originalSizeBytes,
      'compressedSizeBytes': compressedSizeBytes,
      'width': width,
      'height': height,
      'checksum': checksum,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory UploadedImage.fromMap(Map<String, dynamic> map) {
    return UploadedImage(
      downloadUrl: map['downloadUrl'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
      fileName: map['fileName'] as String? ?? '',
      contentType: map['contentType'] as String? ?? 'image/jpeg',
      originalSizeBytes: (map['originalSizeBytes'] as num?)?.toInt() ?? 0,
      compressedSizeBytes: (map['compressedSizeBytes'] as num?)?.toInt() ?? 0,
      width: (map['width'] as num?)?.toInt() ?? 0,
      height: (map['height'] as num?)?.toInt() ?? 0,
      checksum: map['checksum'] as String?,
      uploadedAt: map['uploadedAt'] != null
          ? DateTime.tryParse(map['uploadedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, String> toStorageCustomMetadata({String? profile}) {
    return {
      'originalSizeBytes': originalSizeBytes.toString(),
      'compressedSizeBytes': compressedSizeBytes.toString(),
      'width': width.toString(),
      'height': height.toString(),
      'checksum': ?checksum,
      'profile': ?profile,
    };
  }
}
