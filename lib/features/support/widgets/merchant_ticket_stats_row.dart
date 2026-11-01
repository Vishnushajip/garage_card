import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/features/support/models/ticket_stats_model.dart';

class MerchantTicketStatsRow extends StatelessWidget {
  const MerchantTicketStatsRow({
    super.key,
    required this.stats,
    this.selectedFilter = 'all',
    required this.onSelectFilter,
  });

  final TicketStatsModel stats;
  final String selectedFilter;
  final ValueChanged<String> onSelectFilter;

  Widget _buildStatCard(
    BuildContext context, {
    required String filterKey,
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedFilter == filterKey;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isSelected
        ? color
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onSelectFilter(filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: color),
                Text(
                  count.toString(),
                  style: AppFonts.displaySmall(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ).copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style:
                  AppFonts.labelSmall(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final items = [
          {
            'key': 'all',
            'label': context.tr('allTickets'),
            'count': stats.total,
            'icon': Icons.confirmation_number_outlined,
            'color': AppColors.accentBlue,
          },
          {
            'key': 'open',
            'label': context.tr('open'),
            'count': stats.open,
            'icon': Icons.pending_actions_rounded,
            'color': AppColors.primaryRed,
          },
          {
            'key': 'in_progress',
            'label': context.tr('inProgress'),
            'count': stats.inProgress,
            'icon': Icons.autorenew_rounded,
            'color': AppColors.warning,
          },
          {
            'key': 'waiting_for_customer',
            'label': context.tr('waitingCustomer'),
            'count': stats.waitingForCustomer,
            'icon': Icons.mark_chat_unread_outlined,
            'color': Colors.purple,
          },
          {
            'key': 'resolved',
            'label': context.tr('resolved'),
            'count': stats.resolved,
            'icon': Icons.check_circle_outline_rounded,
            'color': AppColors.success,
          },
        ];

        if (isWide) {
          return Row(
            children: items.map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildStatCard(
                    context,
                    filterKey: item['key'] as String,
                    label: item['label'] as String,
                    count: item['count'] as int,
                    icon: item['icon'] as IconData,
                    color: item['color'] as Color,
                  ),
                ),
              );
            }).toList(),
          );
        }

        return SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 130,
                child: _buildStatCard(
                  context,
                  filterKey: item['key'] as String,
                  label: item['label'] as String,
                  count: item['count'] as int,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
