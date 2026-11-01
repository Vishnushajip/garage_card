import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_retry_button.dart';
import 'package:garage_card/core/shared_widgets/app_state_layout_size.dart';

export 'app_state_layout_size.dart';

enum AppErrorType {
  server,
  network,
  timeout,
  permission,
  validation,
  unauthorized,
  generic,
}

class AppErrorState extends StatefulWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.title = 'Something went wrong',
    this.errorType = AppErrorType.generic,
    this.technicalDetails,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.layoutSize = AppStateLayoutSize.standard,
  });

  final String message;
  final String title;
  final AppErrorType errorType;
  final String? technicalDetails;
  final VoidCallback? onRetry;
  final String retryLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final AppStateLayoutSize layoutSize;

  @override
  State<AppErrorState> createState() => _AppErrorStateState();
}

class _AppErrorStateState extends State<AppErrorState> {
  bool _showDetails = false;

  IconData _getIconForType() {
    switch (widget.errorType) {
      case AppErrorType.network:
        return Icons.wifi_off_rounded;
      case AppErrorType.timeout:
        return Icons.timer_off_outlined;
      case AppErrorType.permission:
        return Icons.lock_person_outlined;
      case AppErrorType.unauthorized:
        return Icons.shield_outlined;
      case AppErrorType.validation:
        return Icons.fact_check_outlined;
      case AppErrorType.server:
        return Icons.dns_outlined;
      case AppErrorType.generic:
        return Icons.error_outline_rounded;
    }
  }

  Color _getColorForType() {
    switch (widget.errorType) {
      case AppErrorType.network:
      case AppErrorType.timeout:
        return AppColors.accentAmber;
      case AppErrorType.permission:
      case AppErrorType.unauthorized:
        return AppColors.accentBlue;
      case AppErrorType.validation:
        return AppColors.accentAmber;
      case AppErrorType.server:
      case AppErrorType.generic:
        return AppColors.error;
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
    final cardBg = isDark ? AppColors.cardDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final color = _getColorForType();

    final double padding = switch (widget.layoutSize) {
      AppStateLayoutSize.compact => 16.0,
      AppStateLayoutSize.standard => 28.0,
      AppStateLayoutSize.fullScreen => 36.0,
    };

    final double iconSize = switch (widget.layoutSize) {
      AppStateLayoutSize.compact => 32.0,
      AppStateLayoutSize.standard => 44.0,
      AppStateLayoutSize.fullScreen => 52.0,
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
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIconForType(), size: iconSize, color: color),
              ),
              const SizedBox(height: 18),
              Text(
                context.tr(widget.title),
                style: widget.layoutSize == AppStateLayoutSize.compact
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
                  context.tr(widget.message),
                  style: widget.layoutSize == AppStateLayoutSize.compact
                      ? AppFonts.bodySmall(color: secondaryTextColor)
                      : AppFonts.bodyMedium(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.technicalDetails != null &&
                  widget.technicalDetails!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => setState(() => _showDetails = !_showDetails),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showDetails
                              ? context.tr('hideDetails')
                              : context.tr('showDetails'),
                          style: AppFonts.labelSmall(
                            color: AppColors.accentBlue,
                          ),
                        ),
                        Icon(
                          _showDetails
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.accentBlue,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showDetails) ...[
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      widget.technicalDetails!,
                      style: AppFonts.bodySmall(color: secondaryTextColor)
                          .copyWith(fontFamily: 'monospace', fontSize: 11),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (widget.onRetry != null)
                    AppRetryButton(
                      onRetry: () async => widget.onRetry!(),
                      label: context.tr(widget.retryLabel),
                      isCompact:
                          widget.layoutSize == AppStateLayoutSize.compact,
                    ),
                  if (widget.secondaryActionLabel != null &&
                      widget.onSecondaryAction != null)
                    AppButton(
                      label: widget.secondaryActionLabel!,
                      onPressed: widget.onSecondaryAction,
                      variant: AppButtonVariant.secondary,
                      height: widget.layoutSize == AppStateLayoutSize.compact
                          ? 38
                          : 46,
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
