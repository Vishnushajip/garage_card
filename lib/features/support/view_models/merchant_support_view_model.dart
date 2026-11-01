import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/support/models/support_ticket_model.dart';
import 'package:garage_card/features/support/models/ticket_stats_model.dart';
import 'package:garage_card/features/support/repositories/support_repository.dart';

class MerchantSupportState {
  const MerchantSupportState({
    this.isLoading = false,
    this.stats = const TicketStatsModel(),
    this.tickets = const [],
    this.selectedStatus = 'all',
    this.selectedCategory = 'all',
    this.selectedPriority = 'all',
    this.searchQuery = '',
    this.garageId = '',
    this.errorMessage,
  });

  final bool isLoading;
  final TicketStatsModel stats;
  final List<SupportTicketModel> tickets;
  final String selectedStatus;
  final String selectedCategory;
  final String selectedPriority;
  final String searchQuery;
  final String garageId;
  final String? errorMessage;

  List<SupportTicketModel> get filteredTickets {
    var result = tickets;

    if (selectedStatus != 'all') {
      if (selectedStatus == 'active') {
        result = result
            .where((t) => t.status != 'resolved' && t.status != 'closed')
            .toList();
      } else {
        result = result.where((t) => t.status == selectedStatus).toList();
      }
    }

    if (selectedCategory != 'all') {
      result = result.where((t) => t.category == selectedCategory).toList();
    }

    if (selectedPriority != 'all') {
      result = result.where((t) => t.priority == selectedPriority).toList();
    }

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((t) {
        return t.ticketNumber.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.customerName.toLowerCase().contains(q) ||
            (t.vehiclePlate?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  MerchantSupportState copyWith({
    bool? isLoading,
    TicketStatsModel? stats,
    List<SupportTicketModel>? tickets,
    String? selectedStatus,
    String? selectedCategory,
    String? selectedPriority,
    String? searchQuery,
    String? garageId,
    String? errorMessage,
  }) {
    return MerchantSupportState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      tickets: tickets ?? this.tickets,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      searchQuery: searchQuery ?? this.searchQuery,
      garageId: garageId ?? this.garageId,
      errorMessage: errorMessage,
    );
  }
}

class MerchantSupportViewModel extends Notifier<MerchantSupportState> {
  @override
  MerchantSupportState build() {
    Future.microtask(initFromMerchantContext);
    return const MerchantSupportState(isLoading: true);
  }

  SupportRepository get _repository => ref.read(supportRepositoryProvider);

  void initFromMerchantContext() {
    final dashState = ref.read(merchantDashboardViewModelProvider);
    final garageId = dashState.garage?.id ?? '';
    if (garageId.isNotEmpty) {
      loadTickets(garageId);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadTickets(String garageId) async {
    if (garageId.isEmpty) return;

    state = state.copyWith(
      isLoading: true,
      garageId: garageId,
      errorMessage: null,
    );

    try {
      final results = await Future.wait([
        _repository.getMerchantTickets(garageId),
        _repository.calculateMerchantTicketStats(garageId),
      ]);

      final tickets = results[0] as List<SupportTicketModel>;
      final stats = results[1] as TicketStatsModel;

      state = state.copyWith(isLoading: false, tickets: tickets, stats: stats);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load merchant support tickets.',
      );
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatus: status);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setPriorityFilter(String priority) {
    state = state.copyWith(selectedPriority: priority);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async {
    if (state.garageId.isNotEmpty) {
      await loadTickets(state.garageId);
    } else {
      initFromMerchantContext();
    }
  }
}

final merchantSupportViewModelProvider =
    NotifierProvider<MerchantSupportViewModel, MerchantSupportState>(
      MerchantSupportViewModel.new,
    );
