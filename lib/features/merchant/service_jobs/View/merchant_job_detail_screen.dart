import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/customer/service_jobs/Widgets/status_timeline_view.dart';
import 'package:garage_card/features/shared/models/qc_checklist_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import '../ViewModel/merchant_jobs_view_model.dart';
import '../Widgets/add_supplemental_work_dialog.dart';
import '../Widgets/gate_pass_verification_dialog.dart';
import '../Widgets/job_status_dialog.dart';
import '../Widgets/qc_checklist_dialog.dart';

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

  void _openStatusDialog(BuildContext context, ServiceJobModel job) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return JobStatusDialog(
          currentStatus: job.status,
          customerName: job.customerName.isNotEmpty
              ? job.customerName
              : 'Customer',
          vehicleDisplay: job.vehicleDisplay,
          jobNumber: job.jobNumber,
          garageName: 'Apex Precision Automotive',
          customerPhone: job.customerPhone,
          customerWhatsApp: job.customerWhatsApp,
          onUpdateStatus: (newStatus, notes) {
            return ref
                .read(merchantJobsViewModelProvider.notifier)
                .updateStatus(
                  jobId: widget.jobId,
                  newStatus: newStatus,
                  notes: notes,
                );
          },
        );
      },
    );
  }

  void _openGatePassVerification(BuildContext context, ServiceJobModel job) {
    showDialog(
      context: context,
      builder: (ctx) => GatePassVerificationDialog(
        job: job,
        onVerify: (otp) => ref
            .read(merchantJobsViewModelProvider.notifier)
            .verifyGatePass(jobId: job.id, otp: otp),
      ),
    );
  }

  void _openQcDialog(BuildContext context, ServiceJobModel job) {
    showDialog(
      context: context,
      builder: (ctx) => QCChecklistDialog(
        job: job,
        onSave: (checklist, inspector) => ref
            .read(merchantJobsViewModelProvider.notifier)
            .updateQcChecklist(
              jobId: job.id,
              checklist: checklist,
              inspectorName: inspector,
            ),
      ),
    );
  }

  void _openSupplementalDialog(BuildContext context, ServiceJobModel job) {
    showDialog(
      context: context,
      builder: (ctx) => AddSupplementalWorkDialog(
        jobId: job.id,
        onAdd: (item) => ref
            .read(merchantJobsViewModelProvider.notifier)
            .addSupplementalWork(jobId: job.id, item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppCustomAppBar(
        title: job.jobNumber,
        subtitle: job.vehicleDisplay,
        actions: [
          IconButton(
            tooltip: 'Inform Customer via WhatsApp',
            icon: const Icon(Icons.chat_rounded, color: AppColors.success),
            onPressed: () => _openStatusDialog(context, job),
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
                            Text(
                              job.vehicleDisplay,
                              style: AppFonts.titleLarge(
                                color: primaryTextColor,
                              ),
                            ),
                            AppStatusBadge(status: job.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customer: ${job.customerName} • Odometer: ${job.odometerReading} km',
                          style: AppFonts.bodyMedium(color: secondaryTextColor),
                        ),
                        Text(
                          'Assigned Technician: ${job.technicianName.isNotEmpty ? job.technicianName : "Not assigned"}',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Update Status & Notify Customer',
                          onPressed: () => _openStatusDialog(context, job),
                          variant: AppButtonVariant.primary,
                          isFullWidth: true,
                          height: 44,
                        ),
                      ],
                    ),
                  ),
                ),
                if (job.status == 'readyForCollection' ||
                    job.status == 'completed') ...[
                  const SizedBox(height: 16),
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: job.isGatePassVerified
                            ? AppColors.success.withValues(alpha: 0.5)
                            : AppColors.accentBlue.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
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
                                  Icon(
                                    job.isGatePassVerified
                                        ? Icons.verified_user_rounded
                                        : Icons.qr_code_scanner_rounded,
                                    color: job.isGatePassVerified
                                        ? AppColors.success
                                        : AppColors.accentBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delivery Gate Pass Verification',
                                    style: AppFonts.titleMedium(
                                      color: primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              AppStatusBadge(
                                status: job.isGatePassVerified
                                    ? 'completed'
                                    : 'readyForCollection',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.isGatePassVerified
                                ? 'Vehicle release verified on ${DateFormatter.formatDateTime(job.gatePassVerifiedAt)}. Delivery completed.'
                                : 'Customer has been issued a 6-digit cryptographic OTP gate pass. Security or foreman must verify the OTP to release vehicle.',
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                          if (!job.isGatePassVerified) ...[
                            const SizedBox(height: 12),
                            AppButton(
                              label: 'Verify Gate OTP & Release Vehicle',
                              icon: const Icon(
                                Icons.security_rounded,
                                size: 16,
                              ),
                              variant: AppButtonVariant.primary,
                              isFullWidth: true,
                              height: 40,
                              onPressed: () =>
                                  _openGatePassVerification(context, job),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Card(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: job.isQcPassed
                          ? AppColors.success.withValues(alpha: 0.4)
                          : borderColor,
                    ),
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
                                Icon(
                                  job.isQcPassed
                                      ? Icons.verified_rounded
                                      : Icons.checklist_rtl_rounded,
                                  color: job.isQcPassed
                                      ? AppColors.success
                                      : AppColors.accentBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '9-Point QC Inspection',
                                  style: AppFonts.titleMedium(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (job.isQcPassed
                                            ? AppColors.success
                                            : AppColors.accentAmber)
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                job.isQcPassed
                                    ? 'Passed'
                                    : '${QCChecklistModel.passedCount(job.qcChecklist)}/9 Passed',
                                style: AppFonts.labelSmall(
                                  color: job.isQcPassed
                                      ? AppColors.success
                                      : AppColors.accentAmber,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          job.isQcPassed
                              ? 'Signed off by ${job.qcInspectorName ?? "Lead Technician"} on ${DateFormatter.formatDateTime(job.qcInspectedAt)}.'
                              : 'Mandatory pre-delivery quality inspection checklist before handing over vehicle.',
                          style: AppFonts.bodySmall(color: secondaryTextColor),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentBlue,
                            side: const BorderSide(color: AppColors.accentBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size.fromHeight(40),
                          ),
                          icon: const Icon(Icons.edit_note_rounded, size: 18),
                          label: Text(
                            job.isQcPassed
                                ? 'Review Checklist'
                                : 'Complete QC Checklist',
                          ),
                          onPressed: () => _openQcDialog(context, job),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: cardBg,
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
                                  Icons.add_alert_rounded,
                                  color: AppColors.accentAmber,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Supplemental Work',
                                  style: AppFonts.titleMedium(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            IconButton(
                              tooltip: 'Request Supplemental Work',
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.accentBlue,
                              ),
                              onPressed: () =>
                                  _openSupplementalDialog(context, job),
                            ),
                          ],
                        ),
                        if (job.supplementalItems.isEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'No unexpected damage or supplemental work requests recorded.',
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          for (final supp in job.supplementalItems) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.backgroundDark
                                    : AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          supp.title,
                                          style:
                                              AppFonts.titleSmall(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (supp.isApproved
                                                      ? AppColors.success
                                                      : supp.isDeclined
                                                      ? AppColors.error
                                                      : AppColors.accentAmber)
                                                  .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          supp.status.toUpperCase(),
                                          style:
                                              AppFonts.labelSmall(
                                                color: supp.isApproved
                                                    ? AppColors.success
                                                    : supp.isDeclined
                                                    ? AppColors.error
                                                    : AppColors.accentAmber,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    supp.reason,
                                    style: AppFonts.bodySmall(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Parts: ${CurrencyFormatter.format(supp.partsCost)} • Labor: ${CurrencyFormatter.format(supp.laborCost)} • Total: ${CurrencyFormatter.format(supp.totalAmount)}',
                                    style: AppFonts.labelSmall(
                                      color: primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Internal Mechanic Notes (Private)',
                          style: AppFonts.titleMedium(
                            color: AppColors.accentAmber,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.internalNotes.isNotEmpty
                              ? job.internalNotes
                              : 'No private mechanic notes added.',
                          style: AppFonts.bodyMedium(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Job History & Audit Log',
                  style: AppFonts.titleLarge(color: primaryTextColor),
                ),
                const SizedBox(height: 10),
                Card(
                  color: cardBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
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
