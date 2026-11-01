import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/support/models/support_ticket_model.dart';
import 'package:garage_card/features/support/repositories/support_repository.dart';

class CustomerSupportState {
  const CustomerSupportState({
    this.isLoading = false,
    this.tickets = const [],
    this.selectedStatus = 'all',
    this.selectedCategory = 'all',
    this.searchQuery = '',
    this.errorMessage,
  });

  final bool isLoading;
  final List<SupportTicketModel> tickets;
  final String selectedStatus;
  final String selectedCategory;
  final String searchQuery;
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

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase().trim();
      result = result.where((t) {
        return t.ticketNumber.toLowerCase().contains(q) ||
            t.subject.toLowerCase().contains(q) ||
            t.garageName.toLowerCase().contains(q) ||
            (t.vehicleDisplay?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  CustomerSupportState copyWith({
    bool? isLoading,
    List<SupportTicketModel>? tickets,
    String? selectedStatus,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return CustomerSupportState(
      isLoading: isLoading ?? this.isLoading,
      tickets: tickets ?? this.tickets,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class CustomerSupportViewModel extends Notifier<CustomerSupportState> {
  @override
  CustomerSupportState build() {
    Future.microtask(loadTickets);
    return const CustomerSupportState(isLoading: true);
  }

  SupportRepository get _repository => ref.read(supportRepositoryProvider);

  Future<void> loadTickets() async {
    final user = ref.read(authViewModelProvider).userProfile;
    final customerId = user?.uid ?? '';
    if (customerId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final tickets = await _repository.getCustomerTickets(customerId);
      state = state.copyWith(isLoading: false, tickets: tickets);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load support tickets. Please try again.',
      );
    }
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatus: status);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async {
    await loadTickets();
  }
}

final customerSupportViewModelProvider =
    NotifierProvider<CustomerSupportViewModel, CustomerSupportState>(
      CustomerSupportViewModel.new,
    );
