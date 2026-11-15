import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';
import 'clay_tooltip.dart';

class RevenueAnalyticsCard extends StatefulWidget {
  const RevenueAnalyticsCard({
    super.key,
    required this.financialMetrics,
    this.currencyCode = 'INR',
  });

  final DashboardFinancialMetrics financialMetrics;
  final String currencyCode;

  @override
  State<RevenueAnalyticsCard> createState() => _RevenueAnalyticsCardState();
}

class _RevenueAnalyticsCardState extends State<RevenueAnalyticsCard> {
  int? _hoveredIndex;
  bool _showInvoiced = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    final points = widget.financialMetrics.dailyRevenuePoints;
    final hasData = points.any((p) => p.collected > 0 || p.invoiced > 0);

    double maxVal = 0.0;
    double highestDayVal = 0.0;
    String highestDayLabel = 'N/A';
    double totalPeriodVal = 0.0;

    for (final p in points) {
      final val = _showInvoiced ? p.invoiced : p.collected;
      totalPeriodVal += val;
      if (val > highestDayVal) {
        highestDayVal = val;
        highestDayLabel = p.label;
      }
      maxVal = math.max(maxVal, math.max(p.invoiced, p.collected));
    }
    if (maxVal <= 0) maxVal = 1000;

    final avgDaily = points.isNotEmpty ? totalPeriodVal / points.length : 0.0;

    return ClayContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 540;
              final headerContent = Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(
                        alpha: isDark ? 0.16 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsFill.chartLineUp,
                        size: 20,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Revenue & Income Trends',
                              style: AppFonts.titleMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 6),
                            const ClayTooltip(
                              message: 'Interactive periodic trend of successfully collected payments vs invoiced work.',
                              iconSize: 14,
                            ),
                          ],
                        ),
                        Text(
                          'Track cashflow velocity across the selected timeline',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final toggleSegment = Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2638)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSegmentButton(
                      label: 'Collected',
                      isSelected: !_showInvoiced,
                      onTap: () => setState(() => _showInvoiced = false),
                      isDark: isDark,
                    ),
                    _buildSegmentButton(
                      label: 'Invoiced',
                      isSelected: _showInvoiced,
                      onTap: () => setState(() => _showInvoiced = true),
                      isDark: isDark,
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: headerContent),
                    const SizedBox(width: 16),
                    toggleSegment,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerContent,
                  const SizedBox(height: 14),
                  toggleSegment,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMiniStat(
                label: _showInvoiced ? 'Total Invoiced' : 'Total Collected',
                value: CurrencyFormatter.format(
                  _showInvoiced
                      ? widget.financialMetrics.totalInvoiced
                      : widget.financialMetrics.totalCollected,
                ),
                color: _showInvoiced ? AppColors.accentBlue : AppColors.success,
                isDark: isDark,
              ),
              _buildMiniStat(
                label: 'Peak Day',
                value:
                    '${CurrencyFormatter.format(highestDayVal)} ($highestDayLabel)',
                color: AppColors.accentAmber,
                isDark: isDark,
              ),
              _buildMiniStat(
                label: 'Average per Point',
                value: CurrencyFormatter.format(avgDaily),
                color: AppColors.info,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (!hasData)
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF121722)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.chartBar,
                      size: 38,
                      color: secondaryTextColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No revenue records in this date range',
                      style: AppFonts.bodyMedium(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Income and invoice charts will automatically generate as jobs are billed.',
                      style: AppFonts.labelSmall(
                        color: secondaryTextColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (_hoveredIndex != null && _hoveredIndex! < points.length) ...[
              _buildPointTooltip(points[_hoveredIndex!], isDark),
              const SizedBox(height: 14),
            ],
            LayoutBuilder(
              builder: (context, chartConstraints) {
                final minRequiredWidth = points.length * 38.0;
                final shouldScroll =
                    chartConstraints.maxWidth < minRequiredWidth;

                final chartRow = Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: points.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final pt = entry.value;
                    final isHovered = _hoveredIndex == idx;

                    final primaryVal = _showInvoiced
                        ? pt.invoiced
                        : pt.collected;
                    final barHeight = primaryVal > 0
                        ? (primaryVal / maxVal * 140).clamp(6.0, 140.0)
                        : 4.0;

                    final barColor = _showInvoiced
                        ? AppColors.accentBlue
                        : AppColors.success;

                    final barWidget = InkWell(
                      onTap: () {
                        setState(() {
                          _hoveredIndex = _hoveredIndex == idx ? null : idx;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: isHovered
                            ? BoxDecoration(
                                color: barColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              )
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              height: barHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    barColor,
                                    barColor.withValues(alpha: 0.75),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: isHovered
                                    ? [
                                        BoxShadow(
                                          color: barColor.withValues(
                                            alpha: 0.4,
                                          ),
                                          offset: const Offset(0, 4),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              pt.label,
                              style:
                                  AppFonts.labelSmall(
                                    color: isHovered
                                        ? primaryTextColor
                                        : secondaryTextColor,
                                  ).copyWith(
                                    fontSize: 10.5,
                                    fontWeight: isHovered
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );

                    if (shouldScroll) {
                      return SizedBox(width: 38, child: barWidget);
                    }
                    return Expanded(child: barWidget);
                  }).toList(),
                );

                if (shouldScroll) {
                  return SizedBox(
                    height: 190,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(width: minRequiredWidth, child: chartRow),
                    ),
                  );
                }

                return SizedBox(height: 190, child: chartRow);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF28334E) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style:
              AppFonts.labelSmall(
                color: isSelected
                    ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ).copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppFonts.labelSmall(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ).copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppFonts.labelMedium(color: color)
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPointTooltip(DashboardChartPoint pt, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Timeline: ${pt.label}',
            style: AppFonts.labelSmall(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 14),
          Text(
            'Collected: ${CurrencyFormatter.format(pt.collected)}',
            style: AppFonts.labelSmall(color: AppColors.success)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 14),
          Text(
            'Invoiced: ${CurrencyFormatter.format(pt.invoiced)}',
            style: AppFonts.labelSmall(color: AppColors.accentBlue)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
