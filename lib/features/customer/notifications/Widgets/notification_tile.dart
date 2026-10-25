import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/features/shared/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final hasImage =
        notification.imageUrl != null && notification.imageUrl!.isNotEmpty;

    return ListTile(
      onTap: onTap,
      leading: hasImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                notification.imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackIcon(isDark, secondaryTextColor),
              ),
            )
          : _buildFallbackIcon(isDark, secondaryTextColor),
      title: Text(
        notification.title,
        style: AppFonts.titleMedium(color: primaryTextColor).copyWith(
          fontWeight:
              notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            notification.body,
            style: AppFonts.bodyMedium(color: secondaryTextColor),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.formatRelative(notification.createdAt),
            style: AppFonts.labelSmall(color: secondaryTextColor),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }

  Widget _buildFallbackIcon(bool isDark, Color secondaryTextColor) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: notification.isRead
            ? (isDark ? AppColors.cardDark : AppColors.borderLight)
            : AppColors.accentBlue.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        notification.type == 'job_status'
            ? Icons.build_circle_rounded
            : notification.type == 'estimate'
                ? Icons.request_quote_rounded
                : notification.type == 'invoice_issued'
                    ? Icons.receipt_long_rounded
                    : Icons.notifications_active_rounded,
        color: notification.isRead ? secondaryTextColor : AppColors.accentBlue,
        size: 22,
      ),
    );
  }
}
