import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading_state.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/add_mechanic_bottom_sheet.dart';
import 'package:go_router/go_router.dart';

import '../ViewModel/merchant_mechanics_view_model.dart';
import '../Widgets/commission_settings_dialog.dart';
import '../Widgets/mechanic_workload_card.dart';

class MerchantMechanicsScreen extends ConsumerWidget {
  const MerchantMechanicsScreen({super.key});

  Widget _buildMetricCard({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color primaryText,
    required Color secondaryText,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: AppFonts.titleLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppFonts.labelSmall(color: secondaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(localeProvider);
    final state = ref.watch(merchantMechanicsViewModelProvider);
    final vm = ref.read(merchantMechanicsViewModelProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('mechanicsAndStaff'),
        subtitle: context.tr('mechanicsSubtitle'),
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
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        final isDesktop = constraints.maxWidth >= 600;
                        final crossAxisCount = isDesktop ? 4 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: isDesktop ? 1.8 : 1.5,
                          children: [
                            _buildMetricCard(
                              context: context,
                              label: context.tr('allMechanics'),
                              value: '${state.totalMechanics}',
                              icon: Icons.people_alt_rounded,
                              color: AppColors.accentBlue,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                            ),
                            _buildMetricCard(
                              context: context,
                              label: context.tr('activeWorkload'),
                              value: '${state.totalActiveAssignedJobs}',
                              icon: Icons.pending_actions_rounded,
                              color: AppColors.primaryRed,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                            ),
                            _buildMetricCard(
                              context: context,
                              label: context.tr('completedThisMonth'),
                              value: '${state.totalCompletedJobs}',
                              icon: Icons.task_alt_rounded,
                              color: AppColors.success,
                              cardBg: cardBg,
                              borderColor: borderColor,
                              primaryText: primaryText,
                              secondaryText: secondaryText,
                            ),
                            if (state.enableIncentives)
                              _buildMetricCard(
                                context: context,
                                label: context.tr('earnedCommission'),
                                value: CurrencyFormatter.format(
                                  state.grandEarnedCommission,
                                ),
                                icon: Icons.payments_rounded,
                                color: AppColors.accentAmber,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                primaryText: primaryText,
                                secondaryText: secondaryText,
                              )
                            else
                              _buildMetricCard(
                                context: context,
                                label: 'Status',
                                value: 'Operational',
                                icon: Icons.verified_user_rounded,
                                color: AppColors.accentBlue,
                                cardBg: cardBg,
                                borderColor: borderColor,
                                primaryText: primaryText,
                                secondaryText: secondaryText,
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: sectionBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            size: 22,
                            color: state.enableIncentives
                                ? AppColors.success
                                : secondaryText,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('enableIncentives'),
                                  style: AppFonts.bodyMedium(color: primaryText)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.enableIncentives
                                      ? 'Commission: ${state.defaultCommissionRate.toStringAsFixed(0)}% on labor revenue'
                                      : context.tr('incentivesDisabledNote'),
                                  style: AppFonts.labelSmall(
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.enableIncentives)
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              tooltip: 'Edit Commission Rate',
                              onPressed: () => CommissionSettingsDialog.show(
                                context,
                                currentRate: state.defaultCommissionRate,
                                onSave: vm.updateCommissionRate,
                              ),
                            ),
                          Switch(
                            value: state.enableIncentives,
                            activeColor: AppColors.success,
                            onChanged: vm.toggleIncentives,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      hint: 'Search mechanic by name or specialty...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      onChanged: vm.setSearchQuery,
                    ),
                    const SizedBox(height: 14),
                    if (state.filteredWorkloads.isEmpty)
                      AppEmptyState(
                        icon: Icons.person_off_rounded,
                        title: context.tr('noMechanicsRegistered'),
                        message: 'Add your technicians to start tracking active repairs and shop-floor workloads.',
                        actionLabel: context.tr('addNewMechanic'),
                        onAction: () async {
                          final added = await AddMechanicBottomSheet.show(
                            context,
                          );
                          if (added != null) {
                            vm.refresh();
                          }
                        },
                      )
                    else
                      ListView.builder(
                        itemCount: state.filteredWorkloads.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (ctx, index) {
                          final item = state.filteredWorkloads[index];
                          return MechanicWorkloadCard(
                            workload: item,
                            enableIncentives: state.enableIncentives,
                            onTapJob: (jobId) =>
                                context.push('/merchant/jobs/$jobId'),
                          );
                        },
                      ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await AddMechanicBottomSheet.show(context);
          if (added != null) {
            vm.refresh();
          }
        },
        icon: const Icon(Icons.person_add_rounded),
        label: Text(context.tr('addNewMechanic')),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
