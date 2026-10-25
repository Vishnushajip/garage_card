import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Model/daily_todo_item_model.dart';

class DailyOperationsTodoCard extends StatelessWidget {
  const DailyOperationsTodoCard({
    super.key,
    required this.items,
    required this.onToggleDone,
    required this.onJobSelected,
    required this.onInvoiceSelected,
  });

  final List<DailyTodoItemModel> items;
  final ValueChanged<String> onToggleDone;
  final ValueChanged<String> onJobSelected;
  final ValueChanged<String> onInvoiceSelected;

  void _callCustomer(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _sendWhatsApp(DailyTodoItemModel item) {
    String msg;
    if (item.type == TodoItemType.deliveryToday) {
      msg =
          'Hello ${item.customerName}, your vehicle ${item.vehicleDisplay} is ready for collection at Apex Precision Automotive. Kindly visit us today to collect your vehicle. Thank you!';
    } else if (item.type == TodoItemType.paymentDue) {
      msg =
          'Hello ${item.customerName}, gentle reminder regarding outstanding payment of ${CurrencyFormatter.format(item.amount ?? 0)} for your recent garage service. Kindly settle at your earliest convenience.';
    } else {
      msg =
          'Hello ${item.customerName}, service update for your vehicle ${item.vehicleDisplay}.';
    }
    WhatsAppShareService.sendWhatsAppMessage(
      phoneNumber: item.customerPhone,
      message: msg,
    );
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

    return Card(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: AppColors.accentBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Operations & Deliveries To-Do',
                          style: AppFonts.titleMedium(color: primaryTextColor),
                        ),
                        Text(
                          'Auto-generated from scheduled vehicle logs & bills',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.where((i) => !i.isDone).length} Pending',
                    style: AppFonts.labelSmall(color: AppColors.accentBlue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No delivery or collection tasks scheduled for today!',
                    style: AppFonts.bodyMedium(color: secondaryTextColor),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isDone = item.isDone;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isDone,
                        onChanged: (_) => onToggleDone(item.id),
                        activeColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (item.jobId != null) {
                              onJobSelected(item.jobId!);
                            } else if (item.invoiceId != null) {
                              onInvoiceSelected(item.invoiceId!);
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildTypeBadge(item.type),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDone
                                            ? secondaryTextColor
                                            : primaryTextColor,
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                              if (item.scheduledTime != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Target: ${item.scheduledTime}',
                                  style: AppFonts.labelSmall(
                                    color: AppColors.accentBlue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone_outlined, size: 18),
                            color: AppColors.accentBlue,
                            tooltip: 'Call Customer',
                            onPressed: () => _callCustomer(item.customerPhone),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                            ),
                            color: AppColors.success,
                            tooltip: 'Send WhatsApp Update',
                            onPressed: () => _sendWhatsApp(item),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(TodoItemType type) {
    Color bg;
    Color fg;
    String label;

    switch (type) {
      case TodoItemType.deliveryToday:
        bg = AppColors.accentBlue.withValues(alpha: 0.12);
        fg = AppColors.accentBlue;
        label = 'DELIVERY TODAY';
        break;
      case TodoItemType.paymentDue:
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        label = 'PAYMENT DUE';
        break;
      case TodoItemType.completedYesterday:
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        label = 'YESTERDAY DONE';
        break;
      case TodoItemType.workPending:
        bg = AppColors.accentAmber.withValues(alpha: 0.12);
        fg = AppColors.accentAmber;
        label = 'WORK IN PROGRESS';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
