import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/shared_widgets/app_date_text.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_whatsapp_icon.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/shared/documents/pdf_generator_service.dart';
import 'package:garage_card/features/shared/models/invoice_model.dart';
import 'package:garage_card/features/shared/models/service_job_model.dart';

import 'edit_invoice_dialog.dart';
import 'job_whatsapp_share_dialog.dart';
import 'update_payment_dialog.dart';

class CompletedJobCard extends ConsumerWidget {
  const CompletedJobCard({
    super.key,
    required this.job,
    required this.invoice,
    required this.onViewDetails,
  });

  final ServiceJobModel job;
  final InvoiceModel? invoice;
  final VoidCallback onViewDetails;

  void _openEditInvoice(BuildContext context) {
    if (invoice == null) {
      AppNotificationService.warning('Invoice not generated for this job yet');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => EditInvoiceDialog(invoice: invoice!, job: job),
    );
  }

  void _openUpdatePayment(BuildContext context) {
    if (invoice == null) {
      AppNotificationService.warning('Invoice not generated for this job yet');
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => UpdatePaymentDialog(invoice: invoice!, job: job),
    );
  }

  Future<void> _downloadPdf(BuildContext context, WidgetRef ref) async {
    if (invoice == null) {
      AppNotificationService.warning('Invoice not found for PDF download');
      return;
    }
    final dashState = ref.read(merchantDashboardViewModelProvider);
    final garage = dashState.garage;
    if (garage == null) {
      AppNotificationService.warning('Garage details not loaded');
      return;
    }

    try {
      await PdfGeneratorService.printOrShareJobInvoice(
        garage: garage,
        job: job,
        invoice: invoice!,
      );
    } catch (e) {
      AppNotificationService.error('Failed to generate PDF: $e');
    }
  }

