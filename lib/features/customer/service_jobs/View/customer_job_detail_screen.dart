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
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

import '../ViewModel/customer_jobs_view_model.dart';
import '../Widgets/digital_gate_pass_dialog.dart';
import '../Widgets/status_timeline_view.dart';

class CustomerJobDetailScreen extends ConsumerStatefulWidget {
  const CustomerJobDetailScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<CustomerJobDetailScreen> createState() =>
      _CustomerJobDetailScreenState();
}

class _CustomerJobDetailScreenState
    extends ConsumerState<CustomerJobDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(customerJobsViewModelProvider.notifier)
          .loadJobDetail(widget.jobId);
    });
  }

  void _openGatePassDialog(BuildContext context, ServiceJobModel job) {
    showDialog(
      context: context,
      builder: (ctx) => DigitalGatePassDialog(job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerJobsViewModelProvider);
    final vm = ref.read(customerJobsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    if (state.isLoadingDetail) {
      return const Scaffold(
        body: AppLoading(message: 'Loading live repair status...'),
      );
    }

    final job = state.selectedJob;
    if (job == null) {
      return Scaffold(
        appBar: const AppCustomAppBar(title: 'Repair Job'),
        body: AppErrorState(
          message: 'Job not found or permission denied.',
          onRetry: () => vm.loadJobDetail(widget.jobId),
        ),
      );
    }

    return Scaffold(
      appBar: AppCustomAppBar(
        title: job.jobNumber,
        subtitle: job.vehicleDisplay,
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
                            Expanded(
                              child: Text(
                                job.vehicleDisplay,
                                style: AppFonts.titleLarge(
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            AppStatusBadge(status: job.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Odometer: ${job.odometerReading} km • Tech: ${job.technicianName.isNotEmpty ? job.technicianName : "Assigned"}',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                        if (job.estimatedCompletionDate != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.infoBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event_available_rounded,
                                  color: AppColors.info,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Estimated Delivery: ${DateFormatter.formatDateTime(job.estimatedCompletionDate)}',
                                  style: AppFonts.labelSmall(
                                    color: AppColors.info,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openGatePassDialog(context, job),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (job.isGatePassVerified
                                            ? AppColors.success
                                            : AppColors.accentBlue)
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                job.isGatePassVerified
                                    ? Icons.verified_user_rounded
                                    : Icons.qr_code_2_rounded,
                                color: job.isGatePassVerified
                                    ? AppColors.success
                                    : AppColors.accentBlue,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.isGatePassVerified
                                        ? 'Vehicle Delivered & Released'
                                        : 'Digital Delivery Gate Pass Ready',
                                    style: AppFonts.titleMedium(
                                      color: primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    job.isGatePassVerified
                                        ? 'Exit gate verification completed'
                                        : 'Tap to view 6-digit OTP & collection QR',
                                    style: AppFonts.labelSmall(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppColors.textSecondaryLight,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                if (job.isQcPassed) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Automotive QC Cleared (9-Point Inspection)',
                                style: AppFonts.labelMedium(
                                  color: AppColors.success,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Inspected and certified by ${job.qcInspectorName ?? "Lead Technician"}.',
                                style: AppFonts.labelSmall(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (job.supplementalItems.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Supplemental Work Approvals',
                    style: AppFonts.titleLarge(color: primaryTextColor),
                  ),
                  const SizedBox(height: 10),
                  for (final item in job.supplementalItems) ...[
                    Card(
                      color: cardBg,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: item.isPending
                              ? AppColors.accentAmber
                              : item.isApproved
                              ? AppColors.success.withValues(alpha: 0.4)
                              : AppColors.error.withValues(alpha: 0.4),
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
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: AppFonts.titleMedium(
                                      color: primaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (item.isApproved
                                                ? AppColors.success
                                                : item.isDeclined
                                                ? AppColors.error
                                                : AppColors.accentAmber)
                                            .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.status.toUpperCase(),
                                    style: AppFonts.labelSmall(
                                      color: item.isApproved
                                          ? AppColors.success
                                          : item.isDeclined
                                          ? AppColors.error
                                          : AppColors.accentAmber,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.reason,
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Parts: ${CurrencyFormatter.format(item.partsCost)} • Labor: ${CurrencyFormatter.format(item.laborCost)}',
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ),
                                ),
                                Text(
                                  'Total: ${CurrencyFormatter.format(item.totalAmount)}',
                                  style: AppFonts.titleSmall(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (item.isPending) ...[
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(
                                          color: AppColors.error,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      onPressed: () =>
                                          vm.decideSupplementalWork(
                                            garageId: job.garageId,
                                            jobId: job.id,
                                            itemId: item.id,
                                            approved: false,
                                            reason: 'Declined by customer',
                                          ),
                                      child: const Text('Decline'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppButton(
                                      label:
                                          'Approve (+${CurrencyFormatter.format(item.totalAmount)})',
                                      variant: AppButtonVariant.primary,
                                      height: 38,
                                      onPressed: () =>
                                          vm.decideSupplementalWork(
                                            garageId: job.garageId,
                                            jobId: job.id,
                                            itemId: item.id,
                                            approved: true,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
                if (job.customerNotes.isNotEmpty) ...[
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
                            'Mechanic Notes for You',
                            style: AppFonts.titleMedium(
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.customerNotes,
                            style: AppFonts.bodyMedium(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Customer Reported Concerns',
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
                    child: Column(
                      children: job.complaints
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.arrow_right_rounded,
                                    color: AppColors.accentBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      c,
                                      style: AppFonts.bodyMedium(
                                        color: primaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Status Timeline',
                  style: AppFonts.titleLarge(color: primaryTextColor),
                ),
                const SizedBox(height: 12),
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
                    child: StatusTimelineView(
                      history: state.history,
                      showCustomerOnly: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Call Garage',
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            WhatsAppShareService.makePhoneCall('+919846012345'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Chat on WhatsApp',
                        icon: const Icon(Icons.chat_rounded, size: 18),
                        variant: AppButtonVariant.primary,
                        onPressed: () => WhatsAppShareService.sendWhatsAppMessage(
                          phoneNumber: '+919846012345',
                          message:
                              'Hello, I am asking about repair status for job ${job.jobNumber} (${job.vehicleDisplay}).',
                        ),
                      ),
                    ),
                  ],
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
