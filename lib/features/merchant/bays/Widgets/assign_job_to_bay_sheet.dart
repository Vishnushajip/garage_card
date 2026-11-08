import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_loading_state.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

class AssignJobToBaySheet extends ConsumerStatefulWidget {
  const AssignJobToBaySheet({
    super.key,
    required this.bayName,
    required this.onSelectJob,
  });

  final String bayName;
  final void Function(ServiceJobModel job) onSelectJob;

  static Future<void> show(
    BuildContext context, {
    required String bayName,
    required void Function(ServiceJobModel job) onSelectJob,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) =>
          AssignJobToBaySheet(bayName: bayName, onSelectJob: onSelectJob),
    );
  }

  @override
  ConsumerState<AssignJobToBaySheet> createState() =>
      _AssignJobToBaySheetState();
}

class _AssignJobToBaySheetState extends ConsumerState<AssignJobToBaySheet> {
  bool _isLoading = true;
  List<ServiceJobModel> _activeJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchActiveJobs();
  }

  Future<void> _fetchActiveJobs() async {
    final user = ref.read(authViewModelProvider).userProfile;
    final garageId = user?.garageId ?? '';
    if (garageId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await ref
          .read(garageRepositoryProvider)
          .getServiceJobsPaginated(garageId: garageId, limit: 30);

      final unassigned = res.items.where((j) {
        final s = j.status.toLowerCase();
        return s != 'completed' && s != 'delivered' && s != 'cancelled';
      }).toList();

      if (mounted) {
        setState(() {
          _activeJobs = unassigned;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.garage_rounded, color: AppColors.accentBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${context.tr("assignJob")}: ${widget.bayName}',
                  style: AppFonts.titleMedium(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('selectJobToAssign'),
            style: AppFonts.bodySmall(color: secondaryTextColor),
          ),
          const SizedBox(height: 14),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: AppLoadingState()),
            )
          else if (_activeJobs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 40,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('noActiveJobsToAssign'),
                      style: AppFonts.bodyMedium(color: secondaryTextColor),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _activeJobs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, index) {
                  final job = _activeJobs[index];
                  return InkWell(
                    onTap: () {
                      widget.onSelectJob(job);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.two_wheeler_rounded,
                              size: 18,
                              color: AppColors.accentBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.vehicleDisplay.isNotEmpty
                                      ? job.vehicleDisplay
                                      : job.jobNumber,
                                  style: AppFonts.bodyMedium(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${job.jobNumber} • ${job.customerName}${job.technicianName.isNotEmpty ? " • Mech: ${job.technicianName}" : ""}',
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.accentBlue,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
