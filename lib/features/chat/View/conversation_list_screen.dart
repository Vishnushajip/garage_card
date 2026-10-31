import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/utils/debouncer.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/conversation_model.dart';

import '../ViewModel/conversation_list_view_model.dart';
import 'chat_screen.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 300));

  String? _selectedConversationId;
  String _selectedName = '';
  String? _selectedPhone;
  String? _selectedSubtitle;

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationListViewModelProvider);
    final vm = ref.read(conversationListViewModelProvider.notifier);
    final authState = ref.watch(authViewModelProvider);
    final isMerchant = authState.activeExperience == 'merchant';
    final currentUserId = authState.userProfile?.uid ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: const AppCustomAppBar(title: 'Messages'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMasterDetail = constraints.maxWidth >= 768;

          if (isMasterDetail &&
              _selectedConversationId == null &&
              state.filteredConversations.isNotEmpty) {
            final first = state.filteredConversations.first;
            _selectedConversationId = first.id;
            _selectedName = isMerchant ? first.customerName : first.garageName;
            _selectedPhone = isMerchant
                ? first.customerPhone
                : first.garagePhone;
            _selectedSubtitle = first.serviceJobTitle;
          }

          if (isMasterDetail) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth >= 1100 ? 380 : 320,
                  child: _buildListPane(
                    state: state,
                    vm: vm,
                    isMerchant: isMerchant,
                    currentUserId: currentUserId,
                    primaryText: primaryText,
                    secondaryText: secondaryText,
                    isMasterDetail: true,
                  ),
                ),
                VerticalDivider(width: 1, thickness: 1, color: borderColor),
                Expanded(
                  child: _selectedConversationId != null
                      ? ChatScreen(
                          key: ValueKey(_selectedConversationId),
                          conversationId: _selectedConversationId!,
                          recipientName: _selectedName,
                          recipientPhone: _selectedPhone,
                          subtitle: _selectedSubtitle,
                          isEmbedded: true,
                        )
                      : _buildEmptyDetailPlaceholder(
                          primaryText,
                          secondaryText,
                        ),
                ),
              ],
            );
          }

          return _buildListPane(
            state: state,
            vm: vm,
            isMerchant: isMerchant,
            currentUserId: currentUserId,
            primaryText: primaryText,
            secondaryText: secondaryText,
            isMasterDetail: false,
          );
        },
      ),
    );
  }

  Widget _buildListPane({
    required dynamic state,
    required dynamic vm,
    required bool isMerchant,
    required String currentUserId,
    required Color primaryText,
    required Color secondaryText,
    required bool isMasterDetail,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AppTextField(
            controller: _searchController,
            hint: 'Search messages...',
            prefixIcon: const Icon(Icons.search_rounded),
            onChanged: (val) => _debouncer.run(() => vm.search(val)),
          ),
        ),
        Expanded(
          child: state.isLoading && state.conversations.isEmpty
              ? const Center(child: AppLoading())
              : state.filteredConversations.isEmpty
              ? const Center(
                  child: AppEmptyState(
                    title: 'No Conversations',
                    message: 'When you enquire about a service or repair, your chats will appear here.',
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                )
              : ListView.separated(
                  itemCount: state.filteredConversations.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (ctx, index) {
                    final ConversationModel conv =
                        state.filteredConversations[index];
                    final title = isMerchant
                        ? conv.customerName
                        : conv.garageName;
                    final unread = conv.unreadCountFor(currentUserId);
                    final isSelected =
                        isMasterDetail && _selectedConversationId == conv.id;

                    return Container(
                      color: isSelected
                          ? AppColors.primaryRed.withValues(alpha: 0.08)
                          : null,
                      child: ListTile(
                        selected: isSelected,
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryRed.withValues(
                            alpha: 0.12,
                          ),
                          child: Text(
                            title.isNotEmpty ? title[0].toUpperCase() : '?',
                            style: AppFonts.titleMedium(
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: AppFonts.titleSmall(color: primaryText)
                                    .copyWith(
                                      fontWeight: isSelected || unread > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conv.lastMessageTime != null)
                              Text(
                                DateFormatter.formatTime(conv.lastMessageTime!),
                                style: AppFonts.labelSmall(
                                  color: unread > 0
                                      ? AppColors.primaryRed
                                      : secondaryText,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: Text(
                                conv.lastMessage.isNotEmpty
                                    ? conv.lastMessage
                                    : 'Tap to open chat',
                                style: AppFonts.bodySmall(
                                  color: unread > 0
                                      ? primaryText
                                      : secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unread > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$unread',
                                  style: AppFonts.labelSmall(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          final phone = isMerchant
                              ? conv.customerPhone
                              : conv.garagePhone;
                          if (isMasterDetail) {
                            setState(() {
                              _selectedConversationId = conv.id;
                              _selectedName = title;
                              _selectedPhone = phone;
                              _selectedSubtitle = conv.serviceJobTitle;
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  conversationId: conv.id,
                                  recipientName: title,
                                  recipientPhone: phone,
                                  subtitle: conv.serviceJobTitle,
                                  isEmbedded: false,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyDetailPlaceholder(Color primaryText, Color secondaryText) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              size: 56,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a conversation',
            style: AppFonts.titleMedium(color: primaryText),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose an inquiry or service conversation to view messages.',
            style: AppFonts.bodySmall(color: secondaryText),
          ),
        ],
      ),
    );
  }
}
