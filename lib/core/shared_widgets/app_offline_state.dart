import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_retry_button.dart';
import 'package:garage_card/core/shared_widgets/app_state_layout_size.dart';

class AppOfflineState extends StatelessWidget {
  const AppOfflineState({
    super.key,
    this.isCachedData = false,
    this.lastSyncedAt,
    this.onRetry,
    this.retryLabel = 'Retry Connection',
    this.customMessage,
    this.layoutSize = AppStateLayoutSize.standard,
  });

  final bool isCachedData;
  final DateTime? lastSyncedAt;
  final VoidCallback? onRetry;
  final String retryLabel;
  final String? customMessage;
  final AppStateLayoutSize layoutSize;

  String _formatLastSynced(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hrs ago';
    return '${diff.inDays} days ago';
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

    if (isCachedData) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accentAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 20,
              color: AppColors.accentAmber,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Offline — Showing cached data',
                    style: AppFonts.labelMedium(color: primaryTextColor)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (lastSyncedAt != null)
                    Text(
                      'Last updated ${_formatLastSynced(lastSyncedAt!)}',
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                    ),
                ],
              ),
            ),
            if (onRetry != null)
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.accentAmber,
                ),
                onPressed: onRetry,
                tooltip: 'Check connection',
              ),
          ],
        ),
      );
    }

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
                  color: AppColors.accentAmber.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 44,
                  color: AppColors.accentAmber,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'No Internet Connection',
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
                  customMessage ?? 'You are currently offline. Please verify your Wi-Fi or cellular network settings and try again.',
                  style: layoutSize == AppStateLayoutSize.compact
                      ? AppFonts.bodySmall(color: secondaryTextColor)
                      : AppFonts.bodyMedium(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                AppRetryButton(
                  onRetry: () async => onRetry!(),
                  label: retryLabel,
                  isCompact: layoutSize == AppStateLayoutSize.compact,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
