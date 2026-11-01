import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_cached_image.dart';
import 'package:garage_card/features/shared/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.recipientName,
  });

  final ChatMessageModel message;
  final bool isMe;
  final String? recipientName;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? AppColors.primaryRed
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));

    final textColor = isMe
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final timeColor = isMe
        ? Colors.white.withValues(alpha: 0.75)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    final senderLabel = isMe
        ? 'You'
        : (message.senderRole == 'merchant'
              ? 'Workshop'
              : (recipientName != null && recipientName!.isNotEmpty
                    ? recipientName!
                    : 'Customer'));

    final roleColor = isMe
        ? Colors.white.withValues(alpha: 0.9)
        : (isDark ? AppColors.accentBlueLight : AppColors.accentBlue);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(MediaQuery.of(context).size.width * 0.75, 480.0),
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            border: isMe
                ? null
                : Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe
                  ? const Radius.circular(16)
                  : const Radius.circular(4),
              bottomRight: isMe
                  ? const Radius.circular(4)
                  : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMe) ...[
                    Icon(
                      message.senderRole == 'merchant'
                          ? Icons.build_circle_outlined
                          : Icons.person_outline_rounded,
                      size: 13,
                      color: roleColor,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    senderLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (message.attachmentUrl != null &&
                  message.attachmentUrl!.isNotEmpty) ...[
                AppCachedImage(
                  imageUrl: message.attachmentUrl,
                  height: 160,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(8),
                  errorWidget: const SizedBox.shrink(),
                ),
                const SizedBox(height: 6),
              ],
              Text(message.text, style: AppFonts.bodyMedium(color: textColor)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.createdAt != null)
                    Text(
                      DateFormatter.formatTime(message.createdAt!),
                      style: AppFonts.labelSmall(color: timeColor),
                    ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead
                          ? Icons.done_all_rounded
                          : Icons.done_rounded,
                      size: 14,
                      color: timeColor,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
