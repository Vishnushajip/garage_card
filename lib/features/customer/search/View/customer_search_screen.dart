import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_search_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_skeleton_loader.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/core/utils/debouncer.dart';

import '../Model/customer_search_state.dart';
import '../ViewModel/customer_search_view_model.dart';
import '../Widgets/customer_search_filter_sheet.dart';
import '../Widgets/customer_search_result_card.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  late final TextEditingController _searchCtrl;
  final FocusNode _focusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(milliseconds: 300),
  );
  bool _hasRequestedInitialFocus = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasRequestedInitialFocus && mounted) {
        _hasRequestedInitialFocus = true;
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _focusNode.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openFilters(CustomerSearchState state, CustomerSearchViewModel vm) {
    CustomerSearchFilterSheet.show(
      context,
      currentState: state,
      onApply: ({distance, vehicleType, category, minPrice, maxPrice, sortBy}) {
        if (distance != state.selectedDistance) vm.setDistance(distance);
        if (vehicleType != null) vm.setVehicleType(vehicleType);
        if (category != null) vm.setCategory(category);
        if (minPrice != state.minPrice || maxPrice != state.maxPrice) {
          vm.setPriceBudget(min: minPrice, max: maxPrice);
        }
        if (sortBy != null) vm.setSortBy(sortBy);
      },
      onReset: vm.clearAllFilters,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      customerSearchViewModelProvider(widget.initialQuery),
    );
    final vm = ref.read(
      customerSearchViewModelProvider(widget.initialQuery).notifier,
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppCustomAppBar(
        title: 'Search Garages & Services',
        subtitle: 'Find workshops, packages & pricing',
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: state.activeFilterCount > 0,
              label: Text('${state.activeFilterCount}'),
              backgroundColor: AppColors.primaryRed,
              child: const Icon(Icons.tune_rounded, size: 22),
            ),
            tooltip: 'Filter options',
            onPressed: () => _openFilters(state, vm),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _searchCtrl,
                        focusNode: _focusNode,
                        hint: 'Search workshops, oil change, wash, brake...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  vm.setQuery('');
                                },
                              )
                            : null,
                        onChanged: (val) {
                          _debouncer.run(() => vm.setQuery(val));
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: state.activeFilterCount > 0
                            ? AppColors.primaryRed
                            : (isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.activeFilterCount > 0
                              ? AppColors.primaryRed
                              : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: state.activeFilterCount > 0
                              ? Colors.white
                              : primaryText,
                        ),
                        onPressed: () => _openFilters(state, vm),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    if (state.selectedDistance != null)
                      _buildActiveFilterChip(
                        '< ${state.selectedDistance!.toStringAsFixed(0)} km',
                        () => vm.setDistance(null),
                      ),
                    if (state.selectedVehicleType != 'All')
                      _buildActiveFilterChip(
                        state.selectedVehicleType.toUpperCase(),
                        () => vm.setVehicleType('All'),
                      ),
                    if (state.selectedCategory != 'All')
                      _buildActiveFilterChip(
                        state.selectedCategory,
                        () => vm.setCategory('All'),
                      ),
                    if (state.minPrice != null || state.maxPrice != null)
                      _buildActiveFilterChip(
                        'Budget: ₹${state.minPrice?.toStringAsFixed(0) ?? '0'}–₹${state.maxPrice?.toStringAsFixed(0) ?? 'Any'}',
                        () => vm.setPriceBudget(min: null, max: null),
                      ),
                    if (state.sortBy != 'nearest')
                      _buildActiveFilterChip(
                        state.sortBy == 'price_asc'
                            ? 'Price: Low to High'
                            : (state.sortBy == 'price_desc'
                                  ? 'Price: High to Low'
                                  : 'Top Rated'),
                        () => vm.setSortBy('nearest'),
                      ),
                    if (state.activeFilterCount > 1)
                      TextButton(
                        onPressed: vm.clearAllFilters,
                        child: Text(
                          'Clear All',
                          style: AppFonts.labelSmall(
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${state.results.length} result${state.results.length == 1 ? '' : 's'} found',
                        style: AppFonts.labelSmall(color: secondaryText),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.accentBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Kochi Area',
                          style: AppFonts.labelSmall(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? AppSkeletonLoader.list(itemCount: 4)
                    : state.errorMessage != null
                    ? AppErrorState(
                        message: state.errorMessage!,
                        onRetry: vm.executeSearch,
                      )
                    : state.results.isEmpty
                    ? AppSearchEmptyState(
                        searchQuery: state.query,
                        hasActiveFilters: state.activeFilterCount > 0,
                        onClearFilters: vm.clearAllFilters,
                        onModifyQuery: () {
                          _focusNode.requestFocus();
                          _searchCtrl.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _searchCtrl.text.length,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final item = state.results[index];
                          return CustomerSearchResultCard(
                            result: item,
                            onTapGarage: () => context.push(
                              '/customer/garages/${item.garage.id}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        backgroundColor: AppColors.accentBlue.withValues(alpha: 0.12),
        deleteIcon: const Icon(Icons.close_rounded, size: 14),
        onDeleted: onRemove,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
