import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/chat_state.dart';

class ChatViewModel extends Notifier<ChatState> {
  ChatViewModel(this.conversationId);

  final String conversationId;
  late final GarageRepository _repo;
  StreamSubscription? _msgSub;

  @override
  ChatState build() {
    _repo = ref.watch(garageRepositoryProvider);
    _initChat(conversationId);
    ref.onDispose(() {
      _msgSub?.cancel();
    });
    return const ChatState(isLoading: true);
  }

  void _initChat(String targetConvId) {
    final authState = ref.read(authViewModelProvider);
    final isMerchant = authState.activeExperience == 'merchant';

    _repo.markConversationRead(targetConvId, isMerchant: isMerchant);

    _msgSub?.cancel();
    _msgSub = _repo
        .streamConversationMessages(targetConvId)
        .listen(
          (messages) {
            state = state.copyWith(messages: messages, isLoading: false);
          },
          onError: (err) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Unable to stream chat messages: $err',
            );
          },
        );
  }

  Future<void> sendMessage(String text, {String? attachmentUrl}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && attachmentUrl == null) return;

    final authState = ref.read(authViewModelProvider);
    final senderId = authState.userProfile?.uid ?? 'user_1';
    final isMerchant = authState.activeExperience == 'merchant';
    final role = isMerchant ? 'merchant' : 'customer';

    state = state.copyWith(isSending: true);
    try {
      await _repo.sendChatMessage(
        conversationId: conversationId,
        senderId: senderId,
        senderRole: role,
        text: trimmed,
        attachmentUrl: attachmentUrl,
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Failed to send message: $e',
      );
    }
  }
}

final chatViewModelProvider =
    NotifierProvider.family<ChatViewModel, ChatState, String>(
      ChatViewModel.new,
    );
