import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/date_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/features/support/models/support_ticket_model.dart';
import 'package:garage_card/features/support/widgets/ticket_priority_badge.dart';
import 'package:garage_card/features/support/widgets/ticket_status_badge.dart';

class CustomerTicketCard extends StatelessWidget {
  const CustomerTicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  final SupportTicketModel ticket;
  final VoidCallback onTap;

  String _formatCategory(BuildContext context, String cat) {
    switch (cat) {
      case 'repair_delay':
        return context.tr('repairDelay');
      case 'estimate_inquiry':
        return context.tr('estimateInquiry');
      case 'invoice_dispute':
        return context.tr('invoiceDispute');
      case 'service_quality':
        return context.tr('serviceQuality');
      case 'vehicle_issue':
        return context.tr('vehicleIssue');
      default:
        return context.tr('generalSupport');
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

    return Card(
      color: cardBg,
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        ticket.ticketNumber,
                        style: AppFonts.labelSmall(color: AppColors.primaryRed)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      TicketPriorityBadge(
                        priority: ticket.priority,
                        isCompact: true,
                      ),
                    ],
                  ),
                  TicketStatusBadge(status: ticket.status, isCompact: true),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.subject,
                style: AppFonts.titleMedium(color: primaryTextColor)
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatCategory(context, ticket.category),
                style: AppFonts.labelSmall(color: secondaryTextColor)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (ticket.garageName.isNotEmpty ||
                  ticket.vehicleDisplay != null) ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (ticket.garageName.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.storefront_rounded,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ticket.garageName,
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    if (ticket.vehicleDisplay != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            size: 14,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ticket.vehicleDisplay!,
                            style: AppFonts.labelSmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Divider(color: borderColor, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.lastMessagePreview.isNotEmpty
                          ? ticket.lastMessagePreview
                          : ticket.description,
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormatter.formatRelative(
                      ticket.lastMessageAt ?? ticket.createdAt,
                    ),
                    style: AppFonts.labelSmall(color: secondaryTextColor)
                        .copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
