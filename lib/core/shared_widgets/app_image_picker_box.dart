import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/services/image_upload_service.dart';
import 'package:garage_card/core/shared_widgets/app_cached_image.dart';
import 'package:image_picker/image_picker.dart';

class AppImagePickerBox extends StatelessWidget {
  const AppImagePickerBox({
    super.key,
    this.existingImageUrl,
    this.selectedFile,
    this.selectedBytes,
    this.height = 160,
    this.label = 'Package Image',
    this.helperText = 'Select a high quality image. It will be automatically compressed before upload.',
    required this.onPickImage,
    this.onRemoveImage,
    this.uploadProgress,
  });

  final String? existingImageUrl;
  final XFile? selectedFile;
  final Uint8List? selectedBytes;
  final double height;
  final String label;
  final String helperText;
  final VoidCallback onPickImage;
  final VoidCallback? onRemoveImage;
  final ImageUploadProgress? uploadProgress;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final hasImage =
        (selectedBytes != null && selectedBytes!.isNotEmpty) ||
        (selectedFile != null) ||
        (existingImageUrl != null && existingImageUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppFonts.labelMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: uploadProgress?.isProcessing == true
                  ? AppColors.accentBlue
                  : borderColor,
              width: uploadProgress?.isProcessing == true ? 1.5 : 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (selectedBytes != null && selectedBytes!.isNotEmpty)
                Image.memory(selectedBytes!, fit: BoxFit.cover)
              else if (existingImageUrl != null && existingImageUrl!.isNotEmpty)
                AppCachedImage(imageUrl: existingImageUrl, fit: BoxFit.cover)
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          color: AppColors.primaryRed,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Image',
                        style: AppFonts.labelMedium(color: primaryTextColor)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'JPG, PNG (Auto-compressed)',
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              if (hasImage && uploadProgress?.isProcessing != true)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: onPickImage,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.photo_camera_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Change',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (onRemoveImage != null) ...[
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onRemoveImage,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (!hasImage && uploadProgress?.isProcessing != true)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: onPickImage),
                  ),
                ),
              if (uploadProgress?.isProcessing == true)
                Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.accentBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            uploadProgress?.statusMessage ?? 'Processing...',
                            style: AppFonts.bodySmall(color: Colors.white)
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: uploadProgress?.progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accentBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (helperText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            helperText,
            style: AppFonts.labelSmall(color: secondaryTextColor),
          ),
        ],
      ],
    );
  }
}
