import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_state_layout_size.dart';

enum AppPermissionType { location, notification, camera, storage, generic }

class AppPermissionState extends StatelessWidget {
  const AppPermissionState({
    super.key,
    required this.permissionType,
    this.title,
    this.description,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.layoutSize = AppStateLayoutSize.standard,
  });

  final AppPermissionType permissionType;
  final String? title;
  final String? description;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final AppStateLayoutSize layoutSize;

  IconData _getIcon() {
    switch (permissionType) {
      case AppPermissionType.location:
        return Icons.location_off_rounded;
      case AppPermissionType.notification:
        return Icons.notifications_off_rounded;
      case AppPermissionType.camera:
        return Icons.no_photography_rounded;
      case AppPermissionType.storage:
        return Icons.folder_off_rounded;
      case AppPermissionType.generic:
        return Icons.security_rounded;
    }
  }

  String _getDefaultTitle() {
    switch (permissionType) {
      case AppPermissionType.location:
        return 'Location Permission Needed';
      case AppPermissionType.notification:
        return 'Notifications Disabled';
      case AppPermissionType.camera:
        return 'Camera Access Needed';
      case AppPermissionType.storage:
        return 'Storage Access Needed';
      case AppPermissionType.generic:
        return 'Permission Required';
    }
  }

  String _getDefaultDescription() {
    switch (permissionType) {
      case AppPermissionType.location:
        return 'We use your location to discover verified workshops near you and calculate accurate road distances. You can enable location in settings or enter your area manually.';
      case AppPermissionType.notification:
        return 'Enable push alerts to receive instant notifications for repair status updates, estimate approvals, and invoice payments.';
      case AppPermissionType.camera:
        return 'Camera access is required to take vehicle inspection photos and capture odometer readings.';
      case AppPermissionType.storage:
        return 'Storage access is required to save digital PDF invoices and inspection documents on your device.';
      case AppPermissionType.generic:
        return 'This feature requires permissions that are currently denied.';
    }
  }

  String _getDefaultPrimaryLabel() {
    switch (permissionType) {
      case AppPermissionType.location:
        return 'Enable Location';
      case AppPermissionType.notification:
        return 'Enable Alerts';
      default:
        return 'Open Settings';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final effectiveTitle = title ?? _getDefaultTitle();
    final effectiveDesc = description ?? _getDefaultDescription();
    final effectivePrimaryLabel =
        primaryActionLabel ?? _getDefaultPrimaryLabel();

    final double padding = switch (layoutSize) {
      AppStateLayoutSize.compact => 16.0,
      AppStateLayoutSize.standard => 28.0,
      AppStateLayoutSize.fullScreen => 36.0,
    };

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(),
                  size: layoutSize == AppStateLayoutSize.compact ? 36 : 46,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                effectiveTitle,
                style: layoutSize == AppStateLayoutSize.compact
                    ? AppFonts.titleMedium(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold)
                    : AppFonts.titleLarge(color: primaryTextColor)
                          .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text(
                  effectiveDesc,
                  style: layoutSize == AppStateLayoutSize.compact
                      ? AppFonts.bodySmall(color: secondaryTextColor)
                      : AppFonts.bodyMedium(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (onPrimaryAction != null)
                    AppButton(
                      label: effectivePrimaryLabel,
                      onPressed: onPrimaryAction,
                      variant: AppButtonVariant.primary,
                      height: layoutSize == AppStateLayoutSize.compact
                          ? 38
                          : 46,
                    ),
                  if (secondaryActionLabel != null && onSecondaryAction != null)
                    TextButton(
                      onPressed: onSecondaryAction,
                      child: Text(
                        secondaryActionLabel!,
                        style: AppFonts.labelLarge(color: AppColors.accentBlue),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
