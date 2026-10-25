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

import '../ViewModel/customer_appointment_view_model.dart';
import '../Widgets/appointment_card.dart';

class CustomerAppointmentsScreen extends ConsumerWidget {
  const CustomerAppointmentsScreen({super.key});

  static Future<void> showBookingSheet(
    BuildContext context, {
    required String garageId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _BookAppointmentSheet(garageId: garageId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerAppointmentViewModelProvider);
    final vm = ref.read(customerAppointmentViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Appointments',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: AppResponsiveLayout(
          child: Builder(
            builder: (context) {
              if (state.isLoading) {
                return const AppLoading(message: 'Loading appointments...');
              }
              if (state.errorMessage != null && state.appointments.isEmpty) {
                return AppErrorState(
                  message: state.errorMessage!,
                  onRetry: vm.refresh,
                );
              }
              if (state.appointments.isEmpty) {
                return const AppEmptyState(
                  title: 'No Appointments Yet',
                  message: 'Find a nearby garage and tap "Request Service" to book your vehicle appointment.',
                  icon: Icons.calendar_today_rounded,
                );
              }
              return ListView.builder(
                itemCount: state.appointments.length,
                itemBuilder: (ctx, index) {
                  return AppointmentCard(
                    appointment: state.appointments[index],
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

class _BookAppointmentSheet extends ConsumerStatefulWidget {
  const _BookAppointmentSheet({required this.garageId});

  final String garageId;

  @override
  ConsumerState<_BookAppointmentSheet> createState() =>
      _BookAppointmentSheetState();
}

class _BookAppointmentSheetState extends ConsumerState<_BookAppointmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleCtrl = TextEditingController(text: '2022 Hyundai Creta');
  final _issueCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+91 98460 77112');
  final _nameCtrl = TextEditingController(text: 'Arjun Menon');

  String _selectedSlot = 'Morning (9:00 AM - 1:00 PM)';
  final DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _vehicleCtrl.dispose();
    _issueCtrl.dispose();
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(customerAppointmentViewModelProvider.notifier)
        .submitAppointmentRequest(
          garageId: widget.garageId,
          customerName: _nameCtrl.text.trim(),
          customerPhone: _phoneCtrl.text.trim(),
          vehicleInfo: _vehicleCtrl.text.trim(),
          preferredDate: _selectedDate,
          preferredTime: _selectedSlot,
          issueDescription: _issueCtrl.text.trim(),
        )
        .then((success) {
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Service request submitted to the garage!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerAppointmentViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

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
                'Request Service Appointment',
                style: AppFonts.titleLarge(color: primaryTextColor),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _vehicleCtrl,
                label: 'Vehicle Details',
                hint: 'e.g. 2022 Hyundai Creta (KL 07 CD 4488)',
                required: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _issueCtrl,
                label: 'Issue / Requested Service',
                hint: 'Describe brake noise, regular service, vibration, etc.',
                maxLines: 3,
                required: true,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please describe the issue' : null,
              ),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Preferred Time Slot',
                value: _selectedSlot,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSlot = val;
                    });
                  }
                },
                items: const [
                  AppDropdownItem(
                    value: 'Morning (9:00 AM - 1:00 PM)',
                    title: 'Morning (9:00 AM - 1:00 PM)',
                  ),
                  AppDropdownItem(
                    value: 'Afternoon (1:00 PM - 5:00 PM)',
                    title: 'Afternoon (1:00 PM - 5:00 PM)',
                  ),
                  AppDropdownItem(
                    value: 'Evening (5:00 PM - 7:30 PM)',
                    title: 'Evening (5:00 PM - 7:30 PM)',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Submit Service Request',
                onPressed: _submit,
                isLoading: state.isSubmitting,
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
