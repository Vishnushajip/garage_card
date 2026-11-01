import 'package:garage_card/features/shared/models/invoice_model.dart';

import 'daily_todo_item_model.dart';
import 'financial_metrics_model.dart';

class MerchantAnalyticsState {
  const MerchantAnalyticsState({
    this.selectedRange = AnalyticsTimeRange.thisMonth,
    this.customStartDate,
    this.customEndDate,
    this.metrics,
    this.filteredInvoices = const [],
    this.todoItems = const [],
    this.yesterdayCompletedCount = 0,
    this.todayDeliveriesCount = 0,
    this.todayPendingPaymentsCount = 0,
    this.showMorningBriefing = false,
    this.isLoading = true,
    this.errorMessage,
  });

  final AnalyticsTimeRange selectedRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final FinancialMetricsModel? metrics;
  final List<InvoiceModel> filteredInvoices;
  final List<DailyTodoItemModel> todoItems;
  final int yesterdayCompletedCount;
  final int todayDeliveriesCount;
  final int todayPendingPaymentsCount;
  final bool showMorningBriefing;
  final bool isLoading;
  final String? errorMessage;

  MerchantAnalyticsState copyWith({
    AnalyticsTimeRange? selectedRange,
    DateTime? customStartDate,
    DateTime? customEndDate,
    FinancialMetricsModel? metrics,
    List<InvoiceModel>? filteredInvoices,
    List<DailyTodoItemModel>? todoItems,
    int? yesterdayCompletedCount,
    int? todayDeliveriesCount,
    int? todayPendingPaymentsCount,
    bool? showMorningBriefing,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MerchantAnalyticsState(
      selectedRange: selectedRange ?? this.selectedRange,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      metrics: metrics ?? this.metrics,
      filteredInvoices: filteredInvoices ?? this.filteredInvoices,
      todoItems: todoItems ?? this.todoItems,
      yesterdayCompletedCount:
          yesterdayCompletedCount ?? this.yesterdayCompletedCount,
      todayDeliveriesCount: todayDeliveriesCount ?? this.todayDeliveriesCount,
      todayPendingPaymentsCount:
          todayPendingPaymentsCount ?? this.todayPendingPaymentsCount,
      showMorningBriefing: showMorningBriefing ?? this.showMorningBriefing,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
