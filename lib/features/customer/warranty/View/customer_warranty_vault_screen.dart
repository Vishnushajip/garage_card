import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/warranty_item_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

class CustomerWarrantyVaultScreen extends ConsumerStatefulWidget {
  const CustomerWarrantyVaultScreen({super.key});

  @override
  ConsumerState<CustomerWarrantyVaultScreen> createState() =>
      _CustomerWarrantyVaultScreenState();
}

class _CustomerWarrantyVaultScreenState
    extends ConsumerState<CustomerWarrantyVaultScreen> {
  bool _isLoading = true;
  String? _error;
  List<WarrantyItemModel> _warranties = [];

  @override
  void initState() {
    super.initState();
    _loadWarranties();
  }

  Future<void> _loadWarranties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = ref.read(authViewModelProvider).userProfile;
      final customerId = user?.uid ?? '';
      final list = await ref
          .read(garageRepositoryProvider)
          .getCustomerWarranties(customerId);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _warranties = list;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: const AppCustomAppBar(
        title: 'Warranty Vault',
        subtitle: 'Digital parts coverage & guarantee certificates',
      ),
      body: AppRefresh(
        onRefresh: _loadWarranties,
        child: AppResponsiveLayout(
          child: Builder(
            builder: (context) {
              if (_isLoading) {
                return const AppLoading(message: 'Loading warranties...');
              }
              if (_error != null && _warranties.isEmpty) {
                return AppErrorState(
                  message: _error!,
                  onRetry: _loadWarranties,
                );
              }
              if (_warranties.isEmpty) {
                return const AppEmptyState(
                  title: 'No Warranties on File',
                  message: 'Genuine replacement parts with manufacturer warranties will appear here automatically upon invoice settlement.',
                  icon: Icons.verified_user_outlined,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _warranties.length,
                itemBuilder: (ctx, index) {
                  final w = _warranties[index];
                  final isActive = w.isActive;

                  return Card(
                    color: cardBg,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isActive
                            ? AppColors.success.withValues(alpha: 0.4)
                            : borderColor,
                        width: isActive ? 1.5 : 1.0,
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
                                  w.partName,
                                  style: AppFonts.titleLarge(
                                    color: primaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (isActive
                                              ? AppColors.success
                                              : AppColors.textSecondaryLight)
                                          .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isActive
                                      ? context.tr('active')
                                      : context.tr('expired'),
                                  style: AppFonts.labelSmall(
                                    color: isActive
                                        ? AppColors.success
                                        : secondaryTextColor,
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Issued by ${w.garageName}',
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Duration',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${w.durationMonths} Months (${w.coverageKm} km)',
                                      style: AppFonts.bodyMedium(
                                        color: primaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Status',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isActive
                                          ? '${w.remainingDays} days remaining'
                                          : 'Coverage ended',
                                      style: AppFonts.bodyMedium(
                                        color: isActive
                                            ? AppColors.success
                                            : secondaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Valid: ${DateFormatter.formatDate(w.startDate)} → ${DateFormatter.formatDate(w.expiryDate)}',
                                  style: AppFonts.labelSmall(
                                    color: secondaryTextColor,
                                  ),
                                ),
                                const Icon(
                                  Icons.verified_outlined,
                                  size: 16,
                                  color: AppColors.accentBlue,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Contact Garage About Warranty',
                            icon: const Icon(Icons.chat_rounded, size: 16),
                            variant: AppButtonVariant.secondary,
                            isFullWidth: true,
                            height: 40,
                            onPressed: () {
                              final msg =
                                  'Hello, I would like to inquire regarding warranty claim for ${w.partName} covered until ${DateFormatter.formatDate(w.expiryDate)}.';
                              WhatsAppShareService.sendWhatsAppMessage(
                                phoneNumber: '+919846012345',
                                message: msg,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
