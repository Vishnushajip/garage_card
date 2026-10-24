import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/features/shared/models/customer_model.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

class MerchantCustomerCard extends StatelessWidget {
  const MerchantCustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  final CustomerModel customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty
                          ? customer.name[0].toUpperCase()
                          : 'C',
                      style: AppFonts.titleLarge(color: AppColors.accentBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppFonts.titleMedium(color: primaryTextColor),
                      ),
                      Text(
                        customer.phone,
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.phone_rounded,
                      color: AppColors.accentBlue, size: 20),
                  onPressed: () =>
                      WhatsAppShareService.makePhoneCall(customer.phone),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_rounded,
                      color: AppColors.success, size: 20),
                  onPressed: () => WhatsAppShareService.sendWhatsAppMessage(
                    phoneNumber: customer.phone,
                    message: 'Hello ${customer.name}, message from your garage.',
                  ),
                ),
              ],
            ),
            if (customer.address.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                customer.address,
                style: AppFonts.bodyMedium(color: secondaryTextColor),
              ),
            ],
            if (customer.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.inputFillLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Note: ${customer.notes}',
                  style: AppFonts.labelSmall(color: secondaryTextColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
