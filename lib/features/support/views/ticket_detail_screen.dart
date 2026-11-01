import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading_state.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/support/models/support_ticket_model.dart';
import 'package:garage_card/features/support/view_models/ticket_details_view_model.dart';
import 'package:garage_card/features/support/widgets/ticket_message_bubble.dart';
import 'package:garage_card/features/support/widgets/ticket_priority_badge.dart';
import 'package:garage_card/features/support/widgets/ticket_resolution_dialog.dart';
import 'package:garage_card/features/support/widgets/ticket_status_badge.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final notifier = ref.read(
      ticketDetailsViewModelProvider(widget.ticketId).notifier,
    );
    final success = await notifier.sendReply(text);
    if (success) {
      _messageController.clear();
      _scrollToBottom();
    }
  }

  Widget _buildHeaderCard(
    BuildContext context,
    SupportTicketModel ticket,
    bool isMerchant,
    TicketDetailsViewModel notifier,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ticket.subject,
                  style: AppFonts.titleMedium(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              TicketStatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              TicketPriorityBadge(priority: ticket.priority, isCompact: true),
              const SizedBox(width: 8),
              Text(
                'Opened ${DateFormatter.formatRelative(ticket.createdAt)}',
                style: AppFonts.labelSmall(color: secondaryTextColor),
              ),
              if (isMerchant && ticket.customerPhone.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '• ${ticket.customerPhone}',
                  style: AppFonts.labelSmall(color: secondaryTextColor),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (ticket.garageName.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.garageName,
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              if (ticket.vehicleDisplay != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.vehicleDisplay!,
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              if (ticket.jobNumber != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.jobNumber!,
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
            ],
          ),
          if (ticket.resolutionComment != null &&
              ticket.resolutionComment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resolution: ${ticket.resolutionComment!}',
                      style: AppFonts.labelSmall(color: AppColors.success)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (isMerchant) ...[
                if (ticket.status == 'open' ||
                    ticket.status == 'waiting_for_merchant')
                  AppButton(
                    label: context.tr('commenceWork'),
                    height: 36,
                    fontSize: 12,
                    onPressed: () => notifier.updateStatus('in_progress'),
                  ),
                if (ticket.status != 'resolved' && ticket.status != 'closed')
                  AppButton(
                    label: context.tr('resolveTicket'),
                    height: 36,
                    fontSize: 12,
                    variant: AppButtonVariant.secondary,
                    onPressed: () async {
                      final comment = await TicketResolutionDialog.show(
                        context,
                        ticketNumber: ticket.ticketNumber,
                      );
                      if (comment != null) {
                        notifier.updateStatus(
                          'resolved',
                          resolutionComment: comment.isNotEmpty
                              ? comment
                              : null,
                        );
                      }
                    },
                  ),
                if (ticket.status == 'resolved')
                  AppButton(
                    label: context.tr('closeTicket'),
                    height: 36,
                    fontSize: 12,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => notifier.updateStatus('closed'),
                  ),
              ] else ...[
                if (ticket.canCustomerReopen)
                  AppButton(
                    label: context.tr('reopenTicket'),
                    height: 36,
                    fontSize: 12,
                    variant: AppButtonVariant.secondary,
                    onPressed: () async {
                      final comment = await TicketResolutionDialog.show(
                        context,
                        ticketNumber: ticket.ticketNumber,
                        isReopen: true,
                      );
                      if (comment != null) {
                        notifier.updateStatus(
                          'reopened',
                          resolutionComment: comment.isNotEmpty
                              ? comment
                              : null,
                        );
                      }
                    },
                  ),
                if (ticket.status == 'resolved')
                  AppButton(
                    label: context.tr('confirmResolution'),
                    height: 36,
                    fontSize: 12,
                    onPressed: () => notifier.updateStatus('closed'),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketDetailsViewModelProvider(widget.ticketId));
    final notifier = ref.read(
      ticketDetailsViewModelProvider(widget.ticketId).notifier,
    );
    final auth = ref.watch(authViewModelProvider);
    final user = auth.userProfile;
    final isMerchant = auth.activeExperience == 'merchant';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    if (state.isLoading) {
      return Scaffold(
        appBar: AppCustomAppBar(title: context.tr('ticketDetails')),
        body: const AppLoadingState(description: 'Loading ticket timeline...'),
      );
    }

    if (state.ticket == null) {
      return Scaffold(
        appBar: AppCustomAppBar(title: context.tr('ticketDetails')),
        body: AppErrorState(
          title: context.tr('ticketNotFound'),
          message:
              state.errorMessage ??
              'The requested support ticket does not exist.',
          onRetry: notifier.init,
        ),
      );
    }

    final ticket = state.ticket!;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppCustomAppBar(
        title: ticket.ticketNumber,
        subtitle: ticket.subject,
      ),
      body: Column(
        children: [
          _buildHeaderCard(context, ticket, isMerchant, notifier),
          Expanded(
            child: state.messages.isEmpty
                ? Center(
                    child: AppEmptyState(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: context.tr('noMessagesYet'),
                      description: context.tr('noMessagesDescription'),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == (user?.uid ?? '');
                      return TicketMessageBubble(message: msg, isMe: isMe);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: barBg,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isMerchant)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send_rounded, size: 14),
                                const SizedBox(width: 4),
                                Text(context.tr('replyToCustomer')),
                              ],
                            ),
                            selected: !state.isInternalMode,
                            onSelected: (_) =>
                                notifier.toggleInternalMode(false),
                            selectedColor: AppColors.primaryRed,
                            labelStyle: AppFonts.labelSmall(
                              color: !state.isInternalMode
                                  ? Colors.white
                                  : AppColors.textSecondaryLight,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_rounded, size: 14),
                                const SizedBox(width: 4),
                                Text(context.tr('internalNoteStaffOnly')),
                              ],
                            ),
                            selected: state.isInternalMode,
                            selectedColor: Colors.amber.shade800,
                            labelStyle: AppFonts.labelSmall(
                              color: state.isInternalMode
                                  ? Colors.white
                                  : AppColors.textSecondaryLight,
                            ).copyWith(fontWeight: FontWeight.bold),
                            onSelected: (_) =>
                                notifier.toggleInternalMode(true),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _messageController,
                          hint: state.isInternalMode
                              ? context.tr('writeInternalNoteHint')
                              : context.tr('typeYourMessage'),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: state.isInternalMode
                              ? Colors.amber.shade800
                              : AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: state.isSending ? null : _handleSend,
                        icon: state.isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
