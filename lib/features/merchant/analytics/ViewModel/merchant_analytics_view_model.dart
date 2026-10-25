import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/notification_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Model/daily_todo_item_model.dart';
import '../Model/financial_metrics_model.dart';
import '../Model/merchant_analytics_state.dart';

class MerchantAnalyticsViewModel extends Notifier<MerchantAnalyticsState> {
  static const String _briefingPrefKey = 'merchant_last_briefing_date';

  @override
  MerchantAnalyticsState build() {
    Future.microtask(_loadAnalytics);
    return const MerchantAnalyticsState(isLoading: true);
  }

  Future<void> _loadAnalytics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = ref.read(garageRepositoryProvider);
      const garageId = 'garage_demo_1';

      final invoices = await repo.getInvoices(garageId: garageId, limit: 100);
      final jobs = await repo.getServiceJobs(garageId: garageId, limit: 100);
      final payments = await repo.getPayments(garageId: garageId, limit: 100);

      final now = DateTime.now();
      final dateRange = _calculateDateRange(
        state.selectedRange,
        now,
        state.customStartDate,
        state.customEndDate,
      );

      final metrics = _calculateFinancialMetrics(
        invoices: invoices,
        jobs: jobs,
        payments: payments,
        range: state.selectedRange,
        start: dateRange.$1,
        end: dateRange.$2,
        now: now,
      );

      final todoData = _buildDailyTodoAndPipeline(
        jobs: jobs,
        invoices: invoices,
        now: now,
      );

      final shouldShowBriefing = await _checkAndTriggerMorningBriefing(
        now: now,
        todayDeliveries: todoData.todayDeliveries,
        pendingDues: todoData.pendingDues,
      );

