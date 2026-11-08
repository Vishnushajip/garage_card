class ServiceRecallItem {
  const ServiceRecallItem({
    required this.vehicleDisplay,
    required this.customerName,
    required this.customerPhone,
    required this.lastServiceDate,
    required this.daysSinceLastService,
    required this.lastJobNumber,
    this.lastComplaints = const [],
    this.estimatedOdometer = 0,
    required this.status,
  });

  final String vehicleDisplay;
  final String customerName;
  final String customerPhone;
  final DateTime lastServiceDate;
  final int daysSinceLastService;
  final String lastJobNumber;
  final List<String> lastComplaints;
  final int estimatedOdometer;
  final String status;

  bool get isOverdue => status == 'overdue';
  bool get isDueThisMonth => status == 'dueThisMonth';
  bool get isUpcoming => status == 'upcoming';
}

class ServiceRecallsState {
  const ServiceRecallsState({
    this.isLoading = false,
    this.items = const [],
    this.filterStatus = 'all',
    this.searchQuery = '',
    this.errorMessage,
  });

  final bool isLoading;
  final List<ServiceRecallItem> items;
  final String filterStatus;
  final String searchQuery;
  final String? errorMessage;

  int get totalRecalls => items.length;
  int get overdueCount => items.where((i) => i.isOverdue).length;
  int get dueThisMonthCount => items.where((i) => i.isDueThisMonth).length;

  List<ServiceRecallItem> get filteredItems {
    var list = items;
    if (filterStatus != 'all') {
      list = list.where((i) => i.status == filterStatus).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((i) {
        return i.vehicleDisplay.toLowerCase().contains(q) ||
            i.customerName.toLowerCase().contains(q) ||
            i.customerPhone.contains(q);
      }).toList();
    }
    return list;
  }

  ServiceRecallsState copyWith({
    bool? isLoading,
    List<ServiceRecallItem>? items,
    String? filterStatus,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ServiceRecallsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}
