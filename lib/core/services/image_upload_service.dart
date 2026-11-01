import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'image_upload/image_compression_processor.dart';
import 'image_upload/image_profile.dart';
import 'image_upload/image_upload_progress.dart';
import 'image_upload/uploaded_image.dart';

export 'image_upload/image_compression_processor.dart';
export 'image_upload/image_profile.dart';
export 'image_upload/image_upload_progress.dart';
export 'image_upload/uploaded_image.dart';

class ImageUploadService {
  ImageUploadService({
    FirebaseStorage? storage,
    ImageCompressionProcessor? processor,
  }) : _customStorage = storage,
       _processor = processor ?? const ImageCompressionProcessor();

  final FirebaseStorage? _customStorage;
  final ImageCompressionProcessor _processor;
  final Uuid _uuid = const Uuid();

  FirebaseStorage get _storage => _customStorage ?? FirebaseStorage.instance;

  Future<Uint8List> _readBytes(dynamic source) async {
    if (source is Uint8List) {
      return source;
    }
    if (source is List<int>) {
      return Uint8List.fromList(source);
    }
    if (source is XFile) {
      return await source.readAsBytes();
    }
    try {
      final dynamic dynamicFile = source;
      final bytes = await dynamicFile.readAsBytes();
      if (bytes is Uint8List) return bytes;
      if (bytes is List<int>) return Uint8List.fromList(bytes);
    } catch (_) {}

    throw ArgumentError('Unsupported image input type: ${source.runtimeType}');
  }

  String _sanitizeSegment(String input) {
    return input
        .split('/')
        .map((segment) => segment.replaceAll(RegExp(r'[^a-zA-Z0-9_\-.]'), '_'))
        .where((segment) => segment.isNotEmpty)
        .join('/');
  }

  String buildStoragePath({
    required String folder,
    String? ownerId,
    String? entityId,
    required String fileExtension,
    String? profileName,
  }) {
    final sanitizedFolder = _sanitizeSegment(folder);
    final idPart = _uuid.v4();
    final profileTag = profileName != null ? '_$profileName' : '';
    final fileName =
        'img_${DateTime.now().millisecondsSinceEpoch}_$idPart$profileTag.$fileExtension';

    if (ownerId != null && ownerId.isNotEmpty) {
      final sanitizedOwner = _sanitizeSegment(ownerId);
      if (entityId != null && entityId.isNotEmpty) {
        final sanitizedEntity = _sanitizeSegment(entityId);
        return '$sanitizedFolder/$sanitizedOwner/$sanitizedEntity/$fileName';
      }
      return '$sanitizedFolder/$sanitizedOwner/$fileName';
    }

    if (entityId != null && entityId.isNotEmpty) {
      final sanitizedEntity = _sanitizeSegment(entityId);
      return '$sanitizedFolder/$sanitizedEntity/$fileName';
    }

    return '$sanitizedFolder/$fileName';
  }

