import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';

import '../Model/customer_search_state.dart';

class CustomerSearchFilterSheet extends StatefulWidget {
  const CustomerSearchFilterSheet({
    super.key,
    required this.currentState,
    required this.onApply,
    required this.onReset,
  });

  final CustomerSearchState currentState;
  final void Function({
    double? distance,
    String? vehicleType,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  })
  onApply;
  final VoidCallback onReset;

  static Future<void> show(
    BuildContext context, {
    required CustomerSearchState currentState,
    required void Function({
      double? distance,
      String? vehicleType,
      String? category,
      double? minPrice,
      double? maxPrice,
      String? sortBy,
    })
    onApply,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerSearchFilterSheet(
        currentState: currentState,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  }

  @override
  State<CustomerSearchFilterSheet> createState() =>
      _CustomerSearchFilterSheetState();
}

class _CustomerSearchFilterSheetState extends State<CustomerSearchFilterSheet> {
  double? _distance;
  String _vehicleType = 'All';
  String _category = 'All';
  double? _minPrice;
  double? _maxPrice;
  String _sortBy = 'nearest';

  @override
  void initState() {
    super.initState();
    _distance = widget.currentState.selectedDistance;
    _vehicleType = widget.currentState.selectedVehicleType;
    _category = widget.currentState.selectedCategory;
    _minPrice = widget.currentState.minPrice;
    _maxPrice = widget.currentState.maxPrice;
    _sortBy = widget.currentState.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Search & Discovery Filters',
                      style: AppFonts.titleLarge(color: primaryText)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _distance = null;
                        _vehicleType = 'All';
                        _category = 'All';
                        _minPrice = null;
                        _maxPrice = null;
                        _sortBy = 'nearest';
                      });
                      widget.onReset();
                    },
                    child: Text(
                      'Reset All',
                      style: AppFonts.labelMedium(color: AppColors.primaryRed),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Distance Radius',
                style: AppFonts.labelLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDistanceChip(null, 'Any Distance'),
                  _buildDistanceChip(2.0, '< 2 km'),
                  _buildDistanceChip(5.0, '< 5 km'),
                  _buildDistanceChip(10.0, '< 10 km'),
                  _buildDistanceChip(25.0, '< 25 km'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Vehicle Compatibility',
                style: AppFonts.labelLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildVehicleChip('All', 'All Vehicles'),
                  _buildVehicleChip('car', 'Cars'),
                  _buildVehicleChip('motorcycle', 'Motorcycles'),
                  _buildVehicleChip('scooter', 'Scooters'),
                  _buildVehicleChip('electric_scooter', 'EV Scooters'),
                  _buildVehicleChip('electric_motorcycle', 'EV Motorcycles'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Service Category',
                style: AppFonts.labelLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip('All', 'All Categories'),
                  _buildCategoryChip('Periodic Service', 'Periodic Service'),
                  _buildCategoryChip(
                    'Water Service & Wash',
                    'Wash & Detailing',
                  ),
                  _buildCategoryChip(
                    'Inspections & Diagnostics',
                    'Diagnostics',
                  ),
                  _buildCategoryChip('Mechanical', 'Mechanical Repair'),
                  _buildCategoryChip('Electrical & Battery', 'Electrical & EV'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Price Budget Range',
                style: AppFonts.labelLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPriceChip(null, null, 'Any Budget'),
                  _buildPriceChip(null, 500, 'Under ₹500'),
                  _buildPriceChip(500, 1500, '₹500 – ₹1,500'),
                  _buildPriceChip(1500, 3000, '₹1,500 – ₹3,000'),
                  _buildPriceChip(3000, null, '₹3,000+'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Sort Order',
                style: AppFonts.labelLarge(color: primaryText)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSortChip('nearest', 'Nearest First'),
                  _buildSortChip('price_asc', 'Price: Low to High'),
                  _buildSortChip('price_desc', 'Price: High to Low'),
                  _buildSortChip('rating', 'Highest Rated'),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Apply Filters',
                isFullWidth: true,
                onPressed: () {
                  widget.onApply(
                    distance: _distance,
                    vehicleType: _vehicleType,
                    category: _category,
                    minPrice: _minPrice,
                    maxPrice: _maxPrice,
                    sortBy: _sortBy,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceChip(double? dist, String label) {
    final isSelected = _distance == dist;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _distance = dist),
    );
  }

  Widget _buildVehicleChip(String type, String label) {
    final isSelected = _vehicleType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _vehicleType = type),
    );
  }

  Widget _buildCategoryChip(String cat, String label) {
    final isSelected = _category == cat;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _category = cat),
    );
  }

  Widget _buildPriceChip(double? min, double? max, String label) {
    final isSelected = _minPrice == min && _maxPrice == max;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        setState(() {
          _minPrice = min;
          _maxPrice = max;
        });
      },
    );
  }

  Widget _buildSortChip(String sort, String label) {
    final isSelected = _sortBy == sort;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.accentBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _sortBy = sort),
    );
  }
}
