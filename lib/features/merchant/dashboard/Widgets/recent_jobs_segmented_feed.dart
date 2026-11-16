import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'clay_container.dart';

class RecentJobsSegmentedFeed extends StatefulWidget {
  const RecentJobsSegmentedFeed({
    super.key,
    required this.jobs,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onJobSelected,
    required this.onNavigateToJobs,
  });

  final List<ServiceJobModel> jobs;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onJobSelected;
  final VoidCallback onNavigateToJobs;

  @override
  State<RecentJobsSegmentedFeed> createState() =>
      _RecentJobsSegmentedFeedState();
}

class _RecentJobsSegmentedFeedState extends State<RecentJobsSegmentedFeed> {
  String _searchQuery = '';
  String _selectedTechnician = 'All Technicians';
  String _selectedVehicleType = 'All Vehicle Types';
  String _selectedPriority = 'All Priorities';

  static const List<(String, String)> _filters = [
    ('all', 'All Active'),
    ('in_progress', 'In Progress'),
    ('pending_assignment', 'Unassigned'),
    ('ready_for_pickup', 'Ready'),
    ('completed', 'Completed'),
  ];

  Widget _buildDropdownPill({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: PhosphorIcon(
            PhosphorIconsRegular.caretDown,
            size: 11,
            color: secondaryTextColor,
          ),
          style: AppFonts.labelSmall(color: secondaryTextColor)
              .copyWith(fontSize: 11, fontWeight: FontWeight.w600),
          dropdownColor: isDark ? const Color(0xFF1E2638) : Colors.white,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
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

    final technicians = [
      'All Technicians',
      ...{
        ...widget.jobs
            .map((j) => j.technicianName)
            .where((name) => name.isNotEmpty),
      },
    ];

    final filteredJobs = widget.jobs.where((job) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesNumber = job.jobNumber.toLowerCase().contains(query);
        final matchesCustomer = job.customerName.toLowerCase().contains(query);
        final matchesVehicle = job.vehicleDisplay.toLowerCase().contains(query);
        if (!matchesNumber && !matchesCustomer && !matchesVehicle) {
          return false;
        }
      }
      if (_selectedTechnician != 'All Technicians' &&
          job.technicianName != _selectedTechnician) {
        return false;
      }
      return true;
    }).toList();

    return ClayContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              final searchField = Container(
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2638)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.magnifyingGlass,
                      size: 14,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: AppFonts.bodySmall(color: primaryTextColor),
                        decoration: InputDecoration(
                          hintText: 'Search by Job ID, plate, customer...',
                          hintStyle: AppFonts.labelSmall(
                            color: secondaryTextColor.withValues(alpha: 0.7),
                          ).copyWith(fontSize: 11.5),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              final dropdownRow = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdownPill(
                      value: _selectedTechnician,
                      items: technicians,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedTechnician = val);
                        }
                      },
                      isDark: isDark,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    _buildDropdownPill(
                      value: _selectedVehicleType,
                      items: const [
                        'All Vehicle Types',
                        'Cars',
                        'Bikes',
                        'Commercial',
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedVehicleType = val);
                        }
                      },
                      isDark: isDark,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    _buildDropdownPill(
                      value: _selectedPriority,
                      items: const ['All Priorities', 'High', 'Normal', 'Low'],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPriority = val);
                        }
                      },
                      isDark: isDark,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(flex: 5, child: searchField),
                    const SizedBox(width: 10),
                    Expanded(flex: 6, child: dropdownRow),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  searchField,
                  const SizedBox(height: 10),
                  dropdownRow,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final isSelected = widget.selectedFilter == f.$1;
                      final count = f.$1 == 'all'
                          ? widget.jobs.length
                          : widget.jobs.where((j) {
                              if (f.$1 == 'in_progress') {
                                return j.status == 'in_progress';
                              }
                              if (f.$1 == 'pending_assignment') {
                                return j.status == 'pending_assignment' ||
                                    j.technicianName.isEmpty;
                              }
                              if (f.$1 == 'ready_for_pickup') {
                                return j.status == 'ready_for_pickup';
                              }
                              if (f.$1 == 'completed') {
                                return j.status == 'completed';
                              }
                              return false;
                            }).length;

                      final chipColor = isSelected
                          ? AppColors.primaryRed
                          : (isDark
                                ? const Color(0xFF1E2638)
                                : const Color(0xFFF1F5F9));
                      final textColor = isSelected
                          ? Colors.white
                          : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight);

                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => widget.onFilterChanged(f.$1),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: chipColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${f.$2} ($count)',
                              style: AppFonts.labelSmall(color: textColor)
                                  .copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 10.5,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Showing ${filteredJobs.length} of ${widget.jobs.length} jobs',
                style: AppFonts.labelSmall(
                  color: secondaryTextColor.withValues(alpha: 0.7),
                ).copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filteredJobs.isEmpty)
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF121722)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(
                      PhosphorIconsRegular.car,
                      size: 28,
                      color: secondaryTextColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No jobs found matching criteria',
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: filteredJobs.take(5).map((job) {
                final displayId = job.jobNumber;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => widget.onJobSelected(job.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2638) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  displayId,
                                  style:
                                      AppFonts.labelLarge(
                                        color: AppColors.primaryRed,
                                      ).copyWith(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppStatusBadge(status: job.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.vehicleDisplay,
                            style: AppFonts.titleSmall(color: primaryTextColor)
                                .copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              PhosphorIcon(
                                PhosphorIconsFill.user,
                                size: 12,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  job.customerName,
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ).copyWith(fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (job.technicianName.isNotEmpty) ...[
                                PhosphorIcon(
                                  PhosphorIconsFill.wrench,
                                  size: 12,
                                  color: AppColors.primaryRed,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    job.technicianName,
                                    style:
                                        AppFonts.labelSmall(
                                          color: AppColors.primaryRed,
                                        ).copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                DateFormatter.formatRelative(
                                  job.updatedAt ?? job.createdAt,
                                ),
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ).copyWith(fontSize: 10.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
