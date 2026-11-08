import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/formatting/currency_formatter.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/models/inventory_item_model.dart';

import '../Model/merchant_inventory_state.dart';
import '../ViewModel/merchant_inventory_view_model.dart';
import '../Widgets/inventory_item_dialog.dart';

class MerchantInventoryScreen extends ConsumerStatefulWidget {
  const MerchantInventoryScreen({super.key});

  @override
  ConsumerState<MerchantInventoryScreen> createState() =>
      _MerchantInventoryScreenState();
}

class _MerchantInventoryScreenState
    extends ConsumerState<MerchantInventoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openItemDialog([InventoryItemModel? item]) {
    showDialog(
      context: context,
      builder: (ctx) => InventoryItemDialog(
        initialItem: item,
        onSave: (saved) => ref
            .read(merchantInventoryViewModelProvider.notifier)
            .saveItem(saved),
      ),
    );
  }

  void _confirmDelete(InventoryItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Inventory Item'),
        content: Text(
          'Are you sure you want to delete ${item.name} (${item.sku})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref
                  .read(merchantInventoryViewModelProvider.notifier)
                  .deleteItem(item.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantInventoryViewModelProvider);
    final vm = ref.read(merchantInventoryViewModelProvider.notifier);
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
      appBar: AppCustomAppBar(
        title: 'Parts & Inventory',
        subtitle: 'Track spare parts, stock levels & profit margins',
        actions: [
          IconButton(
            tooltip: 'Add Spare Part',
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.accentBlue,
            ),
            onPressed: () => _openItemDialog(),
          ),
        ],
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: AppResponsiveLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total SKUs',
                        value: '${state.items.length}',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.accentBlue,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryColor: primaryTextColor,
                        secondaryColor: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Valuation',
                        value: CurrencyFormatter.format(state.totalValuation),
                        icon: Icons.account_balance_wallet_outlined,
                        color: AppColors.success,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryColor: primaryTextColor,
                        secondaryColor: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Low Stock',
                        value: '${state.lowStockCount}',
                        icon: Icons.warning_amber_rounded,
                        color: state.lowStockCount > 0
                            ? AppColors.error
                            : AppColors.textSecondaryLight,
                        cardBg: cardBg,
                        borderColor: borderColor,
                        primaryColor: state.lowStockCount > 0
                            ? AppColors.error
                            : primaryTextColor,
                        secondaryColor: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _searchCtrl,
                        hint: 'Search by part name, SKU, or category...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  vm.setSearch('');
                                },
                              )
                            : null,
                        onChanged: vm.setSearch,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.selectedCategory != 'All'
                              ? AppColors.accentBlue
                              : borderColor,
                          width: state.selectedCategory != 'All' ? 1.5 : 1,
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        tooltip: 'Filter Category',
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: borderColor),
                        ),
                        color: cardBg,
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: state.selectedCategory != 'All'
                              ? AppColors.accentBlue
                              : primaryTextColor,
                          size: 22,
                        ),
                        onSelected: vm.setCategory,
                        itemBuilder: (ctx) =>
                            MerchantInventoryState.categories.map((cat) {
                              final isSelected = state.selectedCategory == cat;
                              return PopupMenuItem<String>(
                                value: cat,
                                child: Row(
                                  children: [
                                    Text(
                                      cat,
                                      style:
                                          AppFonts.bodySmall(
                                            color: isSelected
                                                ? AppColors.accentBlue
                                                : primaryTextColor,
                                          ).copyWith(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                    ),
                                    if (isSelected) ...[
                                      const Spacer(),
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 16,
                                        color: AppColors.accentBlue,
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.selectedCategory != 'All')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accentBlue.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.selectedCategory,
                              style: AppFonts.labelSmall(
                                color: AppColors.accentBlue,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () => vm.setCategory('All'),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (state.isLoading) {
                      return const AppLoading(message: 'Loading inventory...');
                    }
                    if (state.errorMessage != null && state.items.isEmpty) {
                      return AppErrorState(
                        message: state.errorMessage!,
                        onRetry: vm.refresh,
                      );
                    }
                    final displayList = state.filteredItems;
                    if (displayList.isEmpty) {
                      return AppEmptyState(
                        title: 'No Parts Found',
                        message: state.searchQuery.isNotEmpty
                            ? 'No inventory item matches "${state.searchQuery}".'
                            : 'Add your workshop spare parts, oils, and consumables to track stock.',
                        icon: Icons.inventory_2_outlined,
                        actionLabel: 'Add First Item',
                        onAction: () => _openItemDialog(),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: displayList.length,
                      itemBuilder: (ctx, index) {
                        final item = displayList[index];
                        return _buildItemCard(
                          context: context,
                          item: item,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          vm: vm,
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
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Part'),
        onPressed: () => _openItemDialog(),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color borderColor,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: AppFonts.labelSmall(color: secondaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppFonts.titleMedium(color: primaryColor)
                .copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required BuildContext context,
    required InventoryItemModel item,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required MerchantInventoryViewModel vm,
  }) {
    final isLow = item.isLowStock;

    return Card(
      color: cardBg,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLow ? AppColors.error.withValues(alpha: 0.5) : borderColor,
          width: isLow ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.sku,
                              style: AppFonts.labelSmall(
                                color: AppColors.accentBlue,
                              ).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              item.category,
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        style: AppFonts.titleMedium(color: primaryTextColor)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _openItemDialog(item);
                    } else if (val == 'delete') {
                      _confirmDelete(item);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Item'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cost: ${CurrencyFormatter.format(item.unitCost)}  •  Retail: ${CurrencyFormatter.format(item.sellingPrice)}',
                      style: AppFonts.bodySmall(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Margin: ${item.profitMargin.toStringAsFixed(1)}% profit',
                      style: AppFonts.labelSmall(
                        color: item.profitMargin > 20
                            ? AppColors.success
                            : AppColors.accentAmber,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: secondaryTextColor,
                      iconSize: 22,
                      tooltip: 'Decrease Stock',
                      onPressed: item.currentStock > 0
                          ? () => vm.adjustStock(item.id, -1)
                          : null,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 44),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLow
                            ? AppColors.error.withValues(alpha: 0.12)
                            : cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLow ? AppColors.error : borderColor,
                        ),
                      ),
                      child: Text(
                        '${item.currentStock} ${item.unit}',
                        style: AppFonts.labelMedium(
                          color: isLow ? AppColors.error : primaryTextColor,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: AppColors.accentBlue,
                      iconSize: 22,
                      tooltip: 'Increase Stock',
                      onPressed: () => vm.adjustStock(item.id, 1),
                    ),
                  ],
                ),
              ],
            ),
            if (isLow) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Low Stock Alert (Threshold: ${item.minStockAlert} ${item.unit}). Reorder recommended.',
                      style: AppFonts.labelSmall(color: AppColors.error)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            if (item.location != null || item.supplier != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (item.location != null) ...[
                    const Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.location!,
                      style: AppFonts.labelSmall(color: secondaryTextColor),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (item.supplier != null) ...[
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item.supplier!,
                        style: AppFonts.labelSmall(color: secondaryTextColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