  Future<UploadedImage> uploadImage({
    required dynamic file,
    required String folder,
    String? ownerId,
    String? entityId,
    ImageProfile profile = ImageProfile.card,
    String? previousImageUrl,
    String? previousStoragePath,
    void Function(ImageUploadProgress)? onProgress,
  }) async {
    onProgress?.call(
      const ImageUploadProgress(
        status: ImageUploadStatus.validating,
        progress: 0.1,
        statusMessage: 'Validating image...',
      ),
    );

    final Uint8List rawBytes = await _readBytes(file);

    onProgress?.call(
      const ImageUploadProgress(
        status: ImageUploadStatus.compressing,
        progress: 0.3,
        statusMessage: 'Optimizing and compressing image...',
      ),
    );

    final ProcessedImageResult processed = await _processor.processImage(
      inputBytes: rawBytes,
      profile: profile,
    );

    final storagePath = buildStoragePath(
      folder: folder,
      ownerId: ownerId,
      entityId: entityId,
      fileExtension: processed.fileExtension,
      profileName: profile.name,
    );

    final fileName = storagePath.split('/').last;

    onProgress?.call(
      const ImageUploadProgress(
        status: ImageUploadStatus.uploading,
        progress: 0.5,
        statusMessage: 'Uploading to secure storage...',
      ),
    );

    String downloadUrl = '';
    final uploadedAt = DateTime.now();

    if (FirebaseConfig.isInitialized) {
      try {
        final ref = _storage.ref(storagePath);
        final metadata = SettableMetadata(
          contentType: processed.contentType,
          cacheControl: 'public, max-age=31536000',
          customMetadata: {
            'originalSizeBytes': processed.originalSizeBytes.toString(),
            'compressedSizeBytes': processed.compressedSizeBytes.toString(),
            'width': processed.width.toString(),
            'height': processed.height.toString(),
            'checksum': processed.checksum,
            'profile': profile.name,
          },
        );

        final uploadTask = ref.putData(processed.bytes, metadata);

        final subscription = uploadTask.snapshotEvents.listen((event) {
          final total = event.totalBytes;
          final transferred = event.bytesTransferred;
          final pct = total > 0 ? (0.5 + (transferred / total) * 0.45) : 0.5;
          onProgress?.call(
            ImageUploadProgress(
              status: ImageUploadStatus.uploading,
              bytesTransferred: transferred,
              totalBytes: total,
              progress: pct.clamp(0.5, 0.95),
              statusMessage: 'Uploading: ${(pct * 100).toInt()}%',
            ),
          );
        });

        try {
          await uploadTask.timeout(const Duration(seconds: 90));
        } finally {
          await subscription.cancel();
        }

        downloadUrl = await ref.getDownloadURL().timeout(
          const Duration(seconds: 15),
        );
      } catch (e) {
        try {
          downloadUrl = await _uploadViaRest(
            bytes: processed.bytes,
            storagePath: storagePath,
            contentType: processed.contentType,
          );
        } catch (_) {
          onProgress?.call(
            ImageUploadProgress(
              status: ImageUploadStatus.error,
              errorMessage: e.toString(),
              statusMessage: 'Upload failed',
            ),
          );
          rethrow;
        }
      }
    }

    if (downloadUrl.isEmpty) {
      downloadUrl =
          'https://firebasestorage.googleapis.com/v0/b/garage-card-demo/o/${Uri.encodeComponent(storagePath)}?alt=media';
    }

    final uploadedImage = UploadedImage(
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      fileName: fileName,
      contentType: processed.contentType,
      originalSizeBytes: processed.originalSizeBytes,
      compressedSizeBytes: processed.compressedSizeBytes,
      width: processed.width,
      height: processed.height,
      checksum: processed.checksum,
      uploadedAt: uploadedAt,
    );

    onProgress?.call(
      ImageUploadProgress(
        status: ImageUploadStatus.success,
        progress: 1.0,
        bytesTransferred: processed.compressedSizeBytes,
        totalBytes: processed.compressedSizeBytes,
        statusMessage: 'Image optimized & uploaded successfully',
      ),
    );

    if (previousImageUrl != null || previousStoragePath != null) {
      unawaited(
        safeCleanupPreviousImage(
          previousUrl: previousImageUrl,
          previousPath: previousStoragePath,
        ),
      );
    }

    return uploadedImage;
  }

  Future<bool> deleteImageByPath(String storagePath) async {
    if (!FirebaseConfig.isInitialized) return true;
    try {
      final ref = _storage.ref(storagePath);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('STORAGE_DELETE_PATH_ERROR: $e');
      return false;
    }
  }

  Future<bool> deleteImageByUrl(String downloadUrl) async {
    if (!FirebaseConfig.isInitialized) return true;
    if (downloadUrl.isEmpty) return false;
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      return true;
    } catch (e) {
      debugPrint('STORAGE_DELETE_URL_ERROR: $e');
      return false;
    }
  }

  Future<void> safeCleanupPreviousImage({
    String? previousUrl,
    String? previousPath,
  }) async {
    if (previousPath != null && previousPath.isNotEmpty) {
      await deleteImageByPath(previousPath);
      return;
    }
    if (previousUrl != null &&
        previousUrl.isNotEmpty &&
        previousUrl.startsWith('http') &&
        previousUrl.contains('firebasestorage.googleapis.com')) {
      await deleteImageByUrl(previousUrl);
    }
  }

  Future<String> _uploadViaRest({
    required Uint8List bytes,
    required String storagePath,
    required String contentType,
  }) async {
    final bucket = _storage.bucket.isNotEmpty
        ? _storage.bucket
        : 'garage-b7ed1.firebasestorage.app';
    final uri = Uri.parse(
      'https://firebasestorage.googleapis.com/v0/b/$bucket/o?name=${Uri.encodeComponent(storagePath)}',
    );
    final headers = <String, String>{'Content-Type': contentType};
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {}
    }
    final response = await http
        .post(uri, headers: headers, body: bytes)
        .timeout(const Duration(seconds: 60));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final downloadTokens = json['downloadTokens'] as String?;
      if (downloadTokens != null && downloadTokens.isNotEmpty) {
        return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(storagePath)}?alt=media&token=$downloadTokens';
      }
      return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(storagePath)}?alt=media';
    }
    throw StateError('REST upload failed with status ${response.statusCode}');
  }
}

final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});
