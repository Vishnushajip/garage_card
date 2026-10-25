import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/features/merchant/analytics/Model/daily_todo_item_model.dart';
import 'package:garage_card/features/merchant/analytics/Model/financial_metrics_model.dart';

void main() {
  group('Merchant Analytics & Financial Models Tests', () {
    test('FinancialMetricsModel calculates profit and margin accurately', () {
      final now = DateTime.now();
      final metrics = FinancialMetricsModel(
        timeRange: AnalyticsTimeRange.today,
        startDate: now,
        endDate: now,
        grossBilled: 2500.0,
        discountAdjustments: 200.0,
        netBilled: 2300.0,
        totalCollected: 2300.0,
        pendingBalance: 0.0,
        partsCost: 1000.0,
        laborCost: 500.0,
        totalCost: 1500.0,
        netProfit: 800.0,
        profitMargin: (800.0 / 2300.0) * 100,
        isProfit: true,
        totalJobsCompleted: 1,
        totalJobsInProgress: 0,
        currencyCode: 'INR',
        chartPoints: const [
          ChartDataPoint(
            label: 'Today',
            billed: 2500.0,
            collected: 2300.0,
            cost: 1500.0,
            profit: 800.0,
          ),
        ],
      );

      expect(metrics.isProfit, isTrue);
      expect(metrics.netProfit, 800.0);
      expect(
        metrics.grossBilled - metrics.discountAdjustments,
        metrics.netBilled,
      );
      expect(metrics.profitMargin, closeTo(34.78, 0.01));
      expect(metrics.chartPoints.length, 1);
    });

    test('FinancialMetricsModel handles loss scenarios correctly', () {
      final now = DateTime.now();
      final lossMetrics = FinancialMetricsModel(
        timeRange: AnalyticsTimeRange.thisWeek,
        startDate: now,
        endDate: now,
        grossBilled: 1000.0,
        discountAdjustments: 200.0,
        netBilled: 800.0,
        totalCollected: 800.0,
        pendingBalance: 0.0,
        partsCost: 800.0,
        laborCost: 400.0,
        totalCost: 1200.0,
        netProfit: -400.0,
        profitMargin: (-400.0 / 800.0) * 100,
        isProfit: false,
        totalJobsCompleted: 1,
        totalJobsInProgress: 0,
        currencyCode: 'INR',
        chartPoints: const [],
      );

      expect(lossMetrics.isProfit, isFalse);
      expect(lossMetrics.netProfit, -400.0);
      expect(lossMetrics.profitMargin, -50.0);
    });

    test('DailyTodoItemModel copyWith toggles completion state', () {
      final item = DailyTodoItemModel(
        id: 'todo_1',
        title: 'Deliver Royal Enfield Himalayan',
        subtitle: 'Scheduled pickup at 4:00 PM',
        type: TodoItemType.deliveryToday,
        customerName: 'Kiran Kumar',
        customerPhone: '+919876543210',
        vehicleDisplay: 'Royal Enfield Himalayan (KL 07 DH 1122)',
        jobId: 'job_today_1',
        isDone: false,
        scheduledTime: '4:00 PM',
      );

      expect(item.isDone, isFalse);
      expect(item.type, TodoItemType.deliveryToday);

      final completedItem = item.copyWith(isDone: true);
      expect(completedItem.isDone, isTrue);
      expect(completedItem.id, 'todo_1');
      expect(completedItem.customerName, 'Kiran Kumar');
    });

    test('AnalyticsTimeRange values check', () {
      expect(AnalyticsTimeRange.values.length, 5);
      expect(
        AnalyticsTimeRange.values.contains(AnalyticsTimeRange.today),
        isTrue,
      );
      expect(
        AnalyticsTimeRange.values.contains(AnalyticsTimeRange.thisWeek),
        isTrue,
      );
      expect(
        AnalyticsTimeRange.values.contains(AnalyticsTimeRange.thisMonth),
        isTrue,
      );
      expect(
        AnalyticsTimeRange.values.contains(AnalyticsTimeRange.thisYear),
        isTrue,
      );
      expect(
        AnalyticsTimeRange.values.contains(AnalyticsTimeRange.custom),
        isTrue,
      );
    });
  });
}
