import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/customer/service_jobs/Widgets/status_timeline_view.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

import '../ViewModel/merchant_jobs_view_model.dart';
import '../Widgets/job_status_dialog.dart';

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

  void _openStatusDialog(BuildContext context, String currentStatus) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return JobStatusDialog(
          currentStatus: currentStatus,
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

    if (state.isLoading) {
      return const Scaffold(body: AppLoading(message: 'Loading job record...'));
    }

    final job = state.selectedJob;
    if (job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          message: 'Job record not found.',
          onRetry: () => vm.selectJob(widget.jobId),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          job.jobNumber,
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        actions: [
          IconButton(
            tooltip: 'Send WhatsApp Update',
            icon: const Icon(Icons.chat_rounded, color: AppColors.success),
            onPressed: () {
              final msg = WhatsAppShareService.composeJobStatusMessage(
                customerName: job.customerName,
                garageName: 'Apex Precision Automotive',
                vehicleDisplay: job.vehicleDisplay,
                jobNumber: job.jobNumber,
                status: job.status.toUpperCase(),
                notes: job.customerNotes,
              );
              WhatsAppShareService.sendWhatsAppMessage(
                phoneNumber: '+919846077112',
                message: msg,
              );
            },
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
                          onPressed: () =>
                              _openStatusDialog(context, job.status),
                          variant: AppButtonVariant.primary,
                          isFullWidth: true,
                          height: 44,
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