  void _openWhatsApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => JobWhatsAppShareDialog(
        type: WhatsAppNotificationType.invoiceSharing,
        customerName: job.customerName,
        customerPhone: job.customerPhone,
        bikeNumber: job.vehicleDisplay,
        invoiceNumber: invoice?.invoiceNumber ?? job.jobNumber,
        finalBillAmount: invoice?.totalAmount ?? 0.0,
        paidAmount: invoice?.paidAmount ?? 0.0,
        balanceDue: invoice?.balanceDue ?? 0.0,
        paymentStatus: invoice?.status ?? 'completed',
      ),
    );
  }

  Widget _buildViewDetailsButton(
    BuildContext context, {
    EdgeInsetsGeometry? padding,
  }) {
    return OutlinedButton.icon(
      onPressed: onViewDetails,
      icon: const Icon(Icons.visibility_outlined, size: 16),
      label: Text(
        context.tr('viewDetails'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildWhatsAppButton(
    BuildContext context, {
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton.icon(
      onPressed: () => _openWhatsApp(context),
      icon: const AppWhatsAppIcon(size: 16, color: Colors.white),
      label: Text(
        context.tr('whatsapp'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildMoreActionsButton(
    BuildContext context,
    WidgetRef ref,
    Color cardBg,
    Color borderColor,
    double balance,
  ) {
    return PopupMenuButton<String>(
      tooltip: 'More Actions',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardBg,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: const Icon(Icons.more_horiz_rounded, size: 18),
      ),
      onSelected: (val) {
        if (val == 'edit') {
          _openEditInvoice(context);
        } else if (val == 'payment') {
          _openUpdatePayment(context);
        } else if (val == 'pdf') {
          _downloadPdf(context, ref);
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 18),
              SizedBox(width: 10),
              Text('Edit Bill / Items'),
            ],
          ),
        ),
        if (balance > 0)
          const PopupMenuItem(
            value: 'payment',
            child: Row(
              children: [
                Icon(
                  Icons.payment_rounded,
                  size: 18,
                  color: AppColors.accentBlue,
                ),
                SizedBox(width: 10),
                Text('Update Payment'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 18,
                color: AppColors.primaryRed,
              ),
              SizedBox(width: 10),
              Text('Download PDF Invoice'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final sectionBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    double partsTotal = 0.0;
    double laborTotal = 0.0;
    double extraTotal = 0.0;
    int partsCount = 0;

    if (invoice != null) {
      for (final item in invoice!.items) {
        if (item.type.toLowerCase() == 'part') {
          partsTotal += item.totalPrice;
          partsCount += item.quantity;
        } else if (item.type.toLowerCase() == 'labor' ||
            item.type.toLowerCase() == 'labour') {
          laborTotal += item.totalPrice;
        } else if (item.type.toLowerCase() == 'extra' ||
            item.type.toLowerCase() == 'supplemental') {
          extraTotal += item.totalPrice;
        }
      }
    } else {
      extraTotal = job.supplementalItems.fold(
        0.0,
        (acc, item) => acc + item.totalAmount,
      );
    }

    final finalBill =
        invoice?.totalAmount ?? (partsTotal + laborTotal + extraTotal);
    final paid = invoice?.paidAmount ?? 0.0;
    final balance = invoice?.balanceDue ?? 0.0;
    final paymentMethod = invoice?.paymentRecords.isNotEmpty == true
        ? invoice!.paymentRecords.last.method.toUpperCase()
        : 'CASH';
    final paymentStatus = invoice?.status ?? 'completed';

    return Card(
      color: cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.jobNumber,
                    style: AppFonts.labelMedium(color: AppColors.accentBlue)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.vehicleDisplay,
                    style: AppFonts.titleMedium(color: primaryTextColor)
                        .copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                AppStatusBadge(status: 'completed'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 15,
                  color: AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${job.customerName}${job.customerPhone.isNotEmpty ? " • ${job.customerPhone}" : ""}',
                    style: AppFonts.bodySmall(color: secondaryTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.technicianName.isNotEmpty
                        ? job.technicianName
                        : 'General Mechanic',
                    style: AppFonts.labelSmall(color: AppColors.accentAmber)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Received: ',
                  style: AppFonts.labelSmall(color: secondaryTextColor),
                ),
                AppDateText(
                  date: job.createdAt,
                  style: AppFonts.labelSmall(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  'Completed: ',
                  style: AppFonts.labelSmall(color: secondaryTextColor),
                ),
                AppDateText(
                  date: job.completedDate ?? job.updatedAt,
                  style: AppFonts.labelSmall(color: primaryTextColor)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: sectionBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work: ',
                        style: AppFonts.labelSmall(color: secondaryTextColor)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          job.complaints.isNotEmpty
                              ? job.complaints.join(', ')
                              : 'General Service',
                          style: AppFonts.bodySmall(color: primaryTextColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (job.supplementalItems.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Extra Work: ',
                          style: AppFonts.labelSmall(
                            color: AppColors.accentAmber,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            job.supplementalItems
                                .map(
                                  (e) =>
                                      '${e.title} (${CurrencyFormatter.format(e.totalAmount)})',
                                )
                                .join(', '),
                            style: AppFonts.bodySmall(color: primaryTextColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Parts ($partsCount): ${CurrencyFormatter.format(partsTotal)}',
                          style: AppFonts.labelSmall(color: primaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Labour: ${CurrencyFormatter.format(laborTotal)}',
                          style: AppFonts.labelSmall(color: primaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (extraTotal > 0)
                        Expanded(
                          child: Text(
                            'Extra: ${CurrencyFormatter.format(extraTotal)}',
                            style: AppFonts.labelSmall(
                              color: AppColors.accentAmber,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: (balance > 0 ? AppColors.primaryRed : AppColors.success)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color:
                      (balance > 0 ? AppColors.primaryRed : AppColors.success)
                          .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Bill',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                        Text(
                          CurrencyFormatter.format(finalBill),
                          style: AppFonts.titleMedium(color: primaryTextColor)
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Paid: ${CurrencyFormatter.format(paid)} ($paymentMethod)',
                          style: AppFonts.labelSmall(color: AppColors.success),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 38,
                    width: 1,
                    color: borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Balance Due',
                          style: AppFonts.labelSmall(color: secondaryTextColor),
                        ),
                        Text(
                          CurrencyFormatter.format(balance),
                          style: AppFonts.titleMedium(
                            color: balance > 0
                                ? AppColors.primaryRed
                                : AppColors.success,
                          ).copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (balance <= 0
                                        ? AppColors.success
                                        : AppColors.primaryRed)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            paymentStatus.toUpperCase(),
                            style: AppFonts.labelSmall(
                              color: balance <= 0
                                  ? AppColors.success
                                  : AppColors.primaryRed,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final moreActions = invoice != null
                    ? _buildMoreActionsButton(
                        context,
                        ref,
                        cardBg,
                        borderColor,
                        balance,
                      )
                    : null;

                if (constraints.maxWidth >= 480) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          maxWidth: 180,
                        ),
                        child: _buildViewDetailsButton(context),
                      ),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          maxWidth: 180,
                        ),
                        child: _buildWhatsAppButton(context),
                      ),
                      if (moreActions != null) ...[
                        const SizedBox(width: 8),
                        moreActions,
                      ],
                    ],
                  );
                }

                if (constraints.maxWidth < 330) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildViewDetailsButton(
                        context,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildWhatsAppButton(
                              context,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                          ),
                          if (moreActions != null) ...[
                            const SizedBox(width: 8),
                            moreActions,
                          ],
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildViewDetailsButton(
                        context,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildWhatsAppButton(
                        context,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                    if (moreActions != null) ...[
                      const SizedBox(width: 8),
                      moreActions,
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
