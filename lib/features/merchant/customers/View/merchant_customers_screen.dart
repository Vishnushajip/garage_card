import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/utils/debouncer.dart';

import '../ViewModel/merchant_customers_view_model.dart';
import '../Widgets/merchant_customer_card.dart';

class MerchantCustomersScreen extends ConsumerStatefulWidget {
  const MerchantCustomersScreen({super.key});

  @override
  ConsumerState<MerchantCustomersScreen> createState() =>
      _MerchantCustomersScreenState();
}

class _MerchantCustomersScreenState
    extends ConsumerState<MerchantCustomersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Debouncer _debouncer = Debouncer();

  @override
  void dispose() {
    _debouncer.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddCustomerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AddCustomerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantCustomersViewModelProvider);
    final vm = ref.read(merchantCustomersViewModelProvider.notifier);

    return Scaffold(
      appBar: const AppCustomAppBar(
        title: 'Customer Directory',
        subtitle: 'Manage registered vehicle owners & contacts',
        showAccountSwitch: true,
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: AppResponsiveLayout(
          child: Column(
            children: [
              AppTextField(
                controller: _searchCtrl,
                hint: 'Search by customer name, phone number, or email...',
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
                onChanged: (val) {
                  _debouncer.run(() => vm.search(val));
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading) {
                      return const AppLoading(message: 'Loading customers...');
                    }
                    if (state.errorMessage != null && state.customers.isEmpty) {
                      return AppErrorState(
                        message: state.errorMessage!,
                        onRetry: vm.refresh,
                      );
                    }
                    if (state.customers.isEmpty) {
                      return AppEmptyState(
                        title: 'No Customers Found',
                        message: 'Add new customers to track their vehicles and jobs.',
                        icon: Icons.people_outline_rounded,
                        actionLabel: 'Add Customer',
                        onAction: () => _showAddCustomerSheet(context),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.customers.length,
                      itemBuilder: (ctx, index) {
                        final cust = state.customers[index];
                        return MerchantCustomerCard(
                          customer: cust,
                          onTap: () {},
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCustomerSheet(context),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Customer'),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AddCustomerSheet extends ConsumerStatefulWidget {
  const _AddCustomerSheet();

  @override
  ConsumerState<_AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends ConsumerState<_AddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(merchantCustomersViewModelProvider.notifier)
        .addCustomer(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          whatsappNumber: _whatsappCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
        )
        .then((success) {
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Customer registered successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantCustomersViewModelProvider);
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
                'Register New Customer',
                style: AppFonts.titleLarge(color: primaryTextColor),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameCtrl,
                label: 'Customer Name',
                hint: 'e.g. Suresh Varma',
                required: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Phone Number (Calling)',
                hint: 'e.g. +91 98460 11223',
                keyboardType: TextInputType.phone,
                required: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'WhatsApp Number (Repair Updates)',
                      style: AppFonts.labelLarge(color: primaryTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _whatsappCtrl.text = _phoneCtrl.text;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Same as Phone',
                            style: AppFonts.labelSmall(
                              color: AppColors.accentBlue,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AppTextField(
                controller: _whatsappCtrl,
                hint: 'e.g. +91 98460 11223',
                helperText: 'Automated status updates & estimates will be sent to this WhatsApp number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 20,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emailCtrl,
                label: 'Email Address',
                hint: 'e.g. suresh@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _addressCtrl,
                label: 'Address / Locality',
                hint: 'e.g. Kakkanad, Kochi',
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _notesCtrl,
                label: 'Customer Preferences / Notes',
                hint: 'e.g. Requires synthetic oil only...',
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Save Customer',
                onPressed: _save,
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
