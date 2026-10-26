import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/conversation_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

class ConversationListState {
  const ConversationListState({
    this.conversations = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final List<ConversationModel> conversations;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  List<ConversationModel> get filteredConversations {
    if (searchQuery.trim().isEmpty) {
      return conversations;
    }
    final q = searchQuery.toLowerCase();
    return conversations.where((c) {
      return c.garageName.toLowerCase().contains(q) ||
          c.customerName.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  ConversationListState copyWith({
    List<ConversationModel>? conversations,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ConversationListViewModel extends Notifier<ConversationListState> {
  late final GarageRepository _repo;
  StreamSubscription? _sub;

  @override
  ConversationListState build() {
    _repo = ref.watch(garageRepositoryProvider);
    _initStream();
    ref.onDispose(() {
      _sub?.cancel();
    });
    return const ConversationListState(isLoading: true);
  }

  void _initStream() {
    final authState = ref.read(authViewModelProvider);
    final user = authState.userProfile;
    if (user == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final isMerchant = authState.activeExperience == 'merchant';
    final userId = isMerchant
        ? (user.garageId != null && user.garageId!.isNotEmpty
              ? user.garageId!
              : user.uid)
        : user.uid;

    _sub?.cancel();
    _sub = _repo
        .streamUserConversations(userId, isMerchant: isMerchant)
        .listen(
          (convs) {
            state = state.copyWith(conversations: convs, isLoading: false);
          },
          onError: (err) {
            state = state.copyWith(
              isLoading: false,
              errorMessage: 'Unable to stream conversations: $err',
            );
          },
        );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final conversationListViewModelProvider =
    NotifierProvider<ConversationListViewModel, ConversationListState>(
      ConversationListViewModel.new,
    );
