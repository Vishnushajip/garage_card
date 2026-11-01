import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';

import '../Model/financial_metrics_model.dart';

class RevenueBarChart extends StatefulWidget {
  const RevenueBarChart({
    super.key,
    required this.dataPoints,
    this.currencyCode = 'INR',
  });

  final List<ChartDataPoint> dataPoints;
  final String currencyCode;

  @override
  State<RevenueBarChart> createState() => _RevenueBarChartState();
}

class _RevenueBarChartState extends State<RevenueBarChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final hasData = widget.dataPoints.any(
      (dp) => dp.billed > 0 || dp.collected > 0 || dp.cost > 0,
    );

    double maxVal = 0.0;
    for (final dp in widget.dataPoints) {
      maxVal = math.max(
        maxVal,
        math.max(dp.billed, math.max(dp.collected, dp.cost)),
      );
    }
    if (maxVal <= 0) maxVal = 1000;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Revenue, Collections & Costs',
                      style: AppFonts.titleMedium(color: primaryTextColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Periodic comparison breakdown',
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                  ],
                ),
                _buildLegend(isDark),
              ],
            ),
            if (!hasData) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 40,
                        color: secondaryTextColor.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No transaction activity for selected period',
                        style: AppFonts.bodyMedium(color: secondaryTextColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Revenue, collections and cost charts will appear when bills are created.',
                        style: AppFonts.labelSmall(
                          color: secondaryTextColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              if (_selectedIndex != null &&
                  _selectedIndex! < widget.dataPoints.length) ...[
                const SizedBox(height: 12),
                _buildSelectedTooltip(
                  widget.dataPoints[_selectedIndex!],
                  isDark,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: widget.dataPoints.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final dp = entry.value;
                    final isSelected = _selectedIndex == idx;

                    final billedHeight = dp.billed > 0
                        ? (dp.billed / maxVal * 140).clamp(4.0, 140.0)
                        : 0.0;
                    final collectedHeight = dp.collected > 0
                        ? (dp.collected / maxVal * 140).clamp(4.0, 140.0)
                        : 0.0;
                    final costHeight = dp.cost > 0
                        ? (dp.cost / maxVal * 140).clamp(4.0, 140.0)
                        : 0.0;

                    return Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = _selectedIndex == idx ? null : idx;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: AppColors.accentBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                )
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildBar(billedHeight, AppColors.accentBlue),
                                  const SizedBox(width: 2),
                                  _buildBar(collectedHeight, AppColors.success),
                                  const SizedBox(width: 2),
                                  _buildBar(costHeight, AppColors.accentAmber),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dp.label,
                                style: AppFonts.labelSmall(
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    if (height <= 0.0) {
      return const SizedBox(width: 7);
    }
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _legendDot(AppColors.accentBlue, 'Billed'),
        _legendDot(AppColors.success, 'Paid'),
        _legendDot(AppColors.accentAmber, 'Cost'),
      ],
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSelectedTooltip(ChartDataPoint dp, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${dp.label} Breakdown:',
            style: AppFonts.labelSmall(color: AppColors.accentBlue),
          ),
          Text(
            'Billed: ${CurrencyFormatter.format(dp.billed, currencyCode: widget.currencyCode)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentBlue,
            ),
          ),
          Text(
            'Collected: ${CurrencyFormatter.format(dp.collected, currencyCode: widget.currencyCode)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          Text(
            'Cost: ${CurrencyFormatter.format(dp.cost, currencyCode: widget.currencyCode)}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accentAmber,
            ),
          ),
        ],
      ),
    );
  }
}
