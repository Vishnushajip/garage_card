import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/utils/debouncer.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages', style: AppFonts.titleLarge(color: primaryText)),
      ),
      body: AppResponsiveLayout(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppTextField(
                controller: _searchController,
                hint: 'Search messages and garages...',
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
                        final conv = state.filteredConversations[index];
                        final title = isMerchant
                            ? conv.customerName
                            : conv.garageName;
                        final unread = conv.unreadCountFor(currentUserId);

                        return ListTile(
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
                                  style: AppFonts.titleSmall(
                                    color: primaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (conv.lastMessageTime != null)
                                Text(
                                  DateFormatter.formatTime(
                                    conv.lastMessageTime!,
                                  ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  conversationId: conv.id,
                                  recipientName: title,
                                  subtitle: conv.serviceJobTitle,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
