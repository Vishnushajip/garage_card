import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading_state.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:go_router/go_router.dart';

import '../ViewModel/workshop_bays_view_model.dart';
import '../Widgets/add_edit_bay_dialog.dart';
import '../Widgets/assign_job_to_bay_sheet.dart';
import '../Widgets/bay_card_widget.dart';

class MerchantBaysScreen extends ConsumerWidget {
  const MerchantBaysScreen({super.key});

  Widget _buildSummaryPill({
    required BuildContext context,
    required String label,
    required int count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryText,
    required Color cardBg,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppFonts.labelSmall(
                color: isSelected ? color : primaryText,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppFonts.labelSmall(color: color)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(workshopBaysViewModelProvider);
    final vm = ref.read(workshopBaysViewModelProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('workshopBays'),
        subtitle: context.tr('baysSubtitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: context.tr('refresh'),
            onPressed: () => vm.refresh(),
          ),
        ],
      ),
      body: state.isLoading
          ? const AppLoadingState()
          : AppResponsiveLayout(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSummaryPill(
                            context: context,
                            label: 'All Bays',
                            count: state.totalBays,
                            color: AppColors.accentBlue,
                            isSelected: state.filterStatus == 'all',
                            onTap: () => vm.setFilterStatus('all'),
                            primaryText: primaryText,
                            cardBg: cardBg,
                            borderColor: borderColor,
                          ),
                          const SizedBox(width: 8),
                          _buildSummaryPill(
                            context: context,
                            label: context.tr('available'),
                            count: state.availableBays,
                            color: AppColors.success,
                            isSelected: state.filterStatus == 'available',
                            onTap: () => vm.setFilterStatus('available'),
                            primaryText: primaryText,
                            cardBg: cardBg,
                            borderColor: borderColor,
                          ),
                          const SizedBox(width: 8),
                          _buildSummaryPill(
                            context: context,
                            label: context.tr('occupied'),
                            count: state.occupiedBays,
                            color: AppColors.primaryRed,
                            isSelected: state.filterStatus == 'occupied',
                            onTap: () => vm.setFilterStatus('occupied'),
                            primaryText: primaryText,
                            cardBg: cardBg,
                            borderColor: borderColor,
                          ),
                          const SizedBox(width: 8),
                          _buildSummaryPill(
                            context: context,
                            label: context.tr('maintenance'),
                            count: state.maintenanceBays,
                            color: AppColors.accentAmber,
                            isSelected: state.filterStatus == 'maintenance',
                            onTap: () => vm.setFilterStatus('maintenance'),
                            primaryText: primaryText,
                            cardBg: cardBg,
                            borderColor: borderColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (state.filteredBays.isEmpty)
                      AppEmptyState(
                        icon: Icons.garage_rounded,
                        title: 'No bays in this category',
                        message: 'Tap "+ Add New Bay" to set up lifts and repair bays for your workshop floor.',
                        actionLabel: context.tr('addBay'),
                        onAction: () => AddEditBayDialog.show(
                          context,
                          onSave: (name, type) =>
                              vm.createBay(name: name, type: type),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final width = constraints.maxWidth;
                          final crossAxisCount = width >= 900
                              ? 3
                              : width >= 600
                              ? 2
                              : 1;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.filteredBays.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: crossAxisCount == 1
                                      ? 1.6
                                      : 1.35,
                                ),
                            itemBuilder: (ctx, index) {
                              final bay = state.filteredBays[index];
                              return BayCardWidget(
                                bay: bay,
                                onAssignJob: () => AssignJobToBaySheet.show(
                                  context,
                                  bayName: bay.name,
                                  onSelectJob: (job) => vm.assignJobToBay(
                                    bayId: bay.id,
                                    jobId: job.id,
                                    vehicleDisplay:
                                        job.vehicleDisplay.isNotEmpty
                                        ? job.vehicleDisplay
                                        : job.jobNumber,
                                    mechanic: job.technicianName,
                                  ),
                                ),
                                onReleaseBay: () async {
                                  final confirmed = await AppDialog.confirm(
                                    context,
                                    title: context.tr('releaseBay'),
                                    message: context.tr('releaseBayConfirm'),
                                    confirmLabel: context.tr('releaseBay'),
                                    isDestructive: true,
                                  );
                                  if (confirmed == true) {
                                    vm.releaseBay(bay.id);
                                  }
                                },
                                onToggleMaintenance: () =>
                                    vm.toggleMaintenance(bay.id),
                                onDeleteBay: () async {
                                  final confirmed = await AppDialog.confirm(
                                    context,
                                    title: 'Delete Bay',
                                    message:
                                        'Are you sure you want to remove ${bay.name}?',
                                    confirmLabel: 'Delete',
                                    isDestructive: true,
                                  );
                                  if (confirmed == true) {
                                    vm.deleteBay(bay.id);
                                  }
                                },
                                onViewJob: (jobId) =>
                                    context.push('/merchant/jobs/$jobId'),
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditBayDialog.show(
          context,
          onSave: (name, type) => vm.createBay(name: name, type: type),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.tr('addBay')),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