      state = state.copyWith(
        isLoading: false,
        metrics: metrics,
        todoItems: todoData.items,
        yesterdayCompletedCount: todoData.yesterdayCompleted,
        todayDeliveriesCount: todoData.todayDeliveries,
        todayPendingPaymentsCount: todoData.pendingDues,
        showMorningBriefing: shouldShowBriefing,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  (DateTime, DateTime) _calculateDateRange(
    AnalyticsTimeRange range,
    DateTime now,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (range) {
      case AnalyticsTimeRange.today:
        return (todayStart, todayEnd);
      case AnalyticsTimeRange.thisWeek:
        final monday = todayStart.subtract(Duration(days: now.weekday - 1));
        final sunday = monday.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return (monday, sunday);
      case AnalyticsTimeRange.thisMonth:
        final firstDay = DateTime(now.year, now.month, 1);
        final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (firstDay, lastDay);
      case AnalyticsTimeRange.thisYear:
        final firstDay = DateTime(now.year, 1, 1);
        final lastDay = DateTime(now.year, 12, 31, 23, 59, 59);
        return (firstDay, lastDay);
      case AnalyticsTimeRange.custom:
        final start =
            customStart ?? todayStart.subtract(const Duration(days: 7));
        final end = customEnd ?? todayEnd;
        return (start, end);
    }
  }

  FinancialMetricsModel _calculateFinancialMetrics({
    required List<InvoiceModel> invoices,
    required List<ServiceJobModel> jobs,
    required List<dynamic> payments,
    required AnalyticsTimeRange range,
    required DateTime start,
    required DateTime end,
    required DateTime now,
  }) {
    final filteredInvoices = invoices.where((inv) {
      final date = inv.issuedAt ?? inv.createdAt ?? now;
      return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    double gross = 0.0;
    double discounts = 0.0;
    double net = 0.0;
    double collected = 0.0;
    double balance = 0.0;
    double partsCost = 0.0;
    double laborCost = 0.0;

    for (final inv in filteredInvoices) {
      discounts += inv.discountAmount;
      net += inv.totalAmount;
      gross += (inv.totalAmount + inv.discountAmount);
      collected += inv.paidAmount;
      balance += inv.balanceDue;

      for (final item in inv.items) {
        if (item.type == 'part') {
          partsCost += (item.totalPrice * 0.65);
        } else {
          laborCost += (item.totalPrice * 0.40);
        }
      }
    }

    if (partsCost == 0.0 && laborCost == 0.0 && net > 0) {
      partsCost = net * 0.38;
      laborCost = net * 0.22;
    }

    final totalCost = partsCost + laborCost;
    final netProfit = collected - totalCost;
    final profitMargin = net > 0 ? (netProfit / net) * 100 : 0.0;

    final filteredJobs = jobs.where((j) {
      final date = j.createdAt ?? now;
      return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    final completedCount = filteredJobs
        .where((j) => j.status == 'completed')
        .length;
    final inProgressCount = filteredJobs
        .where((j) => j.status == 'inProgress')
        .length;
    final readyCount = filteredJobs
        .where((j) => j.status == 'readyForCollection')
        .length;
    final newCount = filteredJobs.where((j) => j.status == 'received').length;

    final chartPoints = _buildChartDataPoints(range, filteredInvoices, now);

    return FinancialMetricsModel(
      timeRange: range,
      startDate: start,
      endDate: end,
      grossBilled: gross,
      discountAdjustments: discounts,
      netBilled: net,
      totalCollected: collected,
      pendingBalance: balance,
      partsCost: partsCost,
      laborCost: laborCost,
      totalCost: totalCost,
      netProfit: netProfit,
      profitMargin: profitMargin,
      isProfit: netProfit >= 0,
      chartPoints: chartPoints,
      totalJobsCompleted: completedCount,
      totalJobsInProgress: inProgressCount,
      totalJobsReady: readyCount,
      totalNewJobs: newCount,
    );
  }

  List<ChartDataPoint> _buildChartDataPoints(
    AnalyticsTimeRange range,
    List<InvoiceModel> invoices,
    DateTime now,
  ) {
    if (range == AnalyticsTimeRange.today) {
      return [
        const ChartDataPoint(
          label: '9 AM',
          billed: 1200,
          collected: 1200,
          cost: 700,
          profit: 500,
        ),
        const ChartDataPoint(
          label: '12 PM',
          billed: 2500,
          collected: 2300,
          cost: 1300,
          profit: 1000,
        ),
        const ChartDataPoint(
          label: '3 PM',
          billed: 4600,
          collected: 2000,
          cost: 2600,
          profit: -600,
        ),
        const ChartDataPoint(
          label: '6 PM',
          billed: 1800,
          collected: 1800,
          cost: 950,
          profit: 850,
        ),
      ];
    }

    if (range == AnalyticsTimeRange.thisWeek) {
      return [
        const ChartDataPoint(
          label: 'Mon',
          billed: 4200,
          collected: 4200,
          cost: 2200,
          profit: 2000,
        ),
        const ChartDataPoint(
          label: 'Tue',
          billed: 6100,
          collected: 5500,
          cost: 3100,
          profit: 2400,
        ),
        const ChartDataPoint(
          label: 'Wed',
          billed: 8500,
          collected: 8150,
          cost: 4400,
          profit: 3750,
        ),
        const ChartDataPoint(
          label: 'Thu',
          billed: 3800,
          collected: 3800,
          cost: 2100,
          profit: 1700,
        ),
        const ChartDataPoint(
          label: 'Fri',
          billed: 1800,
          collected: 1800,
          cost: 900,
          profit: 900,
        ),
        const ChartDataPoint(
          label: 'Sat',
          billed: 7100,
          collected: 4300,
          cost: 3900,
          profit: 400,
        ),
        const ChartDataPoint(
          label: 'Sun',
          billed: 0,
          collected: 0,
          cost: 0,
          profit: 0,
        ),
      ];
    }

    if (range == AnalyticsTimeRange.thisYear) {
      return [
        const ChartDataPoint(
          label: 'Jan',
          billed: 48000,
          collected: 46000,
          cost: 26000,
          profit: 20000,
        ),
        const ChartDataPoint(
          label: 'Feb',
          billed: 52000,
          collected: 49000,
          cost: 28000,
          profit: 21000,
        ),
        const ChartDataPoint(
          label: 'Mar',
          billed: 68000,
          collected: 64000,
          cost: 34000,
          profit: 30000,
        ),
        const ChartDataPoint(
          label: 'Apr',
          billed: 61000,
          collected: 59000,
          cost: 31000,
          profit: 28000,
        ),
        const ChartDataPoint(
          label: 'May',
          billed: 57000,
          collected: 54000,
          cost: 29000,
          profit: 25000,
        ),
        const ChartDataPoint(
          label: 'Jun',
          billed: 73000,
          collected: 70000,
          cost: 37000,
          profit: 33000,
        ),
        const ChartDataPoint(
          label: 'Jul',
          billed: 69000,
          collected: 66000,
          cost: 35000,
          profit: 31000,
        ),
        const ChartDataPoint(
          label: 'Aug',
          billed: 82000,
          collected: 78000,
          cost: 41000,
          profit: 37000,
        ),
        const ChartDataPoint(
          label: 'Sep',
          billed: 88000,
          collected: 84000,
          cost: 45000,
          profit: 39000,
        ),
        const ChartDataPoint(
          label: 'Oct',
          billed: 45000,
          collected: 39950,
          cost: 23200,
          profit: 16750,
        ),
      ];
    }

    return [
      const ChartDataPoint(
        label: 'Week 1',
        billed: 18500,
        collected: 17200,
        cost: 9800,
        profit: 7400,
      ),
      const ChartDataPoint(
        label: 'Week 2',
        billed: 22400,
        collected: 21800,
        cost: 11600,
        profit: 10200,
      ),
      const ChartDataPoint(
        label: 'Week 3',
        billed: 19800,
        collected: 18900,
        cost: 10400,
        profit: 8500,
      ),
      const ChartDataPoint(
        label: 'Week 4',
        billed: 16000,
        collected: 12250,
        cost: 8900,
        profit: 3350,
      ),
    ];
  }

  _TodoBuildResult _buildDailyTodoAndPipeline({
    required List<ServiceJobModel> jobs,
    required List<InvoiceModel> invoices,
    required DateTime now,
  }) {
    final items = <DailyTodoItemModel>[];
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int yesterdayCompleted = 0;
    int todayDeliveries = 0;
    int pendingDues = 0;

    for (final job in jobs) {
      if (job.completedDate != null) {
        final comp = DateTime(
          job.completedDate!.year,
          job.completedDate!.month,
          job.completedDate!.day,
        );
        if (comp == yesterday) {
          yesterdayCompleted++;
          items.add(
            DailyTodoItemModel(
              id: 'todo_comp_${job.id}',
              jobId: job.id,
              vehicleDisplay: job.vehicleDisplay,
              customerName: job.customerName,
              customerPhone: '+91 98460 77112',
              type: TodoItemType.completedYesterday,
              title: '${job.vehicleDisplay} Completed Yesterday',
              subtitle:
                  'Technician: ${job.technicianName} • Ready for final feedback',
              isDone: true,
            ),
          );
        }
      }

      if (job.status != 'completed' && job.status != 'closed') {
        final isDueToday =
            job.estimatedCompletionDate != null &&
            (job.estimatedCompletionDate!.isBefore(
                  now.add(const Duration(hours: 12)),
                ) ||
                job.status == 'readyForCollection');

        if (isDueToday) {
          todayDeliveries++;
          items.add(
            DailyTodoItemModel(
              id: 'todo_deliv_${job.id}',
              jobId: job.id,
              vehicleDisplay: job.vehicleDisplay,
              customerName: job.customerName,
              customerPhone: '+91 98460 77112',
              type: TodoItemType.deliveryToday,
              title: 'Deliver ${job.vehicleDisplay}',
              subtitle: job.status == 'readyForCollection'
                  ? 'Vehicle ready in collection bay • Customer notified'
                  : 'Scheduled completion today: ${job.customerNotes.isNotEmpty ? job.customerNotes : "Final inspection"}',
              scheduledTime: 'Today by 5:00 PM',
              isDone: false,
            ),
          );
        }
      }
    }

    for (final inv in invoices) {
      if (inv.balanceDue > 0) {
        pendingDues++;
        items.add(
          DailyTodoItemModel(
            id: 'todo_pay_${inv.id}',
            invoiceId: inv.id,
            vehicleDisplay: 'Invoice ${inv.invoiceNumber}',
            customerName: 'Customer ${inv.customerId}',
            customerPhone: '+91 98460 77112',
            type: TodoItemType.paymentDue,
            title: 'Collect Balance Due: ₹${inv.balanceDue.toStringAsFixed(0)}',
            subtitle:
                'Total Billed: ₹${inv.totalAmount.toStringAsFixed(0)} • Paid: ₹${inv.paidAmount.toStringAsFixed(0)}',
            amount: inv.balanceDue,
            isDone: false,
          ),
        );
      }
    }

    return _TodoBuildResult(
      items: items,
      yesterdayCompleted: yesterdayCompleted,
      todayDeliveries: todayDeliveries,
      pendingDues: pendingDues,
    );
  }

  Future<bool> _checkAndTriggerMorningBriefing({
    required DateTime now,
    required int todayDeliveries,
    required int pendingDues,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = '${now.year}-${now.month}-${now.day}';
      final lastBriefing = prefs.getString(_briefingPrefKey);

      if (lastBriefing != todayStr) {
        await prefs.setString(_briefingPrefKey, todayStr);

        final notif = NotificationModel(
          id: const Uuid().v4(),
          recipientUid: 'merchant_demo_1',
          title: '🌅 Daily Operations Briefing',
          body:
              'Today: $todayDeliveries vehicle(s) scheduled for delivery. $pendingDues outstanding invoice balances to collect.',
          type: 'daily_briefing',
          referenceId: 'daily_ops',
          referenceType: 'analytics',
          isRead: false,
          createdAt: now,
        );
        await ref.read(garageRepositoryProvider).createNotification(notif);

        return true;
      }
    } catch (_) {}
    return false;
  }

  void setTimeRange(
    AnalyticsTimeRange range, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    state = state.copyWith(
      selectedRange: range,
      customStartDate: customStart,
      customEndDate: customEnd,
    );
    _loadAnalytics();
  }

  void toggleTodoItem(String todoId) {
    final updated = state.todoItems.map((item) {
      if (item.id == todoId) {
        return item.copyWith(isDone: !item.isDone);
      }
      return item;
    }).toList();
    state = state.copyWith(todoItems: updated);
  }

  void dismissMorningBriefing() {
    state = state.copyWith(showMorningBriefing: false);
  }

  Future<void> refresh() async {
    await _loadAnalytics();
  }
}

class _TodoBuildResult {
  const _TodoBuildResult({
    required this.items,
    required this.yesterdayCompleted,
    required this.todayDeliveries,
    required this.pendingDues,
  });

  final List<DailyTodoItemModel> items;
  final int yesterdayCompleted;
  final int todayDeliveries;
  final int pendingDues;
}

final merchantAnalyticsViewModelProvider =
    NotifierProvider<MerchantAnalyticsViewModel, MerchantAnalyticsState>(() {
      return MerchantAnalyticsViewModel();
    });
