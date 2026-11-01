enum ImageUploadStatus {
  idle,
  validating,
  compressing,
  uploading,
  success,
  error,
}

class ImageUploadProgress {
  const ImageUploadProgress({
    this.status = ImageUploadStatus.idle,
    this.bytesTransferred = 0,
    this.totalBytes = 0,
    this.progress = 0.0,
    this.statusMessage,
    this.errorMessage,
  });

  final ImageUploadStatus status;
  final int bytesTransferred;
  final int totalBytes;
  final double progress;
  final String? statusMessage;
  final String? errorMessage;

  bool get isProcessing =>
      status == ImageUploadStatus.validating ||
      status == ImageUploadStatus.compressing ||
      status == ImageUploadStatus.uploading;

  bool get isSuccess => status == ImageUploadStatus.success;
  bool get hasError => status == ImageUploadStatus.error;

  ImageUploadProgress copyWith({
    ImageUploadStatus? status,
    int? bytesTransferred,
    int? totalBytes,
    double? progress,
    String? statusMessage,
    String? errorMessage,
  }) {
    return ImageUploadProgress(
      status: status ?? this.status,
      bytesTransferred: bytesTransferred ?? this.bytesTransferred,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
