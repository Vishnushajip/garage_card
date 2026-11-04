import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';

enum _AnalyticsFilter { today, thisWeek, thisMonth, custom }

class JobsAnalyticsView extends ConsumerStatefulWidget {
  const JobsAnalyticsView({super.key});

  @override
  ConsumerState<JobsAnalyticsView> createState() => _JobsAnalyticsViewState();
}

class _JobsAnalyticsViewState extends ConsumerState<JobsAnalyticsView> {
  _AnalyticsFilter _filter = _AnalyticsFilter.thisMonth;
  DateTimeRange? _customRange;

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    switch (_filter) {
      case _AnalyticsFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case _AnalyticsFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeek = DateTime(start.year, start.month, start.day);
        final endOfWeek = DateTime(
          start.year,
          start.month,
          start.day + 6,
          23,
          59,
          59,
        );
        return DateTimeRange(start: startOfWeek, end: endOfWeek);
      case _AnalyticsFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: startOfMonth, end: endOfMonth);
      case _AnalyticsFilter.custom:
        return _customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            );
    }
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customRange ?? _getDateRange(),
    );
    if (picked != null) {
      setState(() {
        _filter = _AnalyticsFilter.custom;
        _customRange = picked;
      });
    }
  }

  bool _isDateInRange(DateTime? date, DateTimeRange range) {
    if (date == null) return false;
    return date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
        date.isBefore(range.end.add(const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantJobsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final dateRange = _getDateRange();

    final filteredJobs = state.jobs.where((j) {
      final d = j.completedDate ?? j.createdAt;
      return _isDateInRange(d, dateRange);
    }).toList();

    final filteredInvoices = state.invoices.where((inv) {
      final d = inv.issuedAt ?? inv.createdAt;
      return _isDateInRange(d, dateRange);
    }).toList();

    int totalJobs = filteredJobs.length;
    int pendingJobs = 0;
    int inProgressJobs = 0;
    int completedJobs = 0;

    for (final j in filteredJobs) {
      final s = j.status.toLowerCase();
      if (s == 'completed' || s == 'closed' || s == 'delivered') {
        completedJobs++;
      } else if (s == 'in_progress' ||
          s == 'inprogress' ||
          s == 'awaiting_parts' ||
          s == 'readyforcollection') {
        inProgressJobs++;
      } else {
        pendingJobs++;
      }
    }

    double totalBilled = 0.0;
    double totalCollected = 0.0;
    double totalOutstanding = 0.0;
    double totalDiscounts = 0.0;
    double partsRevenue = 0.0;
    double partsExpenditure = 0.0;
    double laborRevenue = 0.0;
    double extraWorkRevenue = 0.0;

    for (final inv in filteredInvoices) {
      totalBilled += inv.totalAmount;
      totalCollected += inv.paidAmount;
      totalOutstanding += inv.balanceDue;
      totalDiscounts += inv.discountAmount;

      for (final item in inv.items) {
        if (item.type.toLowerCase() == 'part') {
          partsRevenue += item.totalPrice;
          partsExpenditure += item.totalPurchaseCost;
        } else if (item.type.toLowerCase() == 'labor' ||
            item.type.toLowerCase() == 'labour') {
          laborRevenue += item.totalPrice;
        } else if (item.type.toLowerCase() == 'extra' ||
            item.type.toLowerCase() == 'supplemental') {
          extraWorkRevenue += item.totalPrice;
        }
      }
    }

    final partsMargin = partsRevenue - partsExpenditure;
    final estimatedGarageMargin = partsMargin + laborRevenue + extraWorkRevenue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Today'),
                selected: _filter == _AnalyticsFilter.today,
                onSelected: (val) {
                  if (val) setState(() => _filter = _AnalyticsFilter.today);
                },
              ),
              ChoiceChip(
                label: const Text('This Week'),
                selected: _filter == _AnalyticsFilter.thisWeek,
                onSelected: (val) {
                  if (val) setState(() => _filter = _AnalyticsFilter.thisWeek);
                },
              ),
              ChoiceChip(
                label: const Text('This Month'),
                selected: _filter == _AnalyticsFilter.thisMonth,
                onSelected: (val) {
                  if (val) setState(() => _filter = _AnalyticsFilter.thisMonth);
                },
              ),
              ActionChip(
                avatar: const Icon(Icons.date_range_rounded, size: 16),
                label: Text(
                  _filter == _AnalyticsFilter.custom
                      ? '${DateFormatter.formatGarageDate(dateRange.start)} - ${DateFormatter.formatGarageDate(dateRange.end)}'
                      : 'Custom Range',
                ),
                onPressed: _pickCustomRange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Job Statistics (${DateFormatter.formatGarageDate(dateRange.start)} - ${DateFormatter.formatGarageDate(dateRange.end)})',
            style: AppFonts.titleMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final crossAxisCount = isNarrow ? 2 : 4;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: isNarrow ? 1.5 : 1.7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricTile(
                    label: 'Total Jobs',
                    value: '$totalJobs',
                    color: AppColors.accentBlue,
                    icon: Icons.assignment_rounded,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                  _buildMetricTile(
                    label: 'Pending',
                    value: '$pendingJobs',
                    color: AppColors.accentAmber,
                    icon: Icons.hourglass_top_rounded,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                  _buildMetricTile(
                    label: 'In Progress',
                    value: '$inProgressJobs',
                    color: AppColors.accentBlue,
                    icon: Icons.build_circle_rounded,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                  _buildMetricTile(
                    label: 'Completed',
                    value: '$completedJobs',
                    color: AppColors.success,
                    icon: Icons.check_circle_rounded,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Revenue & Collections Summary',
            style: AppFonts.titleMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final crossAxisCount = isNarrow ? 1 : 3;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isNarrow ? 3.2 : 1.8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildFinancialTile(
                    title: 'Total Billed Revenue',
                    amount: CurrencyFormatter.format(totalBilled),
                    subtitle: 'From ${filteredInvoices.length} invoices',
                    color: AppColors.accentBlue,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                  _buildFinancialTile(
                    title: 'Total Collected',
                    amount: CurrencyFormatter.format(totalCollected),
                    subtitle: 'Real payments received',
                    color: AppColors.success,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                  _buildFinancialTile(
                    title: 'Outstanding Receivables',
                    amount: CurrencyFormatter.format(totalOutstanding),
                    subtitle: 'Customer balance due',
                    color: totalOutstanding > 0
                        ? AppColors.error
                        : AppColors.success,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Revenue Breakdown & Expense Tracking',
            style: AppFonts.titleMedium(color: primaryTextColor)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBreakdownRow(
                    title: '1. Parts Billed (Selling Price)',
                    value: CurrencyFormatter.format(partsRevenue),
                    subtitle: 'Amount charged to customers for spare parts',
                    color: primaryTextColor,
                  ),
                  const Divider(height: 16),
                  _buildBreakdownRow(
                    title: '2. Parts Expenditure (Purchase Cost)',
                    value: CurrencyFormatter.format(partsExpenditure),
                    subtitle: 'Actual wholesale cost spent by garage for parts',
                    color: AppColors.accentAmber,
                  ),
                  const Divider(height: 16),
                  _buildBreakdownRow(
                    title: 'Parts Gross Margin',
                    value: CurrencyFormatter.format(partsMargin),
                    subtitle: 'Profit earned on spare parts alone',
                    color: partsMargin >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const Divider(height: 16),
                  _buildBreakdownRow(
                    title: '3. Labour / Service Income',
                    value: CurrencyFormatter.format(laborRevenue),
                    subtitle: 'Pure mechanic service charges',
                    color: AppColors.accentBlue,
                  ),
                  if (extraWorkRevenue > 0) ...[
                    const Divider(height: 16),
                    _buildBreakdownRow(
                      title: '4. Extra Work Income',
                      value: CurrencyFormatter.format(extraWorkRevenue),
                      subtitle: 'Additional repair work billed',
                      color: AppColors.accentAmber,
                    ),
                  ],
                  if (totalDiscounts > 0) ...[
                    const Divider(height: 16),
                    _buildBreakdownRow(
                      title: '5. Total Customer Discounts Given',
                      value: '-${CurrencyFormatter.format(totalDiscounts)}',
                      subtitle: 'Discounts deducted from final bills',
                      color: AppColors.error,
                    ),
                  ],
                  const Divider(height: 20, thickness: 1.5),
                  _buildBreakdownRow(
                    title: 'Net Garage Operational Margin',
                    value: CurrencyFormatter.format(estimatedGarageMargin),
                    subtitle: 'Labour + Extra Work + Parts Profit',
                    color: AppColors.success,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppFonts.labelSmall(color: AppColors.textSecondaryLight),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppFonts.titleLarge(color: color)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTile({
    required String title,
    required String amount,
    required String subtitle,
    required Color color,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppFonts.labelMedium(color: AppColors.textSecondaryLight)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: AppFonts.titleLarge(color: color)
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppFonts.bodySmall(color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    (isBold
                            ? AppFonts.titleSmall(color: color)
                            : AppFonts.labelLarge(color: color))
                        .copyWith(
                          fontWeight: isBold
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
              ),
              Text(
                subtitle,
                style: AppFonts.bodySmall(color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style:
              (isBold
                      ? AppFonts.titleLarge(color: color)
                      : AppFonts.titleSmall(color: color))
                  .copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
