import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../Model/dashboard_analytics_models.dart';
import 'clay_container.dart';
import 'clay_tooltip.dart';

class _PipelineStageData {
  const _PipelineStageData({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.color,
    required this.filterKey,
  });

  final String stepNumber;
  final String title;
  final String subtitle;
  final int count;
  final PhosphorIconData icon;
  final Color color;
  final String filterKey;
}

class WorkshopPipelineDiagram extends StatelessWidget {
  const WorkshopPipelineDiagram({
    super.key,
    required this.operationalMetrics,
    this.onStageSelected,
    this.onNavigateToJobs,
  });

  final DashboardOperationalMetrics operationalMetrics;
  final ValueChanged<String>? onStageSelected;
  final VoidCallback? onNavigateToJobs;

  List<_PipelineStageData> _buildStages() {
    return [
      _PipelineStageData(
        stepNumber: '01',
        title: 'Booked & Intake',
        subtitle: 'Unassigned & Appointments',
        count:
            operationalMetrics.jobsAwaitingAssignment +
            operationalMetrics.todayAppointments,
        icon: PhosphorIconsFill.calendarCheck,
        color: const Color(0xFF6366F1),
        filterKey: 'pending',
      ),
      _PipelineStageData(
        stepNumber: '02',
        title: 'Inspection & Quote',
        subtitle: 'Diagnostics & Quotes',
        count:
            operationalMetrics.jobsAwaitingInspection +
            operationalMetrics.estimatesAwaitingApproval,
        icon: PhosphorIconsFill.clipboardText,
        color: const Color(0xFF8B5CF6),
        filterKey: 'inspection',
      ),
      _PipelineStageData(
        stepNumber: '03',
        title: 'Active Bay Repairs',
        subtitle: 'Technicians on Floor',
        count: operationalMetrics.jobsInProgress,
        icon: PhosphorIconsFill.wrench,
        color: const Color(0xFF2563EB),
        filterKey: 'in_progress',
      ),
      _PipelineStageData(
        stepNumber: '04',
        title: 'Awaiting Parts',
        subtitle: 'Logistics & Suppliers',
        count: operationalMetrics.jobsAwaitingParts,
        icon: PhosphorIconsFill.package,
        color: const Color(0xFFF59E0B),
        filterKey: 'waiting_parts',
      ),
      _PipelineStageData(
        stepNumber: '05',
        title: 'Ready for Pickup',
        subtitle: 'Quality Tested & Clean',
        count: operationalMetrics.jobsReadyForPickup,
        icon: PhosphorIconsFill.key,
        color: const Color(0xFF06B6D4),
        filterKey: 'ready',
      ),
      _PipelineStageData(
        stepNumber: '06',
        title: 'Delivered & Paid',
        subtitle: 'Settled & Invoiced',
        count: operationalMetrics.jobsCompleted,
        icon: PhosphorIconsFill.checkCircle,
        color: const Color(0xFF10B981),
        filterKey: 'completed',
      ),
    ];
  }

  Widget _buildLiveDot() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF10B981),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0x6610B981), blurRadius: 5, spreadRadius: 1.5),
        ],
      ),
    );
  }

  Widget _buildStageCard({
    required BuildContext context,
    required _PipelineStageData stage,
    required bool isDark,
  }) {
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return InkWell(
      onTap: () {
        if (onStageSelected != null) {
          onStageSelected!(stage.filterKey);
        } else if (onNavigateToJobs != null) {
          onNavigateToJobs!();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161C28) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: stage.color.withValues(alpha: isDark ? 0.32 : 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: stage.color.withValues(alpha: isDark ? 0.12 : 0.05),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: stage.color.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    stage.stepNumber,
                    style: AppFonts.labelSmall(color: stage.color)
                        .copyWith(fontSize: 9.5, fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: stage.color.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: PhosphorIcon(
                      stage.icon,
                      size: 14,
                      color: stage.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${stage.count}',
                style: AppFonts.titleLarge(color: primaryTextColor).copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stage.title,
              style: AppFonts.labelSmall(color: primaryTextColor)
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              stage.subtitle,
              style: AppFonts.labelSmall(
                color: secondaryTextColor.withValues(alpha: 0.8),
              ).copyWith(fontSize: 9.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar(List<_PipelineStageData> stages, bool isDark) {
    final total = stages.fold<int>(0, (sum, s) => sum + s.count);

    if (total == 0) {
      return Container(
        height: 8,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF222B3D) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(
          children: stages.map((stage) {
            if (stage.count == 0) return const SizedBox.shrink();
            final flex = stage.count;
            return Expanded(
              flex: flex,
              child: Container(
                color: stage.color,
                margin: const EdgeInsets.symmetric(horizontal: 0.5),
              ),
            );
          }).toList(),
        ),
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

    final stages = _buildStages();
    final totalVehicles = stages.fold<int>(0, (sum, s) => sum + s.count);
    final activeFloorLoad = operationalMetrics.vehiclesCurrentlyUnderService;

    return ClayContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final headerInfo = Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: PhosphorIcon(
                        PhosphorIconsFill.gitFork,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Workshop Bay & Pipeline Stage Diagram',
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const ClayTooltip(
                              message: 'Real-time vehicle lifecycle progression across intake, diagnostics, active repair bays, parts logistics, and final delivery.',
                              iconSize: 14,
                            ),
                          ],
                        ),
                        Text(
                          'Live throughput of $totalVehicles vehicles across workshop fulfillment stages',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final bayCapacityBadge = Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2638)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLiveDot(),
                    const SizedBox(width: 6),
                    Text(
                      '$activeFloorLoad in Floor Bays',
                      style: AppFonts.labelSmall(
                        color: isDark ? Colors.white : const Color(0xFF1D4ED8),
                      ).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: headerInfo),
                    const SizedBox(width: 12),
                    bayCapacityBadge,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerInfo,
                  const SizedBox(height: 10),
                  bayCapacityBadge,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              if (width >= 1150) {
                return Row(
                  children: [
                    for (int i = 0; i < stages.length; i++) ...[
                      Expanded(
                        child: _buildStageCard(
                          context: context,
                          stage: stages[i],
                          isDark: isDark,
                        ),
                      ),
                      if (i < stages.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: PhosphorIcon(
                            PhosphorIconsBold.caretRight,
                            size: 14,
                            color: secondaryTextColor.withValues(alpha: 0.4),
                          ),
                        ),
                    ],
                  ],
                );
              }

              if (width >= 680) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 124,
                  ),
                  itemCount: stages.length,
                  itemBuilder: (context, index) {
                    return _buildStageCard(
                      context: context,
                      stage: stages[index],
                      isDark: isDark,
                    );
                  },
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  mainAxisExtent: 120,
                ),
                itemCount: stages.length,
                itemBuilder: (context, index) {
                  return _buildStageCard(
                    context: context,
                    stage: stages[index],
                    isDark: isDark,
                  );
                },
              );
            },
          ),
          const SizedBox(height: 14),
          _buildDistributionBar(stages, isDark),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stage distribution ratio',
                style: AppFonts.labelSmall(
                  color: secondaryTextColor.withValues(alpha: 0.7),
                ).copyWith(fontSize: 10),
              ),
              InkWell(
                onTap: onNavigateToJobs,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'View Live Floor Board',
                        style: AppFonts.labelSmall(
                          color: const Color(0xFF2563EB),
                        ).copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      const PhosphorIcon(
                        PhosphorIconsBold.arrowRight,
                        size: 11,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
