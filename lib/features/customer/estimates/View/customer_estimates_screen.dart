import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/documents/pdf_generator_service.dart';
import 'package:garage_card/features/shared/models/estimate_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';

import '../ViewModel/customer_estimates_view_model.dart';
import '../Widgets/estimate_line_items_view.dart';

class CustomerEstimatesScreen extends ConsumerWidget {
  const CustomerEstimatesScreen({super.key});

  void _confirmApprove(
    BuildContext context,
    WidgetRef ref,
    EstimateModel estimate,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Approve Estimate?',
      message:
          'You are approving estimate ${estimate.estimateNumber} for ${CurrencyFormatter.format(estimate.totalAmount)}. The garage will proceed with repair works.',
      confirmLabel: 'Yes, Approve Estimate',
    );

    if (confirmed == true) {
      final success = await ref
          .read(customerEstimatesViewModelProvider.notifier)
          .approveEstimate(estimate.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Estimate approved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _promptReject(
    BuildContext context,
    WidgetRef ref,
    EstimateModel estimate,
  ) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Decline Estimate'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please specify a reason or clarification request for the garage:',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: reasonCtrl,
                hint: 'e.g. Cost exceeds budget, need alternative parts...',
                maxLines: 3,
                required: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            AppButton(
              label: 'Decline',
              variant: AppButtonVariant.danger,
              onPressed: () {
                final reason = reasonCtrl.text.trim();
                if (reason.isEmpty) return;
                Navigator.pop(dialogCtx);
                ref
                    .read(customerEstimatesViewModelProvider.notifier)
                    .rejectEstimate(estimate.id, reason);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerEstimatesViewModelProvider);
    final vm = ref.read(customerEstimatesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Digital Estimates',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: AppResponsiveLayout(
          child: Builder(
            builder: (context) {
              if (state.isLoading) {
                return const AppLoading(message: 'Loading estimates...');
              }
              if (state.errorMessage != null && state.estimates.isEmpty) {
                return AppErrorState(
                  message: state.errorMessage!,
                  onRetry: vm.refresh,
                );
              }
              if (state.estimates.isEmpty) {
                return const AppEmptyState(
                  title: 'No Estimates Available',
                  message: 'When your mechanic completes vehicle inspection, digital estimates will appear here for your review.',
                  icon: Icons.request_quote_outlined,
                );
              }

              return ListView.builder(
                itemCount: state.estimates.length,
                itemBuilder: (ctx, index) {
                  final estimate = state.estimates[index];

                  return Card(
                    color: cardBg,
                    margin: const EdgeInsets.only(bottom: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    estimate.estimateNumber,
                                    style: AppFonts.titleLarge(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  Text(
                                    'Created: ${DateFormatter.formatDate(estimate.createdAt)}',
                                    style: AppFonts.labelSmall(
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              AppStatusBadge(status: estimate.status),
                            ],
                          ),
                          const Divider(height: 24),
                          EstimateLineItemsView(estimate: estimate),
                          const Divider(height: 24),
                          Row(
                            children: [
                              IconButton.outlined(
                                tooltip: 'Print or Save PDF',
                                icon: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.accentBlue,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final dummyGarage = GarageModel(
                                    id: estimate.garageId,
                                    name: 'Apex Precision Automotive',
                                    address: 'Near MG Road, Ravipuram, Kochi, Kerala',
                                    phone: '+91 98460 12345',
                                    email: 'service@apexprecision.com',
                                    ownerUid: 'merchant_1',
                                  );
                                  PdfGeneratorService.printOrShareEstimate(
                                    garage: dummyGarage,
                                    estimate: estimate,
                                    customerName: 'Arjun Menon',
                                    vehicleDisplay:
                                        '2022 Hyundai Creta (KL 07 CD 4488)',
                                  );
                                },
                              ),
                              const Spacer(),
                              if (estimate.status != 'approved') ...[
                                AppButton(
                                  label: 'Decline',
                                  variant: AppButtonVariant.outline,
                                  onPressed: () =>
                                      _promptReject(context, ref, estimate),
                                  height: 40,
                                ),
                                const SizedBox(width: 10),
                                AppButton(
                                  label: 'Approve Estimate',
                                  variant: AppButtonVariant.primary,
                                  isLoading: state.isActionInProgress,
                                  onPressed: () =>
                                      _confirmApprove(context, ref, estimate),
                                  height: 40,
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.successBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.success,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Approved by you on ${DateFormatter.formatDate(estimate.approvedAt)}',
                                        style: AppFonts.labelSmall(
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
