import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/notifications/fcm_notification_sender.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';
import 'package:go_router/go_router.dart';

class CustomerInquiryService {
  CustomerInquiryService._();

  static Future<void> startInquiry(
    BuildContext context,
    WidgetRef ref, {
    required GarageModel garage,
    GarageServiceModel? package,
    String? customMessage,
  }) async {
    final authUser = ref.read(authViewModelProvider).userProfile;
    final customerId = authUser?.uid ?? 'cust_guest';
    final customerName =
        (authUser?.fullName.isNotEmpty == true && authUser?.fullName != 'User')
        ? authUser!.fullName
        : 'Customer';

    String? phone = authUser?.phoneNumber;
    if (phone == null || phone.trim().isEmpty) {
      phone = await _showPhoneConfirmSheet(context, customerName);
      if (phone == null || phone.trim().isEmpty) {
        return;
      }
    }

    final packageName = package?.name ?? 'Vehicle Service';
    final repo = ref.read(garageRepositoryProvider);

    final conv = await repo.getOrCreateConversation(
      customerId: customerId,
      customerName: customerName,
      customerPhone: phone,
      garageId: garage.id,
      garageName: garage.name,
      garagePhone: garage.phone,
      serviceJobTitle: packageName,
    );

    final inquiryText =
        customMessage ??
        'Hi ${garage.name}, I would like to inquire about "$packageName". My contact number is $phone. Please let me know the availability and schedule.';

    await repo.sendChatMessage(
      conversationId: conv.id,
      senderId: customerId,
      senderRole: 'customer',
      text: inquiryText,
    );

    FcmNotificationSender.send(
      title: 'New Service Inquiry from $customerName',
      content: 'Inquiring about "$packageName". Contact: $phone',
      subtitle: 'Tap to open chat and contact customer directly',
      garageId: garage.id,
      recipientUid: garage.ownerUid,
      type: 'inquiry',
      deepLink:
          '/chat/${conv.id}?name=${Uri.encodeComponent(customerName)}&phone=$phone',
      dataPayload: {
        'conversationId': conv.id,
        'customerPhone': phone,
        'customerName': customerName,
        'garageId': garage.id,
        'type': 'inquiry',
        'isChat': 'true',
        'deepLink':
            '/chat/${conv.id}?name=${Uri.encodeComponent(customerName)}&phone=$phone',
      },
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Inquiry sent to ${garage.name}! Opening chat...',
                  style: AppFonts.bodySmall(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      final encodedGarageName = Uri.encodeComponent(garage.name);
      context.push(
        '/chat/${conv.id}?name=$encodedGarageName&phone=${garage.phone}',
      );
    }
  }

  static Future<String?> _showPhoneConfirmSheet(
    BuildContext context,
    String customerName,
  ) async {
    final phoneCtrl = TextEditingController(text: '+91 ');
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: AppColors.accentBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Callback Contact Number',
                            style: AppFonts.titleMedium(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'The workshop will receive this number to discuss details.',
                            style: AppFonts.labelSmall(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: phoneCtrl,
                  label: 'Your Mobile Number',
                  hint: '+91 98765 43210',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, null),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Send Inquiry',
                        onPressed: () {
                          final text = phoneCtrl.text.trim();
                          if (text.length >= 8) {
                            Navigator.pop(ctx, text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
