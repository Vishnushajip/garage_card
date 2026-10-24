import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';
import '../ViewModel/customer_jobs_view_model.dart';
import '../Widgets/status_timeline_view.dart';

class CustomerJobDetailScreen extends ConsumerStatefulWidget {
  const CustomerJobDetailScreen({
    super.key,
    required this.jobId,
  });

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerJobsViewModelProvider);
    final vm = ref.read(customerJobsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    if (state.isLoadingDetail) {
      return const Scaffold(
        body: AppLoading(message: 'Loading live repair status...'),
      );
    }

    final job = state.selectedJob;
    if (job == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          message: 'Job not found or permission denied.',
          onRetry: () => vm.loadJobDetail(widget.jobId),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          job.jobNumber,
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
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
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
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
                                style:
                                    AppFonts.titleLarge(color: primaryTextColor),
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
                            style: AppFonts.titleMedium(color: primaryTextColor),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.customerNotes,
                            style: AppFonts.bodyMedium(color: secondaryTextColor),
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
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
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
                      color:
                          isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StatusTimelineView(history: state.history),
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
                        onPressed: () =>
                            WhatsAppShareService.sendWhatsAppMessage(
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
