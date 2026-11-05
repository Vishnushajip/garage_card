import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_date_text.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:garage_card/features/customer/service_jobs/Widgets/status_timeline_view.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/add_extra_work_dialog.dart';
import 'package:garage_card/features/merchant/service_jobs/View/merchant_complete_job_screen.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/edit_invoice_dialog.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/job_whatsapp_share_dialog.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/update_payment_dialog.dart';
import 'package:garage_card/features/shared/documents/pdf_generator_service.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import '../ViewModel/merchant_jobs_view_model.dart';

class MerchantJobDetailScreen extends ConsumerStatefulWidget {
  const MerchantJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<MerchantJobDetailScreen> createState() =>
      _MerchantJobDetailScreenState();
}

class _MerchantJobDetailScreenState
    extends ConsumerState<MerchantJobDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(merchantJobsViewModelProvider.notifier).selectJob(widget.jobId);
    });
  }

  void _openChangeMechanicDialog(BuildContext context, ServiceJobModel job) {
    final state = ref.read(merchantJobsViewModelProvider);
    final mechanicSet = <String>{};
    for (final m in state.mechanics) {
      if (m.name.trim().isNotEmpty) {
        mechanicSet.add(m.name.trim());
      }
    }
    for (final j in state.jobs) {
      if (j.technicianName.trim().isNotEmpty) {
        mechanicSet.add(j.technicianName.trim());
      }
    }
    final mechanicList = mechanicSet.toList();

    String? selected =
        job.technicianName.isNotEmpty &&
            mechanicList.contains(job.technicianName)
        ? job.technicianName
        : (mechanicList.isNotEmpty ? mechanicList.first : null);
    final customCtrl = TextEditingController();
    bool isCustom = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(context.tr('changeAssignedMechanic')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppDropdown<String>(
                    label: context.tr('mechanic'),
                    value: isCustom ? '__custom__' : selected,
                    items: [
                      ...mechanicList.map(
                        (m) => AppDropdownItem(value: m, title: m),
                      ),
                      AppDropdownItem(
                        value: '__custom__',
                        title: context.tr('addCustomMechanic'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val == '__custom__') {
                        setDialogState(() {
                          isCustom = true;
                          selected = null;
                        });
                      } else {
                        setDialogState(() {
                          isCustom = false;
                          selected = val;
                        });
                      }
                    },
                  ),
                  if (isCustom) ...[
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: customCtrl,
                      label: context.tr('newMechanicName'),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(context.tr('cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = isCustom
                        ? customCtrl.text.trim()
                        : (selected ?? '');
                    if (name.isEmpty) return;
                    final successMsg =
                        '${context.tr("mechanicAssignedSuccess")}: $name';
                    Navigator.of(dialogCtx).pop();
                    final ok = await ref
                        .read(merchantJobsViewModelProvider.notifier)
                        .assignMechanic(jobId: job.id, mechanicName: name);
                    if (ok) {
                      AppNotificationService.success(successMsg);
                    }
                  },
                  child: Text(context.tr('save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openAddExtraWorkDialog(BuildContext context, ServiceJobModel job) {
    showDialog(
      context: context,
      builder: (ctx) => AddExtraWorkDialog(job: job),
    );
  }

  void _openCompleteJobBillingDialog(
    BuildContext context,
    ServiceJobModel job,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MerchantCompleteJobScreen(job: job)),
    );
  }

  void _openEditInvoiceDialog(
    BuildContext context,
    ServiceJobModel job,
    InvoiceModel invoice,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EditInvoiceDialog(invoice: invoice, job: job),
    );
  }

  void _openUpdatePaymentDialog(
    BuildContext context,
    ServiceJobModel job,
    InvoiceModel invoice,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpdatePaymentDialog(invoice: invoice, job: job),
    );
  }

  Future<void> _downloadPdf(
    BuildContext context,
    ServiceJobModel job,
    InvoiceModel invoice,
  ) async {
    final dashState = ref.read(merchantDashboardViewModelProvider);
    final garage = dashState.garage;
    if (garage == null) {
      AppNotificationService.warning('Garage details not loaded');
      return;
    }
    try {
      await PdfGeneratorService.printOrShareJobInvoice(
        garage: garage,
        job: job,
        invoice: invoice,
      );
    } catch (e) {
      AppNotificationService.error('Failed to generate PDF invoice: $e');
    }
  }

  void _openWhatsAppDialog(
    BuildContext context,
    ServiceJobModel job,
    InvoiceModel? invoice,
    WhatsAppNotificationType type,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => JobWhatsAppShareDialog(
        type: type,
        customerName: job.customerName,
        customerPhone: job.customerPhone,
        bikeNumber: job.vehicleDisplay,
        problem: job.complaints.isNotEmpty
            ? job.complaints.first
            : 'Service Request',
        jobNumber: job.jobNumber,
        mechanic: job.technicianName,
        extraWork: job.supplementalItems.isNotEmpty
            ? job.supplementalItems.map((e) => e.title).join(', ')
            : '',
        finalBillAmount: invoice?.totalAmount ?? 0.0,
        paidAmount: invoice?.paidAmount ?? 0.0,
        balanceDue: invoice?.balanceDue ?? 0.0,
        invoiceNumber: invoice?.invoiceNumber ?? job.jobNumber,
        paymentStatus: invoice?.status ?? 'unpaid',
      ),
    );
  }

  Future<void> _startRepairWork(ServiceJobModel job) async {
    final ok = await ref
        .read(merchantJobsViewModelProvider.notifier)
        .updateStatus(
          jobId: job.id,
          newStatus: 'in_progress',
          notes:
              'Repair work started by ${job.technicianName.isNotEmpty ? job.technicianName : "foreman"}',
        );
    if (ok) {
      AppNotificationService.success('Repair work marked In Progress');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final state = ref.watch(merchantJobsViewModelProvider);
    final vm = ref.read(merchantJobsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    if (state.isLoading) {
      return const Scaffold(body: AppLoading(message: 'Loading job record...'));
    }

    final job = state.selectedJob;
    if (job == null) {
      return Scaffold(
        appBar: const AppCustomAppBar(title: 'Job Record'),
        body: AppErrorState(
          message: 'Job record not found.',
          onRetry: () => vm.selectJob(widget.jobId),
        ),
      );
    }

    final invoice = state.selectedInvoice;
    final isCompleted =
        job.status.toLowerCase() == 'completed' ||
        job.status.toLowerCase() == 'closed' ||
        job.status.toLowerCase() == 'delivered';
    final isInProgress =
        job.status.toLowerCase() == 'in_progress' ||
        job.status.toLowerCase() == 'inprogress' ||
        job.status.toLowerCase() == 'awaiting_parts';
    final isPending = !isCompleted && !isInProgress;

    final extraWorkTotal = job.supplementalItems.fold(
      0.0,
      (acc, item) => acc + item.totalAmount,
    );

    return Scaffold(
      appBar: AppCustomAppBar(
        title: job.jobNumber,
        subtitle: job.vehicleDisplay,
        actions: [
          IconButton(
            tooltip: 'Inform Customer on WhatsApp',
            icon: const AppWhatsAppIcon(size: 20, color: Color(0xFF25D366)),
            onPressed: () => _openWhatsAppDialog(
              context,
              job,
              invoice,
              isCompleted
                  ? WhatsAppNotificationType.invoiceSharing
                  : WhatsAppNotificationType.jobCreated,
            ),
          ),
        ],
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: SingleChildScrollView(
          child: AppResponsiveLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: cardBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                job.vehicleDisplay,
                                style: AppFonts.titleLarge(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            AppStatusBadge(status: job.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              context.tr('customerLabel'),
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${job.customerName}${job.customerPhone.isNotEmpty ? " (${job.customerPhone})" : ""}',
                                style: AppFonts.bodyMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              context.tr('assignedMechanicLabel'),
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                job.technicianName.isNotEmpty
                                    ? job.technicianName
                                    : context.tr('notAssigned'),
                                style: AppFonts.bodyMedium(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () =>
                                  _openChangeMechanicDialog(context, job),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  context.tr('change'),
                                  style:
                                      AppFonts.labelSmall(
                                        color: AppColors.accentBlue,
                                      ).copyWith(
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.tr('createdLabel'),
                                  style: AppFonts.bodySmall(
                                    color: secondaryTextColor,
                                  ),
                                ),
                                AppDateText(
                                  date: job.createdAt,
                                  style: AppFonts.bodySmall(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if (job.completedDate != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.tr('completedLabel'),
                                    style: AppFonts.bodySmall(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  AppDateText(
                                    date: job.completedDate,
                                    style: AppFonts.bodySmall(
                                      color: primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (isPending) ...[
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: context.tr('startRepairWork'),
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () => _startRepairWork(job),
                                  variant: AppButtonVariant.primary,
                                  height: 44,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF25D366),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size.fromHeight(44),
                                  ),
                                  icon: const AppWhatsAppIcon(
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(context.tr('notifyCustomer')),
                                  onPressed: () => _openWhatsAppDialog(
                                    context,
                                    job,
                                    invoice,
                                    WhatsAppNotificationType.jobCreated,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (isInProgress) ...[
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  label: '+ ${context.tr("extraWork")}',
                                  icon: const Icon(
                                    Icons.add_task_rounded,
                                    size: 16,
                                  ),
                                  onPressed: () =>
                                      _openAddExtraWorkDialog(context, job),
                                  variant: AppButtonVariant.outline,
                                  height: 44,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppButton(
                                  label: context.tr('completeAndBill'),
                                  icon: const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      _openCompleteJobBillingDialog(
                                        context,
                                        job,
                                      ),
                                  variant: AppButtonVariant.primary,
                                  height: 44,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (invoice != null) ...[
                                ElevatedButton.icon(
                                  onPressed: () => _openEditInvoiceDialog(
                                    context,
                                    job,
                                    invoice,
                                  ),
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    size: 16,
                                  ),
                                  label: Text(context.tr('editBillDiscount')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentBlue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                if (invoice.balanceDue > 0)
                                  ElevatedButton.icon(
                                    onPressed: () => _openUpdatePaymentDialog(
                                      context,
                                      job,
                                      invoice,
                                    ),
                                    icon: const Icon(
                                      Icons.payment_rounded,
                                      size: 16,
                                    ),
                                    label: Text(context.tr('recordPayment')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _downloadPdf(context, job, invoice),
                                  icon: const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    size: 16,
                                  ),
                                  label: Text(context.tr('pdfInvoice')),
                                ),
                              ],
                              ElevatedButton.icon(
                                onPressed: () => _openWhatsAppDialog(
                                  context,
                                  job,
                                  invoice,
                                  WhatsAppNotificationType.invoiceSharing,
                                ),
                                icon: const AppWhatsAppIcon(
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(context.tr('shareOnWhatsApp')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: cardBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.report_problem_rounded,
                              color: AppColors.accentAmber,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('originalReportedWork'),
                              style: AppFonts.titleMedium(
                                color: primaryTextColor,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (job.complaints.isEmpty)
                          Text(
                            context.tr('generalServiceRequested'),
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          )
                        else
                          for (final complaint in job.complaints) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('•  '),
                                  Expanded(
                                    child: Text(
                                      complaint,
                                      style: AppFonts.bodyMedium(
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: cardBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.add_task_rounded,
                                  color: AppColors.accentBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.tr('extraWorkDetails'),
                                  style: AppFonts.titleMedium(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (!isCompleted)
                              IconButton(
                                tooltip: context.tr('addExtraWork'),
                                icon: const Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: AppColors.accentBlue,
                                ),
                                onPressed: () =>
                                    _openAddExtraWorkDialog(context, job),
                              ),
                          ],
                        ),
                        if (job.supplementalItems.isEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            context.tr('noExtraWorkRecorded'),
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                          if (!isCompleted) ...[
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  _openAddExtraWorkDialog(context, job),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: Text(context.tr('addExtraWork')),
                            ),
                          ],
                        ] else ...[
                          const SizedBox(height: 10),
                          for (final supp in job.supplementalItems) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sectionBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          supp.title,
                                          style:
                                              AppFonts.labelLarge(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if (supp.reason.isNotEmpty &&
                                            supp.reason != supp.title) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            supp.reason,
                                            style: AppFonts.bodySmall(
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(supp.totalAmount),
                                    style: AppFonts.titleSmall(
                                      color: AppColors.accentBlue,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('totalExtraWorkCharges'),
                                style: AppFonts.titleSmall(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                CurrencyFormatter.format(extraWorkTotal),
                                style: AppFonts.titleSmall(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          if (!isCompleted) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size.fromHeight(42),
                              ),
                              icon: const AppWhatsAppIcon(
                                size: 16,
                                color: Colors.white,
                              ),
                              label: Text(
                                context.tr('informCustomerExtraWork'),
                              ),
                              onPressed: () => _openWhatsAppDialog(
                                context,
                                job,
                                invoice,
                                WhatsAppNotificationType.extraWorkAdded,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                if (invoice != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: cardBg,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_rounded,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.tr('invoicePaymentSummary'),
                                    style: AppFonts.titleMedium(
                                      color: primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                invoice.invoiceNumber,
                                style: AppFonts.labelMedium(
                                  color: AppColors.accentBlue,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: sectionBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                for (final item in invoice.items) ...[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.description} (x${item.quantity})',
                                          style: AppFonts.bodySmall(
                                            color: primaryTextColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(
                                          item.totalPrice,
                                        ),
                                        style: AppFonts.bodySmall(
                                          color: primaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                if (invoice.discountAmount > 0) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Discount:',
                                        style: AppFonts.bodySmall(
                                          color: AppColors.error,
                                        ),
                                      ),
                                      Text(
                                        '-${CurrencyFormatter.format(invoice.discountAmount)}',
                                        style: AppFonts.bodySmall(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const Divider(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Final Bill Amount:',
                                      style: AppFonts.titleSmall(
                                        color: primaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(
                                        invoice.totalAmount,
                                      ),
                                      style: AppFonts.titleMedium(
                                        color: AppColors.accentBlue,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Amount Paid:',
                                      style: AppFonts.bodyMedium(
                                        color: AppColors.success,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(
                                        invoice.paidAmount,
                                      ),
                                      style: AppFonts.titleSmall(
                                        color: AppColors.success,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Balance Due:',
                                      style: AppFonts.titleSmall(
                                        color: invoice.balanceDue > 0
                                            ? AppColors.error
                                            : AppColors.success,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(
                                        invoice.balanceDue,
                                      ),
                                      style: AppFonts.titleSmall(
                                        color: invoice.balanceDue > 0
                                            ? AppColors.error
                                            : AppColors.success,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Job History & Status Timeline',
                  style: AppFonts.titleMedium(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  color: cardBg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StatusTimelineView(history: state.history),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
