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

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2A364F) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
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
                    ? (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight)
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
    Widget? extraBadge,
  }) {
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppFonts.labelSmall(color: secondaryTextColor)
                .copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppFonts.titleSmall(color: color)
                    .copyWith(fontWeight: FontWeight.w800, fontSize: 14.5),
              ),
              if (extraBadge != null) ...[const SizedBox(width: 6), extraBadge],
            ],
          ),
        ],
      ),
    );
  }

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
    int peakIndex = 0;
    double totalPeriodVal = 0.0;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final val = _showInvoiced ? p.invoiced : p.collected;
      totalPeriodVal += val;
      if (val > highestDayVal) {
        highestDayVal = val;
        highestDayLabel = p.label;
        peakIndex = i;
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
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildMiniStat(
                  label: _showInvoiced ? 'Total Invoiced' : 'Total Collected',
                  value: CurrencyFormatter.format(
                    _showInvoiced
                        ? widget.financialMetrics.totalInvoiced
                        : widget.financialMetrics.totalCollected,
                  ),
                  color: _showInvoiced
                      ? AppColors.accentBlue
                      : AppColors.success,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _buildMiniStat(
                  label: 'Peak Day',
                  value:
                      '${CurrencyFormatter.format(highestDayVal)} ($highestDayLabel)',
                  color: AppColors.accentAmber,
                  isDark: isDark,
                  extraBadge: highestDayVal > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '● $highestDayLabel - ${CurrencyFormatter.format(highestDayVal)} (1 Settlement)',
                            style: AppFonts.labelSmall(color: Colors.white)
                                .copyWith(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                _buildMiniStat(
                  label: 'Average per Point',
                  value: CurrencyFormatter.format(avgDaily),
                  color: AppColors.info,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (!hasData)
            Container(
              height: 170,
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
                      PhosphorIconsRegular.chartLineUp,
                      size: 36,
                      color: secondaryTextColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No revenue records in this date range',
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = constraints.maxWidth;
                final primaryColor = _showInvoiced
                    ? AppColors.accentBlue
                    : const Color(0xFF10B981);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 150,
                      width: chartWidth,
                      child: CustomPaint(
                        size: Size(chartWidth, 150),
                        painter: _RevenueAreaChartPainter(
                          points: points,
                          showInvoiced: _showInvoiced,
                          maxVal: maxVal,
                          primaryColor: primaryColor,
                          isDark: isDark,
                          highlightIndex: _hoveredIndex ?? peakIndex,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          (points.length <= 6
                                  ? points
                                  : [
                                      points.first,
                                      points[(points.length * 0.25).floor()],
                                      points[(points.length * 0.5).floor()],
                                      points[(points.length * 0.75).floor()],
                                      points.last,
                                    ])
                              .map((p) {
                                return Text(
                                  p.label,
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ).copyWith(fontSize: 10),
                                );
                              })
                              .toList(),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RevenueAreaChartPainter extends CustomPainter {
  const _RevenueAreaChartPainter({
    required this.points,
    required this.showInvoiced,
    required this.maxVal,
    required this.primaryColor,
    required this.isDark,
    required this.highlightIndex,
  });

  final List<DashboardChartPoint> points;
  final bool showInvoiced;
  final double maxVal;
  final Color primaryColor;
  final bool isDark;
  final int highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final dashPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double midY = size.height * 0.5;
    const double dashWidth = 5;
    const double dashSpace = 4;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, midY),
        Offset(startX + dashWidth, midY),
        dashPaint,
      );
      startX += dashWidth + dashSpace;
    }

    final double stepX = points.length > 1
        ? size.width / (points.length - 1)
        : size.width;

    final path = Path();
    final areaPath = Path();

    final List<Offset> offsets = [];

    for (int i = 0; i < points.length; i++) {
      final val = showInvoiced ? points[i].invoiced : points[i].collected;
      final ratio = maxVal > 0 ? (val / maxVal).clamp(0.0, 1.0) : 0.0;
      final y = size.height - (ratio * (size.height - 20)) - 10;
      final x = i * stepX;
      offsets.add(Offset(x, y));
    }

    if (offsets.isNotEmpty) {
      path.moveTo(offsets.first.dx, offsets.first.dy);
      areaPath.moveTo(offsets.first.dx, size.height);
      areaPath.lineTo(offsets.first.dx, offsets.first.dy);

      for (int i = 1; i < offsets.length; i++) {
        final p0 = offsets[i - 1];
        final p1 = offsets[i];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
        areaPath.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p1.dx,
          p1.dy,
        );
      }

      areaPath.lineTo(offsets.last.dx, size.height);
      areaPath.close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.65),
            primaryColor.withValues(alpha: 0.05),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);

      final linePaint = Paint()
        ..color = primaryColor
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(path, linePaint);

      if (highlightIndex >= 0 && highlightIndex < offsets.length) {
        final targetOffset = offsets[highlightIndex];

        final circleFill = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        final circleStroke = Paint()
          ..color = primaryColor
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

        canvas.drawCircle(targetOffset, 5.0, circleFill);
        canvas.drawCircle(targetOffset, 5.0, circleStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RevenueAreaChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.showInvoiced != showInvoiced ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.highlightIndex != highlightIndex ||
        oldDelegate.primaryColor != primaryColor;
  }
}
