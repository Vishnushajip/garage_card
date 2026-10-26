import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/features/shared/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message, required this.isMe});

  final ChatMessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? AppColors.primaryRed
        : (isDark ? AppColors.cardDark : AppColors.cardLight);

    final textColor = isMe
        ? Colors.white
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final timeColor = isMe
        ? Colors.white.withValues(alpha: 0.75)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
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
              if (message.attachmentUrl != null &&
                  message.attachmentUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    message.attachmentUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
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
