import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/features/support/models/ticket_message_model.dart';

class TicketMessageBubble extends StatelessWidget {
  const TicketMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  final TicketMessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (message.isInternal) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.amber.shade900.withValues(alpha: 0.25)
              : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.amber.shade700 : Colors.amber.shade300,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                ),
                const SizedBox(width: 6),
                Text(
                  'Merchant Internal Note • Staff Only',
                  style: AppFonts.labelSmall(
                    color: isDark
                        ? Colors.amber.shade300
                        : Colors.amber.shade900,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                ),
                const Spacer(),
                Text(
                  DateFormatter.formatRelative(message.createdAt),
                  style: AppFonts.labelSmall(
                    color: isDark
                        ? Colors.amber.shade400
                        : Colors.amber.shade700,
                  ).copyWith(fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              message.message,
              style: AppFonts.bodyMedium(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'By ${message.senderName}',
              style: AppFonts.labelSmall(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ).copyWith(fontSize: 10),
            ),
          ],
        ),
      );
    }

    final bubbleBg = isMe
        ? AppColors.primaryRed
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);
    final textFg = isMe
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    final secondaryFg = isMe
        ? Colors.white.withValues(alpha: 0.75)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(
                message.senderName,
                style: AppFonts.labelSmall(color: AppColors.primaryRed)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(height: 2),
            ],
            Text(message.message, style: AppFonts.bodyMedium(color: textFg)),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatRelative(message.createdAt),
              style: AppFonts.labelSmall(color: secondaryFg)
                  .copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
