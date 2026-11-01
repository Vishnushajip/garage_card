import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
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
      final user = ref.read(authViewModelProvider).userProfile;
      final repo = ref.read(garageRepositoryProvider);
      var garageId = (user?.garageId != null && user!.garageId!.isNotEmpty)
          ? user.garageId!
          : '';

      if (garageId.isEmpty && user != null && user.uid.isNotEmpty) {
        final garage = await repo.getGarageByOwnerUid(user.uid);
        if (garage != null) {
          garageId = garage.id;
        }
      }

      final results = await Future.wait([
        repo.getInvoices(garageId: garageId, limit: 200),
        repo.getServiceJobs(garageId: garageId, limit: 200),
        repo.getPayments(garageId: garageId, limit: 200),
      ]);

      final allInvoices = results[0] as List<InvoiceModel>;
      final allJobs = results[1] as List<ServiceJobModel>;
      final payments = results[2];

      final now = DateTime.now();
      final dateRange = _calculateDateRange(
        state.selectedRange,
        now,
        state.customStartDate,
        state.customEndDate,
      );

      final start = dateRange.$1;
      final end = dateRange.$2;

      final filteredInvoices = allInvoices.where((inv) {
        final date = inv.issuedAt ?? inv.createdAt ?? now;
        return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
            (date.isBefore(end) || date.isAtSameMomentAs(end));
      }).toList();

      final metrics = _calculateFinancialMetrics(
        invoices: filteredInvoices,
        jobs: allJobs,
        payments: payments,
        range: state.selectedRange,
        start: start,
        end: end,
        now: now,
      );

      final todoData = _buildDailyTodoAndPipeline(
        jobs: allJobs,
        invoices: filteredInvoices,
        now: now,
      );

      state = state.copyWith(
        isLoading: false,
        metrics: metrics,
        filteredInvoices: filteredInvoices,
        todoItems: todoData.items,
        yesterdayCompletedCount: todoData.yesterdayCompleted,
        todayDeliveriesCount: todoData.todayDeliveries,
        todayPendingPaymentsCount: todoData.pendingDues,
        showMorningBriefing: false,
      );

      _checkAndTriggerMorningBriefing(
        now: now,
        userUid: user?.uid ?? '',
        todayDeliveries: todoData.todayDeliveries,
        pendingDues: todoData.pendingDues,
      ).then((shouldShow) {
        if (shouldShow) {
          state = state.copyWith(showMorningBriefing: true);
        }
      });
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
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(end.year, end.month, end.day, 23, 59, 59),
        );
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
    double gross = 0.0;
    double discounts = 0.0;
    double net = 0.0;
    double collected = 0.0;
    double balance = 0.0;
    double partsCost = 0.0;
    double laborCost = 0.0;

    for (final inv in invoices) {
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
      return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
          (date.isBefore(end) || date.isAtSameMomentAs(end));
    }).toList();

    final completedCount = filteredJobs
        .where((j) => j.isCompletedRepair)
        .length;
    final inProgressCount = filteredJobs
        .where(
          (j) =>
              j.status.toLowerCase() == 'in_progress' ||
              j.status.toLowerCase() == 'inprogress',
        )
        .length;
    final readyCount = filteredJobs
        .where(
          (j) =>
              j.status.toLowerCase() == 'readyforcollection' ||
              j.status.toLowerCase() == 'ready_for_collection',
        )
        .length;
    final newCount = filteredJobs.where((j) => j.isPendingRequest).length;

    final chartPoints = _buildChartDataPoints(range, invoices, now, start, end);

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
    DateTime start,
    DateTime end,
  ) {
    switch (range) {
      case AnalyticsTimeRange.today:
        final slots = [
          ('9 AM', 0, 9),
          ('12 PM', 9, 12),
          ('3 PM', 12, 15),
          ('6 PM', 15, 18),
          ('9 PM', 18, 24),
        ];
        return slots.map((slot) {
          final slotInvoices = invoices.where((inv) {
            final d = inv.issuedAt ?? inv.createdAt ?? now;
            return d.hour >= slot.$2 && d.hour < slot.$3;
          }).toList();
          double billed = 0.0;
          double collected = 0.0;
          double cost = 0.0;
          for (final inv in slotInvoices) {
            billed += (inv.totalAmount + inv.discountAmount);
            collected += inv.paidAmount;
            cost += _computeInvoiceCost(inv);
          }
          return ChartDataPoint(
            label: slot.$1,
            billed: billed,
            collected: collected,
            cost: cost,
            profit: collected - cost,
          );
        }).toList();

      case AnalyticsTimeRange.thisWeek:
        final weekStart = start;
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return List.generate(7, (i) {
          final currentDay = weekStart.add(Duration(days: i));
          final dayInvoices = invoices.where((inv) {
            final d = inv.issuedAt ?? inv.createdAt ?? now;
            return d.year == currentDay.year &&
                d.month == currentDay.month &&
                d.day == currentDay.day;
          }).toList();
          double billed = 0.0;
          double collected = 0.0;
          double cost = 0.0;
          for (final inv in dayInvoices) {
            billed += (inv.totalAmount + inv.discountAmount);
            collected += inv.paidAmount;
            cost += _computeInvoiceCost(inv);
          }
          return ChartDataPoint(
            label: days[i],
            billed: billed,
            collected: collected,
            cost: cost,
            profit: collected - cost,
          );
        });

      case AnalyticsTimeRange.thisMonth:
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final weeks = <(String, int, int)>[
          ('Week 1', 1, 7),
          ('Week 2', 8, 14),
          ('Week 3', 15, 21),
          ('Week 4', 22, 28),
          if (daysInMonth > 28) ('Week 5', 29, daysInMonth),
        ];
        return weeks.map((w) {
          final weekInvoices = invoices.where((inv) {
            final d = inv.issuedAt ?? inv.createdAt ?? now;
            return d.year == now.year &&
                d.month == now.month &&
                d.day >= w.$2 &&
                d.day <= w.$3;
          }).toList();
          double billed = 0.0;
          double collected = 0.0;
          double cost = 0.0;
          for (final inv in weekInvoices) {
            billed += (inv.totalAmount + inv.discountAmount);
            collected += inv.paidAmount;
            cost += _computeInvoiceCost(inv);
          }
          return ChartDataPoint(
            label: w.$1,
            billed: billed,
            collected: collected,
            cost: cost,
            profit: collected - cost,
          );
        }).toList();

      case AnalyticsTimeRange.thisYear:
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return List.generate(12, (i) {
          final monthIndex = i + 1;
          final monthInvoices = invoices.where((inv) {
            final d = inv.issuedAt ?? inv.createdAt ?? now;
            return d.year == now.year && d.month == monthIndex;
          }).toList();
          double billed = 0.0;
          double collected = 0.0;
          double cost = 0.0;
          for (final inv in monthInvoices) {
            billed += (inv.totalAmount + inv.discountAmount);
            collected += inv.paidAmount;
            cost += _computeInvoiceCost(inv);
          }
          return ChartDataPoint(
            label: months[i],
            billed: billed,
            collected: collected,
            cost: cost,
            profit: collected - cost,
          );
        });

      case AnalyticsTimeRange.custom:
        final diffDays = end.difference(start).inDays + 1;
        if (diffDays <= 7) {
          return List.generate(diffDays, (i) {
            final day = start.add(Duration(days: i));
            final dayInvoices = invoices.where((inv) {
              final d = inv.issuedAt ?? inv.createdAt ?? now;
              return d.year == day.year &&
                  d.month == day.month &&
                  d.day == day.day;
            }).toList();
            double billed = 0.0;
            double collected = 0.0;
            double cost = 0.0;
            for (final inv in dayInvoices) {
              billed += (inv.totalAmount + inv.discountAmount);
              collected += inv.paidAmount;
              cost += _computeInvoiceCost(inv);
            }
            return ChartDataPoint(
              label: '${day.day}/${day.month}',
              billed: billed,
              collected: collected,
              cost: cost,
              profit: collected - cost,
            );
          });
        } else {
          const bucketCount = 4;
          final bucketDuration = diffDays / bucketCount;
          return List.generate(bucketCount, (i) {
            final bStart = start.add(
              Duration(days: (i * bucketDuration).floor()),
            );
            final bEnd = start.add(
              Duration(days: (((i + 1) * bucketDuration).floor()) - 1),
            );
            final bInvoices = invoices.where((inv) {
              final d = inv.issuedAt ?? inv.createdAt ?? now;
              return !d.isBefore(bStart) &&
                  !d.isAfter(bEnd.add(const Duration(days: 1)));
            }).toList();
            double billed = 0.0;
            double collected = 0.0;
            double cost = 0.0;
            for (final inv in bInvoices) {
              billed += (inv.totalAmount + inv.discountAmount);
              collected += inv.paidAmount;
              cost += _computeInvoiceCost(inv);
            }
            return ChartDataPoint(
              label:
                  '${bStart.day}/${bStart.month} - ${bEnd.day}/${bEnd.month}',
              billed: billed,
              collected: collected,
              cost: cost,
              profit: collected - cost,
            );
          });
        }
    }
  }

  double _computeInvoiceCost(InvoiceModel inv) {
    double cost = 0.0;
    for (final item in inv.items) {
      if (item.type == 'part') {
        cost += (item.totalPrice * 0.65);
      } else {
        cost += (item.totalPrice * 0.40);
      }
    }
    if (cost == 0.0 && inv.totalAmount > 0) {
      cost = inv.totalAmount * 0.60;
    }
    return cost;
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
              customerPhone: job.customerPhone,
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
              customerPhone: job.customerPhone,
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
            customerName: inv.customerId.isNotEmpty
                ? 'Customer ${inv.customerId}'
                : '',
            customerPhone: '',
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
    required String userUid,
    required int todayDeliveries,
    required int pendingDues,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = '${now.year}-${now.month}-${now.day}';
      final lastBriefing = prefs.getString(_briefingPrefKey);

      if (lastBriefing != todayStr && userUid.isNotEmpty) {
        await prefs.setString(_briefingPrefKey, todayStr);

        final istNow = now.toUtc().add(const Duration(hours: 5, minutes: 30));
        final h = istNow.hour;
        final String briefingTitle;
        if (h >= 5 && h < 12) {
          briefingTitle = '🌅 Morning Operations Briefing';
        } else if (h >= 12 && h < 17) {
          briefingTitle = '☀️ Afternoon Operations Briefing';
        } else if (h >= 17 && h < 21) {
          briefingTitle = '🌆 Evening Operations Briefing';
        } else {
          briefingTitle = '🌙 Night Operations Briefing';
        }

        final notif = NotificationModel(
          id: const Uuid().v4(),
          recipientUid: userUid,
          title: briefingTitle,
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
