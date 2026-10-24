import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/customer/estimates/Widgets/estimate_line_items_view.dart';
import 'package:garage_card/features/shared/documents/pdf_generator_service.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';
import '../ViewModel/merchant_estimates_view_model.dart';
import '../Widgets/estimate_form_dialog.dart';

class MerchantEstimatesScreen extends ConsumerWidget {
  const MerchantEstimatesScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return EstimateFormDialog(
          onSave: ({
            required String estimateNumber,
            required List items,
            required double taxRate,
            required double discountAmount,
          }) {
            return ref
                .read(merchantEstimatesViewModelProvider.notifier)
                .createEstimate(
                  estimateNumber: estimateNumber,
                  items: items.cast(),
                  taxRate: taxRate,
                  discountAmount: discountAmount,
                );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantEstimatesViewModelProvider);
    final vm = ref.read(merchantEstimatesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Estimates & Quotes',
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
                return AppEmptyState(
                  title: 'No Estimates Created',
                  message: 'Create and send quotes for customer inspection jobs.',
                  icon: Icons.request_quote_outlined,
                  actionLabel: 'Create Estimate',
                  onAction: () => _showCreateDialog(context, ref),
                );
              }

              return ListView.builder(
                itemCount: state.estimates.length,
                itemBuilder: (ctx, index) {
                  final estimate = state.estimates[index];
                  return Card(
                    color: cardBg,
                    margin: const EdgeInsets.only(bottom: 16),
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
                                    'Date: ${DateFormatter.formatDate(estimate.createdAt)}',
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
                                tooltip: 'Print or Share PDF',
                                icon: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.accentBlue,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final dummyGarage = GarageModel(
                                    id: estimate.garageId,
                                    name: 'Apex Precision Automotive',
                                    address:
                                        'Near MG Road, Ravipuram, Kochi, Kerala',
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
                              const SizedBox(width: 8),
                              IconButton.outlined(
                                tooltip: 'Share on WhatsApp',
                                icon: const Icon(
                                  Icons.chat_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                onPressed: () {
                                  final msg =
                                      WhatsAppShareService.composeEstimateMessage(
                                    customerName: 'Arjun Menon',
                                    garageName: 'Apex Precision Automotive',
                                    vehicleDisplay: '2022 Hyundai Creta',
                                    estimateNumber: estimate.estimateNumber,
                                    totalAmount: CurrencyFormatter.format(
                                        estimate.totalAmount),
                                  );
                                  WhatsAppShareService.sendWhatsAppMessage(
                                    phoneNumber: '+919846077112',
                                    message: msg,
                                  );
                                },
                              ),
                              const Spacer(),
                              if (estimate.status == 'approved') ...[
                                AppButton(
                                  label: 'Convert to Invoice',
                                  variant: AppButtonVariant.primary,
                                  isLoading: state.isConverting,
                                  height: 40,
                                  onPressed: () async {
                                    final success =
                                        await vm.convertToInvoice(estimate);
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Estimate converted into invoice successfully!'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Estimate'),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
