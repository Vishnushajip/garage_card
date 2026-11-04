import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';

import 'job_whatsapp_share_dialog.dart';

class CreateJobDialog extends ConsumerStatefulWidget {
  const CreateJobDialog({super.key});

  @override
  ConsumerState<CreateJobDialog> createState() => _CreateJobDialogState();
}

class _CreateJobDialogState extends ConsumerState<CreateJobDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCustomerId;
  bool _isNewCustomer = false;

  final TextEditingController _customerNameCtrl = TextEditingController();
  final TextEditingController _customerPhoneCtrl = TextEditingController();
  final TextEditingController _bikeNumberCtrl = TextEditingController();
  final TextEditingController _bikeModelCtrl = TextEditingController();
  final TextEditingController _bikeProblemCtrl = TextEditingController();

  String? _selectedMechanic;
  bool _isCustomMechanic = false;
  final TextEditingController _customMechanicCtrl = TextEditingController();

  static const List<String> _defaultMechanics = [
    'Suresh Kumar',
    'Rahul Nair',
    'Anand K',
    'Manoj P',
  ];

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _bikeNumberCtrl.dispose();
    _bikeModelCtrl.dispose();
    _bikeProblemCtrl.dispose();
    _customMechanicCtrl.dispose();
    super.dispose();
  }

  void _onCustomerSelected(String? value) {
    if (value == '__new__') {
      setState(() {
        _isNewCustomer = true;
        _selectedCustomerId = null;
        _customerNameCtrl.clear();
        _customerPhoneCtrl.clear();
      });
    } else if (value != null) {
      final state = ref.read(merchantJobsViewModelProvider);
      final cust = state.customers.where((c) => c.id == value).firstOrNull;
      setState(() {
        _isNewCustomer = false;
        _selectedCustomerId = value;
        if (cust != null) {
          _customerNameCtrl.text = cust.name;
          _customerPhoneCtrl.text = cust.phone;
        }
      });
    }
  }

  void _onMechanicSelected(String? value) {
    if (value == '__custom__') {
      setState(() {
        _isCustomMechanic = true;
        _selectedMechanic = null;
        _customMechanicCtrl.clear();
      });
    } else {
      setState(() {
        _isCustomMechanic = false;
        _selectedMechanic = value;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final customerName = _customerNameCtrl.text.trim();
    final customerPhone = _customerPhoneCtrl.text.trim();
    final bikeNumber = _bikeNumberCtrl.text.trim().toUpperCase();
    final bikeModel = _bikeModelCtrl.text.trim();
    final problem = _bikeProblemCtrl.text.trim();
    final mechanicName = _isCustomMechanic
        ? _customMechanicCtrl.text.trim()
        : (_selectedMechanic ?? '');

    if (mechanicName.isEmpty) {
      AppNotificationService.warning(
        'Please select or enter an assigned mechanic',
      );
      return;
    }

    final success = await ref
        .read(merchantJobsViewModelProvider.notifier)
        .createJob(
          customerName: customerName,
          customerPhone: customerPhone,
          bikeNumber: bikeNumber,
          bikeModel: bikeModel,
          problem: problem,
          mechanicName: mechanicName,
          customerId: _selectedCustomerId,
        );

    if (success && mounted) {
      Navigator.of(context).pop();
      AppNotificationService.success('Repair job order created successfully');

      if (customerPhone.isNotEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => JobWhatsAppShareDialog(
            type: WhatsAppNotificationType.jobCreated,
            customerName: customerName,
            customerPhone: customerPhone,
            bikeNumber: bikeNumber,
            bikeModel: bikeModel,
            problem: problem,
            jobNumber: 'Job Order',
            mechanic: mechanicName,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantJobsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final dialogBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final mechanicSet = <String>{..._defaultMechanics};
    for (final job in state.jobs) {
      if (job.technicianName.trim().isNotEmpty) {
        mechanicSet.add(job.technicianName.trim());
      }
    }
    final mechanicList = mechanicSet.toList();

    final customerOptions = [
      const AppDropdownItem(value: '__new__', title: '+ Add New Customer'),
      ...state.customers.map((c) {
        final phoneText = c.phone.isNotEmpty ? ' (${c.phone})' : '';
        return AppDropdownItem(value: c.id, title: '${c.name}$phoneText');
      }),
    ];

    final mechanicOptions = [
      ...mechanicList.map((m) => AppDropdownItem(value: m, title: m)),
      const AppDropdownItem(
        value: '__custom__',
        title: '+ Add Custom Mechanic',
      ),
    ];

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.two_wheeler_rounded,
                            color: AppColors.accentBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'New Bike Job Order',
                          style: AppFonts.titleLarge(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '1. Customer Details',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                AppDropdown<String>(
                  label: 'Select Customer',
                  value: _isNewCustomer ? '__new__' : _selectedCustomerId,
                  items: customerOptions,
                  hint: state.customers.isEmpty
                      ? '+ Add New Customer'
                      : 'Choose customer or add new...',
                  onChanged: _onCustomerSelected,
                ),
                if (_isNewCustomer || state.customers.isEmpty) ...[
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _customerNameCtrl,
                    label: 'Customer Name',
                    hint: 'e.g. Rahul Sharma',
                    required: true,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Customer name is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _customerPhoneCtrl,
                    label: 'Mobile / WhatsApp Number',
                    hint: 'e.g. 9847123456',
                    keyboardType: TextInputType.phone,
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  '2. Vehicle Information',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: AppTextField(
                        controller: _bikeNumberCtrl,
                        label: 'Bike Registration Number',
                        hint: 'e.g. KL 11 AH 2045',
                        inputFormatters: [
                          TextInputFormatter.withFunction(
                            (old, val) =>
                                val.copyWith(text: val.text.toUpperCase()),
                          ),
                        ],
                        required: true,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Registration number is required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: AppTextField(
                        controller: _bikeModelCtrl,
                        label: 'Bike Model (Optional)',
                        hint: 'e.g. Classic 350, FZ',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '3. Reported Problem / Work',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _bikeProblemCtrl,
                  label: 'Customer Complaint / Work Needed',
                  hint: 'Describe customer reported problem (e.g. Engine oil change, brake loose, chain sound)...',
                  maxLines: 3,
                  required: true,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please describe the bike problem'
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  '4. Assigned Mechanic',
                  style: AppFonts.titleSmall(color: AppColors.accentBlue)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                AppDropdown<String>(
                  label: 'Assigned Mechanic',
                  value: _isCustomMechanic ? '__custom__' : _selectedMechanic,
                  items: mechanicOptions,
                  hint: 'Select mechanic...',
                  onChanged: _onMechanicSelected,
                ),
                if (_isCustomMechanic) ...[
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _customMechanicCtrl,
                    label: 'New Mechanic Name',
                    hint: 'e.g. Shaji Kumar',
                    required: true,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Mechanic name is required'
                        : null,
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(),
                        height: 46,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Create Job Order',
                        icon: const Icon(Icons.check_rounded, size: 18),
                        onPressed: state.isCreatingJob ? null : _submit,
                        isLoading: state.isCreatingJob,
                        height: 46,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
