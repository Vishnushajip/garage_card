import 'package:garage_card/features/shared/models/chat_message_model.dart';
import 'package:garage_card/features/shared/models/conversation_model.dart';

class ChatState {
  const ChatState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.errorMessage,
  });

  final ConversationModel? conversation;
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;

  ChatState copyWith({
    ConversationModel? conversation,
    List<ChatMessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? errorMessage,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
    );
  }
}
