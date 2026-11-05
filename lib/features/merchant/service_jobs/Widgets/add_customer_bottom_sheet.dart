import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';

import '../ViewModel/merchant_jobs_view_model.dart';

class AddCustomerBottomSheet extends ConsumerStatefulWidget {
  const AddCustomerBottomSheet({super.key});

  static Future<CustomerModel?> show(BuildContext context) {
    return showModalBottomSheet<CustomerModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AddCustomerBottomSheet(),
    );
  }

  @override
  ConsumerState<AddCustomerBottomSheet> createState() =>
      _AddCustomerBottomSheetState();
}

class _AddCustomerBottomSheetState
    extends ConsumerState<AddCustomerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    final saved = await ref
        .read(merchantJobsViewModelProvider.notifier)
        .addCustomer(name: name, phone: phone, address: address);

    if (saved != null && mounted) {
      AppNotificationService.success(context.tr('customerAddedSuccess'));
      Navigator.of(context).pop(saved);
    } else if (mounted) {
      AppNotificationService.error(context.tr('customerAddFailed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final state = ref.watch(merchantJobsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.surfaceDark
        : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                            Icons.person_add_rounded,
                            color: AppColors.accentBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.tr('addNewCustomer'),
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
                const SizedBox(height: 18),
                AppTextField(
                  controller: _nameCtrl,
                  label: context.tr('customerFullName'),
                  hint: 'e.g. Rahul Sharma',
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                  ),
                  required: true,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? context.tr('customerNameRequired')
                      : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _phoneCtrl,
                  label: context.tr('phoneWhatsAppNumber'),
                  hint: 'e.g. 9847123456',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                  keyboardType: TextInputType.phone,
                  required: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.tr('customerPhoneRequired');
                    }
                    if (v.trim().length < 8) {
                      return context.tr('enterValidPhone');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _addressCtrl,
                  label: context.tr('addressLocationOptional'),
                  hint: 'e.g. MG Road, Kochi',
                  prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: context.tr('cancel'),
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.of(context).pop(),
                        height: 46,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: context.tr('saveCustomer'),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        onPressed: state.isAddingCustomer ? null : _submit,
                        isLoading: state.isAddingCustomer,
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
