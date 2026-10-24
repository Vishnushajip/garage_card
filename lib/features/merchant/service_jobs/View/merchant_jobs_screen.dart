import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/pagination/proactive_scroll_listener.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import '../ViewModel/merchant_jobs_view_model.dart';
import 'merchant_job_detail_screen.dart';

class MerchantJobsScreen extends ConsumerStatefulWidget {
  const MerchantJobsScreen({super.key});

  @override
  ConsumerState<MerchantJobsScreen> createState() => _MerchantJobsScreenState();
}

class _MerchantJobsScreenState extends ConsumerState<MerchantJobsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late final ProactiveScrollListener _scrollListener;

  @override
  void initState() {
    super.initState();
    _scrollListener = ProactiveScrollListener(
      onPrefetchRequested: () {},
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showNewJobSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _NewJobSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantJobsViewModelProvider);
    final vm = ref.read(merchantJobsViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Jobs Management',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener.handleScrollNotification,
        child: AppRefresh(
          onRefresh: vm.refresh,
          child: AppResponsiveLayout(
            child: Column(
              children: [
                AppTextField(
                  controller: _searchCtrl,
                  hint: 'Search by job number, customer or vehicle...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            vm.search('');
                          },
                        )
                      : null,
                  onChanged: vm.search,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state.isLoading) {
                        return const AppLoading(message: 'Loading jobs...');
                      }
                      if (state.errorMessage != null && state.jobs.isEmpty) {
                        return AppErrorState(
                          message: state.errorMessage!,
                          onRetry: vm.refresh,
                        );
                      }
                      if (state.jobs.isEmpty) {
                        return AppEmptyState(
                          title: 'No Repair Jobs Found',
                          message: 'Create a new job order when a vehicle arrives.',
                          icon: Icons.car_repair_rounded,
                          actionLabel: 'Create New Job',
                          onAction: () => _showNewJobSheet(context),
                        );
                      }

                      return ListView.separated(
                        itemCount: state.jobs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (ctx, index) {
                          final job = state.jobs[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MerchantJobDetailScreen(jobId: job.id),
                                  ),
                                );
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    job.jobNumber,
                                    style: AppFonts.labelLarge(
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      job.vehicleDisplay,
                                      style: AppFonts.bodyLarge(
                                        color: primaryTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Customer: ${job.customerName} • Tech: ${job.technicianName.isNotEmpty ? job.technicianName : "Unassigned"}',
                                style: AppFonts.labelSmall(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewJobSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Job Order'),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _NewJobSheet extends ConsumerStatefulWidget {
  const _NewJobSheet();

  @override
  ConsumerState<_NewJobSheet> createState() => _NewJobSheetState();
}

class _NewJobSheetState extends ConsumerState<_NewJobSheet> {
  final _formKey = GlobalKey<FormState>();
  final _custCtrl = TextEditingController(text: 'Arjun Menon');
  final _vehCtrl =
      TextEditingController(text: '2022 Hyundai Creta (KL 07 CD 4488)');
  final _complaintCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController(text: '34500');
  final _techCtrl = TextEditingController(text: 'Suresh Kumar');

  @override
  void dispose() {
    _custCtrl.dispose();
    _vehCtrl.dispose();
    _complaintCtrl.dispose();
    _odometerCtrl.dispose();
    _techCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(merchantJobsViewModelProvider.notifier)
        .createJob(
          customerName: _custCtrl.text.trim(),
          vehicleDisplay: _vehCtrl.text.trim(),
          complaint: _complaintCtrl.text.trim(),
          odometerReading: int.tryParse(_odometerCtrl.text.trim()) ?? 0,
          technicianName: _techCtrl.text.trim(),
        )
        .then((success) {
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Repair job created and logged successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantJobsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Open New Repair Job Order',
                style: AppFonts.titleLarge(color: primaryTextColor),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _custCtrl,
                label: 'Customer Name',
                required: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _vehCtrl,
                label: 'Vehicle (Year Make Model Plate)',
                required: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _complaintCtrl,
                label: 'Primary Concern / Customer Request',
                hint: 'e.g. Brake vibration, Periodic Service, AC weak...',
                maxLines: 2,
                required: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _odometerCtrl,
                      label: 'Odometer (km)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _techCtrl,
                      label: 'Assigned Mechanic',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Create Repair Job',
                onPressed: _save,
                isLoading: state.isCreatingJob,
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
