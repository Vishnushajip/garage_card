import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/merchant/service_jobs/ViewModel/merchant_jobs_view_model.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/add_customer_bottom_sheet.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/add_mechanic_bottom_sheet.dart';
import 'package:garage_card/features/merchant/service_jobs/Widgets/job_whatsapp_share_dialog.dart';

class MerchantCreateJobScreen extends ConsumerStatefulWidget {
  const MerchantCreateJobScreen({super.key});

  @override
  ConsumerState<MerchantCreateJobScreen> createState() =>
      _MerchantCreateJobScreenState();
}

class _MerchantCreateJobScreenState
    extends ConsumerState<MerchantCreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCustomerId;
  final TextEditingController _customerNameCtrl = TextEditingController();
  final TextEditingController _customerPhoneCtrl = TextEditingController();

  final TextEditingController _bikeNumberCtrl = TextEditingController();
  final TextEditingController _bikeModelCtrl = TextEditingController();
  final TextEditingController _bikeProblemCtrl = TextEditingController();

  String? _selectedMechanic;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(merchantJobsViewModelProvider.notifier)
          .loadCustomers(refresh: true);
      ref
          .read(merchantJobsViewModelProvider.notifier)
          .loadMechanics(refresh: true);
    });
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _bikeNumberCtrl.dispose();
    _bikeModelCtrl.dispose();
    _bikeProblemCtrl.dispose();
    super.dispose();
  }

  void _onCustomerSelected(String? value) {
    if (value == '__add_new__') {
      _openAddCustomerSheet();
      return;
    }
    if (value == '__load_more__') {
      ref.read(merchantJobsViewModelProvider.notifier).fetchNextCustomersPage();
      return;
    }
    if (value != null) {
      final state = ref.read(merchantJobsViewModelProvider);
      final cust = state.customers.where((c) => c.id == value).firstOrNull;
      setState(() {
        _selectedCustomerId = value;
        if (cust != null) {
          _customerNameCtrl.text = cust.name;
          _customerPhoneCtrl.text = cust.phone;
        }
      });
    }
  }

  Future<void> _openAddCustomerSheet() async {
    final newCust = await AddCustomerBottomSheet.show(context);
    if (newCust != null && mounted) {
      setState(() {
        _selectedCustomerId = newCust.id;
        _customerNameCtrl.text = newCust.name;
        _customerPhoneCtrl.text = newCust.phone;
      });
    }
  }

  void _onMechanicSelected(String? value) {
    if (value == '__add_new__') {
      _openAddMechanicSheet();
      return;
    }
    if (value == '__load_more__') {
      ref.read(merchantJobsViewModelProvider.notifier).fetchNextMechanicsPage();
      return;
    }
    setState(() {
      _selectedMechanic = value;
    });
  }

  Future<void> _openAddMechanicSheet() async {
    final newMech = await AddMechanicBottomSheet.show(context);
    if (newMech != null && mounted) {
      setState(() {
        _selectedMechanic = newMech.name;
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
    final mechanicName = _selectedMechanic?.trim() ?? '';

    if (mechanicName.isEmpty) {
      AppNotificationService.warning(context.tr('pleaseSelectMechanic'));
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
      AppNotificationService.success(context.tr('jobCreatedSuccess'));
      Navigator.of(context).pop();

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
    ref.watch(localeProvider);
    final state = ref.watch(merchantJobsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    final customerDropdownItems = <AppDropdownItem<String>>[
      AppDropdownItem(
        value: '__add_new__',
        title: context.tr('addNewCustomerDb'),
      ),
      ...state.customers.map((c) {
        final phoneText = c.phone.isNotEmpty ? ' • ${c.phone}' : '';
        return AppDropdownItem(value: c.id, title: '${c.name}$phoneText');
      }),
      if (state.hasMoreCustomers && state.customers.isNotEmpty)
        AppDropdownItem(
          value: '__load_more__',
          title: context.tr('loadMoreCustomers'),
        ),
    ];

    final mechanicDropdownItems = <AppDropdownItem<String>>[
      AppDropdownItem(
        value: '__add_new__',
        title: context.tr('addNewMechanicDb'),
      ),
      ...state.mechanics.map((m) {
        final specText = m.specialization.isNotEmpty
            ? ' (${m.specialization})'
            : '';
        return AppDropdownItem(value: m.name, title: '${m.name}$specText');
      }),
      if (state.hasMoreMechanics && state.mechanics.isNotEmpty)
        AppDropdownItem(
          value: '__load_more__',
          title: context.tr('loadMoreMechanics'),
        ),
    ];

    final bikeNumberField = AppTextField(
      controller: _bikeNumberCtrl,
      label: context.tr('bikeRegNumber'),
      hint: 'e.g. KL 11 AH 2045',
      prefixIcon: const Icon(Icons.pin_outlined, size: 18),
      inputFormatters: [
        TextInputFormatter.withFunction(
          (old, val) => val.copyWith(text: val.text.toUpperCase()),
        ),
      ],
      required: true,
      validator: (v) =>
          v == null || v.trim().isEmpty ? context.tr('bikeRegRequired') : null,
    );

    final bikeModelField = AppTextField(
      controller: _bikeModelCtrl,
      label: context.tr('bikeModelOptional'),
      hint: 'e.g. Classic 350, Pulsar 150, FZ',
      prefixIcon: const Icon(Icons.two_wheeler_rounded, size: 18),
    );

    return Scaffold(
      appBar: AppCustomAppBar(title: context.tr('newJobOrder')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppResponsiveLayout.kMaxFormWidth,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 360) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentBlue
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline_rounded,
                                          color: AppColors.accentBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          context.tr('customerDetails'),
                                          style:
                                              AppFonts.titleMedium(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _openAddCustomerSheet,
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                      ),
                                      label: Text(context.tr('addNewCustomer')),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.accentBlue,
                                        textStyle: AppFonts.bodySmall(
                                          color: AppColors.accentBlue,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentBlue
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline_rounded,
                                          color: AppColors.accentBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          context.tr('customerDetails'),
                                          style:
                                              AppFonts.titleMedium(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _openAddCustomerSheet,
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: Text(context.tr('addNewCustomer')),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.accentBlue,
                                    textStyle: AppFonts.bodySmall(
                                      color: AppColors.accentBlue,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        AppDropdown<String>(
                          label: context.tr('selectCustomerFromDb'),
                          value: _selectedCustomerId,
                          items: customerDropdownItems,
                          hint: state.isLoadingCustomers
                              ? context.tr('loadingCustomersFromDb')
                              : (state.customers.isEmpty
                                    ? context.tr('noCustomersFoundAdd')
                                    : context.tr('chooseExistingCustomer')),
                          onChanged: _onCustomerSelected,
                        ),
                        if (state.isLoadingCustomers) ...[
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _customerNameCtrl,
                          label: context.tr('customerName'),
                          hint: context.tr('enterFullName'),
                          prefixIcon: const Icon(
                            Icons.person_rounded,
                            size: 18,
                          ),
                          required: true,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('customerNameRequired')
                              : null,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _customerPhoneCtrl,
                          label: context.tr('phoneWhatsAppNumber'),
                          hint: 'e.g. 9847123456',
                          prefixIcon: const Icon(Icons.phone_rounded, size: 18),
                          keyboardType: TextInputType.phone,
                          required: true,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('customerPhoneRequired')
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.two_wheeler_rounded,
                                color: AppColors.accentBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr('vehicleInformation'),
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 600) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  bikeNumberField,
                                  const SizedBox(height: 14),
                                  bikeModelField,
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 6, child: bikeNumberField),
                                const SizedBox(width: 14),
                                Expanded(flex: 5, child: bikeModelField),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.build_circle_outlined,
                                color: AppColors.accentBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr('reportedProblemComplaints'),
                                style: AppFonts.titleMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _bikeProblemCtrl,
                          label: context.tr('customerComplaintWorkNeeded'),
                          hint: 'Describe issues reported by customer (e.g. Engine oil change, front disc pad replacement, chain noise)...',
                          maxLines: 4,
                          minLines: 2,
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                          ),
                          required: true,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? context.tr('describeBikeProblem')
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 360) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentBlue
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.engineering_rounded,
                                          color: AppColors.accentBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          context.tr('assignedMechanic'),
                                          style:
                                              AppFonts.titleMedium(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _openAddMechanicSheet,
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        size: 16,
                                      ),
                                      label: Text(context.tr('addNewMechanic')),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.accentBlue,
                                        textStyle: AppFonts.bodySmall(
                                          color: AppColors.accentBlue,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentBlue
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.engineering_rounded,
                                          color: AppColors.accentBlue,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          context.tr('assignedMechanic'),
                                          style:
                                              AppFonts.titleMedium(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _openAddMechanicSheet,
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: Text(context.tr('addNewMechanic')),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.accentBlue,
                                    textStyle: AppFonts.bodySmall(
                                      color: AppColors.accentBlue,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        if (state.mechanics.isEmpty &&
                            !state.isLoadingMechanics) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentAmber.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.accentAmber.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.accentAmber,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.tr('noMechanicsInDb'),
                                    style: AppFonts.bodySmall(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        AppDropdown<String>(
                          label: context.tr('assignedMechanic'),
                          value: _selectedMechanic,
                          items: mechanicDropdownItems,
                          hint: state.isLoadingMechanics
                              ? context.tr('loadingMechanicsFromDb')
                              : (state.mechanics.isEmpty
                                    ? context.tr('addNewMechanicDb')
                                    : context.tr('selectMechanicFromDb')),
                          onChanged: _onMechanicSelected,
                        ),
                        if (state.isLoadingMechanics) ...[
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: context.tr('cancel'),
                          variant: AppButtonVariant.outline,
                          onPressed: () => Navigator.of(context).pop(),
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          label: context.tr('createJobOrder'),
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20,
                          ),
                          onPressed: state.isCreatingJob ? null : _submit,
                          isLoading: state.isCreatingJob,
                          height: 48,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
