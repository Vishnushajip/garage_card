import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

import 'image_profile.dart';

class ProcessedImageResult {
  const ProcessedImageResult({
    required this.bytes,
    required this.width,
    required this.height,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.contentType,
    required this.fileExtension,
    required this.checksum,
    required this.durationMs,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final String contentType;
  final String fileExtension;
  final String checksum;
  final int durationMs;

  double get savedPercentage {
    if (originalSizeBytes <= 0) return 0.0;
    final saved = originalSizeBytes - compressedSizeBytes;
    return saved > 0 ? (saved / originalSizeBytes) * 100 : 0.0;
  }
}

class ImageCompressionProcessor {
  const ImageCompressionProcessor();

  static const int maxInputSizeBytes = 20 * 1024 * 1024;

  bool _hasTransparentPixels(img.Image image) {
    if (!image.hasAlpha) return false;
    final totalPixels = image.width * image.height;
    final step = totalPixels > 250000 ? 5 : 1;
    var index = 0;
    for (final pixel in image) {
      if (index % step == 0 && pixel.a < 250) {
        return true;
      }
      index++;
    }
    return false;
  }

  Future<ProcessedImageResult> processImage({
    required Uint8List inputBytes,
    required ImageProfile profile,
  }) async {
    final stopwatch = Stopwatch()..start();

    if (inputBytes.isEmpty) {
      throw ArgumentError('Image byte buffer cannot be empty.');
    }
    if (inputBytes.length > maxInputSizeBytes) {
      throw ArgumentError('Image file size exceeds maximum 20MB limit.');
    }

    final decoded = img.decodeImage(inputBytes);
    if (decoded == null) {
      throw const FormatException(
        'Failed to decode image. Invalid or corrupt image data.',
      );
    }

    img.Image prepared = img.bakeOrientation(decoded);

    final originalWidth = prepared.width;
    final originalHeight = prepared.height;

    final targetDimensions = _calculateTargetDimensions(
      width: originalWidth,
      height: originalHeight,
      maxWidth: profile.maxWidth,
      maxHeight: profile.maxHeight,
    );

    final needsResize =
        targetDimensions.width != originalWidth ||
        targetDimensions.height != originalHeight;

    if (needsResize) {
      prepared = img.copyResize(
        prepared,
        width: targetDimensions.width,
        height: targetDimensions.height,
        interpolation: img.Interpolation.cubic,
      );
    }

    final hasTransparency = _hasTransparentPixels(prepared);

    Uint8List compressedBytes;
    String contentType;
    String fileExtension;

    if (hasTransparency) {
      compressedBytes = Uint8List.fromList(img.encodePng(prepared, level: 6));
      contentType = 'image/png';
      fileExtension = 'png';
    } else {
      compressedBytes = Uint8List.fromList(
        img.encodeJpg(prepared, quality: profile.quality),
      );
      contentType = 'image/jpeg';
      fileExtension = 'jpg';
    }

    if (!needsResize &&
        inputBytes.length < compressedBytes.length &&
        inputBytes.length <= (profile.maxWidth * profile.maxHeight)) {
      compressedBytes = inputBytes;
      if (inputBytes.length >= 8 &&
          inputBytes[0] == 0x89 &&
          inputBytes[1] == 0x50 &&
          inputBytes[2] == 0x4E &&
          inputBytes[3] == 0x47) {
        contentType = 'image/png';
        fileExtension = 'png';
      } else {
        contentType = 'image/jpeg';
        fileExtension = 'jpg';
      }
    }

    final checksum = sha256.convert(compressedBytes).toString();
    stopwatch.stop();

    return ProcessedImageResult(
      bytes: compressedBytes,
      width: prepared.width,
      height: prepared.height,
      originalSizeBytes: inputBytes.length,
      compressedSizeBytes: compressedBytes.length,
      contentType: contentType,
      fileExtension: fileExtension,
      checksum: checksum,
      durationMs: stopwatch.elapsedMilliseconds,
    );
  }

  _Dimensions _calculateTargetDimensions({
    required int width,
    required int height,
    required int maxWidth,
    required int maxHeight,
  }) {
    if (width <= maxWidth && height <= maxHeight) {
      return _Dimensions(width, height);
    }

    final double ratio = width / height;
    int targetWidth = width;
    int targetHeight = height;

    if (targetWidth > maxWidth) {
      targetWidth = maxWidth;
      targetHeight = (targetWidth / ratio).round();
    }

    if (targetHeight > maxHeight) {
      targetHeight = maxHeight;
      targetWidth = (targetHeight * ratio).round();
    }

    if (targetWidth <= 0) targetWidth = 1;
    if (targetHeight <= 0) targetHeight = 1;

    return _Dimensions(targetWidth, targetHeight);
  }
}

class _Dimensions {
  const _Dimensions(this.width, this.height);
  final int width;
  final int height;
}
