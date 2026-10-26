import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

import '../ViewModel/chat_view_model.dart';
import '../Widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.recipientName,
    this.subtitle,
  });

  final String conversationId;
  final String recipientName;
  final String? subtitle;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref
        .read(chatViewModelProvider(widget.conversationId).notifier)
        .sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider(widget.conversationId));
    final authUser = ref.watch(authViewModelProvider).userProfile;
    final currentUserId = authUser?.uid ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryRed.withValues(alpha: 0.12),
              child: Text(
                widget.recipientName.isNotEmpty
                    ? widget.recipientName[0].toUpperCase()
                    : 'G',
                style: AppFonts.titleSmall(color: AppColors.primaryRed),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: AppFonts.titleMedium(color: primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: AppFonts.bodySmall(color: secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: AppResponsiveLayout(
        child: Column(
          children: [
            Expanded(
              child: state.isLoading && state.messages.isEmpty
                  ? const Center(child: AppLoading())
                  : state.messages.isEmpty
                  ? const Center(
                      child: AppEmptyState(
                        title: 'No Messages Yet',
                        message: 'Send a message to start conversation about vehicle repairs, parts, or quotes.',
                        icon: Icons.chat_bubble_outline_rounded,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: state.messages.length,
                      itemBuilder: (ctx, index) {
                        final msg = state.messages[index];
                        final isMe = msg.senderId == currentUserId;
                        return ChatBubble(message: msg, isMe: isMe);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _textController,
                        hint: 'Type a message...',
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: state.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                        onPressed: state.isSending ? null : _onSend,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
