import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import '../ViewModel/customer_reminders_view_model.dart';
import '../Widgets/reminder_card_item.dart';

class CustomerRemindersScreen extends ConsumerWidget {
  const CustomerRemindersScreen({super.key});

  void _showLogExternalSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _LogExternalServiceSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerRemindersViewModelProvider);
    final vm = ref.read(customerRemindersViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Service Reminders',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        actions: [
          IconButton(
            tooltip: 'Log External Service',
            icon: const Icon(Icons.add_task_rounded),
            onPressed: () => _showLogExternalSheet(context, ref),
          ),
        ],
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: AppResponsiveLayout(
          child: Builder(
            builder: (context) {
              if (state.isLoading) {
                return const AppLoading(message: 'Loading service reminders...');
              }
              if (state.errorMessage != null && state.reminders.isEmpty) {
                return AppErrorState(
                  message: state.errorMessage!,
                  onRetry: vm.refresh,
                );
              }
              if (state.reminders.isEmpty) {
                return AppEmptyState(
                  title: 'No Active Reminders',
                  message:
                      'Service reminders are automatically generated when repair jobs complete, or you can record external maintenance.',
                  icon: Icons.notifications_none_rounded,
                  actionLabel: 'Log External Service',
                  onAction: () => _showLogExternalSheet(context, ref),
                );
              }

              return ListView.builder(
                itemCount: state.reminders.length,
                itemBuilder: (ctx, index) {
                  return ReminderCardItem(
                    reminder: state.reminders[index],
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

class _LogExternalServiceSheet extends ConsumerStatefulWidget {
  const _LogExternalServiceSheet();

  @override
  ConsumerState<_LogExternalServiceSheet> createState() =>
      _LogExternalServiceSheetState();
}

class _LogExternalServiceSheetState
    extends ConsumerState<_LogExternalServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleDisplayCtrl =
      TextEditingController(text: '2022 Hyundai Creta (KL 07 CD 4488)');
  final _odometerCtrl = TextEditingController(text: '35000');
  final _notesCtrl = TextEditingController();

  String _selectedServiceType = 'Periodic Engine Oil Change';

  @override
  void dispose() {
    _vehicleDisplayCtrl.dispose();
    _odometerCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(customerRemindersViewModelProvider.notifier)
        .recordExternalService(
          vehicleId: 'veh_1',
          vehicleDisplay: _vehicleDisplayCtrl.text.trim(),
          serviceType: _selectedServiceType,
          serviceDate: DateTime.now(),
          odometerReading: int.tryParse(_odometerCtrl.text.trim()) ?? 0,
          notes: _notesCtrl.text.trim(),
        )
        .then((success) {
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'External service recorded. Next interval scheduled!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerRemindersViewModelProvider);
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
                'Log External Service Record',
                style: AppFonts.titleLarge(color: primaryTextColor),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _vehicleDisplayCtrl,
                label: 'Vehicle',
                required: true,
              ),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Service Type',
                value: _selectedServiceType,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedServiceType = val;
                    });
                  }
                },
                items: const [
                  AppDropdownItem(
                    value: 'Periodic Engine Oil Change',
                    title: 'Periodic Engine Oil Change',
                  ),
                  AppDropdownItem(
                    value: 'Brake Pad Replacement',
                    title: 'Brake Pad Replacement',
                  ),
                  AppDropdownItem(
                    value: 'Tyre Rotation & Alignment',
                    title: 'Tyre Rotation & Alignment',
                  ),
                  AppDropdownItem(
                    value: 'Battery Replacement',
                    title: 'Battery Replacement',
                  ),
                  AppDropdownItem(
                    value: 'Transmission Fluid Flush',
                    title: 'Transmission Fluid Flush',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _odometerCtrl,
                label: 'Odometer at Service (km)',
                keyboardType: TextInputType.number,
                required: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _notesCtrl,
                label: 'Service Notes / Parts Used',
                hint: 'e.g. Serviced at Shell quick lube, Mobil 1 5W-30 used.',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Save & Calculate Next Interval',
                onPressed: _submit,
                isLoading: state.isSaving,
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
