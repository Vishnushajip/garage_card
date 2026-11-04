import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

import '../ViewModel/chat_view_model.dart';
import '../Widgets/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.recipientName,
    this.recipientPhone,
    this.subtitle,
    this.isEmbedded = false,
  });

  final String conversationId;
  final String recipientName;
  final String? recipientPhone;
  final String? subtitle;
  final bool isEmbedded;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _quickReplies = [
    'We would like to discuss further',
    'Doorstep pickup is available',
    'When would you like to schedule?',
    'Please share vehicle details / photo',
  ];

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

  void _sendQuickReply(String text) {
    ref
        .read(chatViewModelProvider(widget.conversationId).notifier)
        .sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatViewModelProvider(widget.conversationId));
    final authState = ref.watch(authViewModelProvider);
    final authUser = authState.userProfile;
    final activeExperience = authState.activeExperience;
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
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final phone = widget.recipientPhone;
    final hasPhone = phone != null && phone.trim().isNotEmpty;

    final content = Column(
      children: [
        if (hasPhone)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.08),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.accentBlue.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.contact_phone_rounded,
                    color: AppColors.accentBlue,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct Contact: $phone',
                        style: AppFonts.labelSmall(color: AppColors.accentBlue)
                            .copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'One-tap dial or open WhatsApp message',
                        style: AppFonts.labelSmall(color: secondaryText)
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Call',
                  icon: const Icon(Icons.phone_rounded, size: 20),
                  color: AppColors.success,
                  onPressed: () => WhatsAppShareService.makePhoneCall(phone),
                ),
                IconButton(
                  tooltip: 'WhatsApp',
                  icon: const AppWhatsAppIcon(
                    color: AppColors.success,
                    size: 20,
                  ),
                  onPressed: () => WhatsAppShareService.openWhatsApp(
                    phone: phone,
                    message:
                        'Hi ${widget.recipientName}, regarding your inquiry on WeFix.',
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.isLoading && state.messages.isEmpty
              ? const Center(child: AppLoading())
              : state.messages.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    title: 'No Messages Yet',
                    message: 'Send an inquiry message to discuss service packages, schedules, and repair details.',
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: state.messages.length,
                  itemBuilder: (ctx, index) {
                    final msg = state.messages[index];
                    final isMe = (activeExperience == 'merchant')
                        ? (msg.senderRole == 'merchant')
                        : (activeExperience == 'customer')
                        ? (msg.senderRole == 'customer')
                        : (msg.senderId == currentUserId);
                    return ChatBubble(
                      message: msg,
                      isMe: isMe,
                      recipientName: widget.recipientName,
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          color: surfaceColor,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _quickReplies.map((reply) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(reply),
                    labelStyle: AppFonts.labelSmall(color: primaryText),
                    backgroundColor: isDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: () => _sendQuickReply(reply),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
    );

    if (widget.isEmbedded) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryRed.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      widget.recipientName.isNotEmpty
                          ? widget.recipientName[0].toUpperCase()
                          : 'G',
                      style: AppFonts.titleMedium(color: AppColors.primaryRed),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.recipientName,
                          style: AppFonts.titleMedium(color: primaryText)
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null)
                          Text(
                            widget.subtitle!,
                            style: AppFonts.labelSmall(color: secondaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (hasPhone) ...[
                    IconButton.outlined(
                      tooltip: 'Call Phone',
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      color: AppColors.success,
                      onPressed: () =>
                          WhatsAppShareService.makePhoneCall(phone),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: 'WhatsApp',
                      icon: const AppWhatsAppIcon(
                        color: AppColors.success,
                        size: 18,
                      ),
                      onPressed: () => WhatsAppShareService.openWhatsApp(
                        phone: phone,
                        message:
                            'Hi ${widget.recipientName}, regarding your inquiry on WeFix.',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppCustomAppBar(
        titleWidget: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryRed.withValues(alpha: 0.12),
              child: Text(
                widget.recipientName.isNotEmpty
                    ? widget.recipientName[0].toUpperCase()
                    : 'G',
                style: AppFonts.titleSmall(color: AppColors.primaryRed),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recipientName,
                    style: AppFonts.titleMedium(color: primaryText)
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: AppFonts.labelSmall(color: secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (hasPhone) ...[
            IconButton(
              tooltip: 'Call',
              icon: const Icon(Icons.phone_rounded, size: 20),
              color: AppColors.success,
              onPressed: () => WhatsAppShareService.makePhoneCall(phone),
            ),
            IconButton(
              tooltip: 'WhatsApp',
              icon: const AppWhatsAppIcon(color: AppColors.success, size: 20),
              onPressed: () => WhatsAppShareService.openWhatsApp(
                phone: phone,
                message:
                    'Hi ${widget.recipientName}, regarding your inquiry on WeFix.',
              ),
            ),
          ],
        ],
      ),
      body: AppResponsiveLayout(child: content),
    );
  }
}
