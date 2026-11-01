import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/support/models/support_ticket_model.dart';
import 'package:garage_card/features/support/models/ticket_history_model.dart';
import 'package:garage_card/features/support/models/ticket_message_model.dart';
import 'package:garage_card/features/support/repositories/support_repository.dart';

class TicketDetailsState {
  const TicketDetailsState({
    this.isLoading = false,
    this.ticket,
    this.messages = const [],
    this.history = const [],
    this.isSending = false,
    this.isUpdatingStatus = false,
    this.isInternalMode = false,
    this.errorMessage,
  });

  final bool isLoading;
  final SupportTicketModel? ticket;
  final List<TicketMessageModel> messages;
  final List<TicketHistoryModel> history;
  final bool isSending;
  final bool isUpdatingStatus;
  final bool isInternalMode;
  final String? errorMessage;

  TicketDetailsState copyWith({
    bool? isLoading,
    SupportTicketModel? ticket,
    List<TicketMessageModel>? messages,
    List<TicketHistoryModel>? history,
    bool? isSending,
    bool? isUpdatingStatus,
    bool? isInternalMode,
    String? errorMessage,
  }) {
    return TicketDetailsState(
      isLoading: isLoading ?? this.isLoading,
      ticket: ticket ?? this.ticket,
      messages: messages ?? this.messages,
      history: history ?? this.history,
      isSending: isSending ?? this.isSending,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      isInternalMode: isInternalMode ?? this.isInternalMode,
      errorMessage: errorMessage,
    );
  }
}

class TicketDetailsViewModel extends Notifier<TicketDetailsState> {
  TicketDetailsViewModel(this.ticketId);

  final String ticketId;
  StreamSubscription<SupportTicketModel?>? _ticketSub;
  StreamSubscription<List<TicketMessageModel>>? _messagesSub;

  SupportRepository get _repository => ref.read(supportRepositoryProvider);

  @override
  TicketDetailsState build() {
    ref.onDispose(() {
      _ticketSub?.cancel();
      _messagesSub?.cancel();
    });

    Future.microtask(init);
    return const TicketDetailsState(isLoading: true);
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final auth = ref.read(authViewModelProvider);
    final isMerchant = auth.activeExperience == 'merchant';

    try {
      final initialTicket = await _repository.getTicketDetails(ticketId);
      final initialHistory = await _repository.getTicketHistory(ticketId);

      state = state.copyWith(
        isLoading: false,
        ticket: initialTicket,
        history: initialHistory,
      );

      _ticketSub?.cancel();
      _ticketSub = _repository.watchTicket(ticketId).listen((t) {
        if (t != null) {
          state = state.copyWith(ticket: t);
        }
      });

      _messagesSub?.cancel();
      _messagesSub = _repository
          .watchTicketMessages(ticketId, includeInternal: isMerchant)
          .listen((msgs) {
            state = state.copyWith(messages: msgs);
          });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load ticket details.',
      );
    }
  }

  void toggleInternalMode(bool value) {
    state = state.copyWith(isInternalMode: value);
  }

  Future<bool> sendReply(
    String text, {
    List<String> attachments = const [],
  }) async {
    if (text.trim().isEmpty && attachments.isEmpty) return false;

    final auth = ref.read(authViewModelProvider);
    final user = auth.userProfile;
    final isMerchant = auth.activeExperience == 'merchant';

    state = state.copyWith(isSending: true, errorMessage: null);

    try {
      final message = TicketMessageModel(
        id: '',
        ticketId: ticketId,
        senderId: user?.uid ?? '',
        senderName: user?.fullName ?? (isMerchant ? 'Merchant' : 'Customer'),
        senderRole: isMerchant ? 'merchant' : 'customer',
        message: text.trim(),
        attachments: attachments,
        isInternal: isMerchant && state.isInternalMode,
      );

      await _repository.sendMessage(ticketId, message);
      final updatedHistory = await _repository.getTicketHistory(ticketId);

      state = state.copyWith(
        isSending: false,
        isInternalMode: false,
        history: updatedHistory,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: 'Failed to send message. Please retry.',
      );
      return false;
    }
  }

  Future<bool> updateStatus(
    String newStatus, {
    String? resolutionComment,
  }) async {
    final auth = ref.read(authViewModelProvider);
    final user = auth.userProfile;
    final isMerchant = auth.activeExperience == 'merchant';

    state = state.copyWith(isUpdatingStatus: true, errorMessage: null);

    try {
      await _repository.updateTicketStatus(
        ticketId,
        newStatus,
        resolutionComment: resolutionComment,
        performedBy: user?.uid ?? '',
        performedByName:
            user?.fullName ?? (isMerchant ? 'Merchant Staff' : 'Customer'),
        performedByRole: isMerchant ? 'merchant' : 'customer',
      );

      final updatedTicket = await _repository.getTicketDetails(ticketId);
      final updatedHistory = await _repository.getTicketHistory(ticketId);

      state = state.copyWith(
        isUpdatingStatus: false,
        ticket: updatedTicket,
        history: updatedHistory,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        errorMessage: 'Failed to update ticket status.',
      );
      return false;
    }
  }

  Future<bool> updatePriority(String newPriority) async {
    final auth = ref.read(authViewModelProvider);
    final user = auth.userProfile;

    state = state.copyWith(isUpdatingStatus: true, errorMessage: null);

    try {
      await _repository.updateTicketPriority(
        ticketId,
        newPriority,
        performedBy: user?.uid ?? '',
        performedByName: user?.fullName ?? 'Merchant Staff',
      );

      final updatedTicket = await _repository.getTicketDetails(ticketId);
      final updatedHistory = await _repository.getTicketHistory(ticketId);

      state = state.copyWith(
        isUpdatingStatus: false,
        ticket: updatedTicket,
        history: updatedHistory,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        errorMessage: 'Failed to update ticket priority.',
      );
      return false;
    }
  }
}

final ticketDetailsViewModelProvider =
    NotifierProvider.family<TicketDetailsViewModel, TicketDetailsState, String>(
      TicketDetailsViewModel.new,
    );
