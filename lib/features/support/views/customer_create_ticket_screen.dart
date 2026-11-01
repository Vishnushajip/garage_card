import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/models/vehicle_model.dart';
import 'package:garage_card/features/support/view_models/create_ticket_view_model.dart';
import 'package:garage_card/features/support/view_models/customer_support_view_model.dart';
import 'package:go_router/go_router.dart';

class CustomerCreateTicketScreen extends ConsumerStatefulWidget {
  const CustomerCreateTicketScreen({
    super.key,
    this.preselectedJobId,
    this.preselectedGarageId,
    this.preselectedVehicleId,
    this.preselectedInvoiceId,
  });

  final String? preselectedJobId;
  final String? preselectedGarageId;
  final String? preselectedVehicleId;
  final String? preselectedInvoiceId;

  @override
  ConsumerState<CustomerCreateTicketScreen> createState() =>
      _CustomerCreateTicketScreenState();
}

class _CustomerCreateTicketScreenState
    extends ConsumerState<CustomerCreateTicketScreen> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(createTicketViewModelProvider.notifier)
          .loadCustomerContext(
            preselectedJobId: widget.preselectedJobId,
            preselectedGarageId: widget.preselectedGarageId,
            preselectedVehicleId: widget.preselectedVehicleId,
            preselectedInvoiceId: widget.preselectedInvoiceId,
          );
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(createTicketViewModelProvider.notifier);
    final success = await notifier.submitTicket(
      subject: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (success && mounted) {
      ref.read(customerSupportViewModelProvider.notifier).refresh();
      final created = ref.read(createTicketViewModelProvider).createdTicket;
      if (created != null) {
        context.pushReplacement('/customer/support/${created.id}');
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createTicketViewModelProvider);
    final notifier = ref.read(createTicketViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: context.tr('createSupportTicket'),
        subtitle: context.tr('createTicketSubtitle'),
      ),
      body: SingleChildScrollView(
        child: AppResponsiveLayout(
          maxWidth: 800,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: AppFonts.bodySmall(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Card(
                  color: cardBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('ticketInformation'),
                          style: AppFonts.titleMedium(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        AppDropdown<String>(
                          label: context.tr('supportCategory'),
                          value: state.category,
                          items: [
                            AppDropdownItem(
                              value: 'vehicle_issue',
                              title: context.tr('vehicleIssue'),
                            ),
                            AppDropdownItem(
                              value: 'repair_delay',
                              title: context.tr('repairDelay'),
                            ),
                            AppDropdownItem(
                              value: 'estimate_inquiry',
                              title: context.tr('estimateInquiry'),
                            ),
                            AppDropdownItem(
                              value: 'invoice_dispute',
                              title: context.tr('invoiceDispute'),
                            ),
                            AppDropdownItem(
                              value: 'service_quality',
                              title: context.tr('serviceQuality'),
                            ),
                            AppDropdownItem(
                              value: 'general_support',
                              title: context.tr('generalSupport'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) notifier.setCategory(val);
                          },
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _subjectController,
                          label: context.tr('subject'),
                          hint: context.tr('subjectHint'),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _descriptionController,
                          label: context.tr('issueDescription'),
                          hint: context.tr('descriptionHint'),
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: AppDropdown<String>(
                                label: context.tr('priority'),
                                value: state.priority,
                                items: const [
                                  AppDropdownItem(value: 'low', title: 'Low'),
                                  AppDropdownItem(
                                    value: 'medium',
                                    title: 'Medium',
                                  ),
                                  AppDropdownItem(value: 'high', title: 'High'),
                                  AppDropdownItem(
                                    value: 'urgent',
                                    title: 'Urgent',
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) notifier.setPriority(val);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppDropdown<String>(
                                label: context.tr('preferredContact'),
                                value: state.preferredContact,
                                items: [
                                  AppDropdownItem(
                                    value: 'in_app',
                                    title: context.tr('inAppSupport'),
                                  ),
                                  AppDropdownItem(
                                    value: 'whatsapp',
                                    title: context.tr('whatsappOnly'),
                                  ),
                                  AppDropdownItem(
                                    value: 'phone',
                                    title: context.tr('phoneCall'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    notifier.setPreferredContact(val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  color: cardBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('relatedEntities'),
                          style: AppFonts.titleMedium(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        if (state.vehicles.isNotEmpty) ...[
                          AppDropdown<VehicleModel?>(
                            label: context.tr('relatedVehicle'),
                            value: state.selectedVehicle,
                            items: state.vehicles.map((v) {
                              return AppDropdownItem<VehicleModel?>(
                                value: v,
                                title:
                                    '${v.make} ${v.model} (${v.licensePlate})',
                              );
                            }).toList(),
                            onChanged: notifier.selectVehicle,
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (state.jobs.isNotEmpty) ...[
                          AppDropdown<ServiceJobModel?>(
                            label: context.tr('relatedRepairJob'),
                            value: state.selectedJob,
                            items: [
                              AppDropdownItem<ServiceJobModel?>(
                                value: null,
                                title: context.tr('noneNotApplicable'),
                              ),
                              ...state.jobs.map((j) {
                                return AppDropdownItem<ServiceJobModel?>(
                                  value: j,
                                  title:
                                      '${j.jobNumber} • ${j.vehicleDisplay.isNotEmpty ? j.vehicleDisplay : j.status}',
                                );
                              }),
                            ],
                            onChanged: notifier.selectJob,
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (state.invoices.isNotEmpty) ...[
                          AppDropdown<InvoiceModel?>(
                            label: context.tr('relatedInvoice'),
                            value: state.selectedInvoice,
                            items: [
                              AppDropdownItem<InvoiceModel?>(
                                value: null,
                                title: context.tr('noneNotApplicable'),
                              ),
                              ...state.invoices.map((inv) {
                                return AppDropdownItem<InvoiceModel?>(
                                  value: inv,
                                  title:
                                      '${inv.invoiceNumber} • ₹${inv.totalAmount.toStringAsFixed(0)}',
                                );
                              }),
                            ],
                            onChanged: notifier.selectInvoice,
                          ),
                          const SizedBox(height: 14),
                        ],
                        AppDropdown<GarageModel?>(
                          label: context.tr('relatedGarage'),
                          value: state.selectedGarage,
                          items: [
                            AppDropdownItem<GarageModel?>(
                              value: null,
                              title: context.tr('generalPlatformSupport'),
                            ),
                            ...state.garages.map((g) {
                              return AppDropdownItem<GarageModel?>(
                                value: g,
                                title: g.name,
                              );
                            }),
                          ],
                          onChanged: notifier.selectGarage,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: context.tr('submitTicket'),
                  icon: const Icon(Icons.send_rounded),
                  isLoading: state.isSubmitting,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
