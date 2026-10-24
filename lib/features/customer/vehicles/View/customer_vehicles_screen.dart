import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_empty_state.dart';
import 'package:garage_card/core/shared_widgets/app_error_state.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import '../ViewModel/customer_vehicles_view_model.dart';
import '../Widgets/vehicle_card_item.dart';

class CustomerVehiclesScreen extends ConsumerWidget {
  const CustomerVehiclesScreen({
    super.key,
    required this.onSelectVehicle,
  });

  final ValueChanged<String> onSelectVehicle;

  void _showAddVehicleSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _AddVehicleSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerVehiclesViewModelProvider);
    final vm = ref.read(customerVehiclesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Vehicles',
          style: AppFonts.titleLarge(color: primaryTextColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddVehicleSheet(context, ref),
          ),
        ],
      ),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: AppResponsiveLayout(
          child: Builder(
            builder: (context) {
              if (state.isLoading) {
                return const AppLoading(message: 'Loading your vehicles...');
              }
              if (state.errorMessage != null && state.vehicles.isEmpty) {
                return AppErrorState(
                  message: state.errorMessage!,
                  onRetry: vm.refresh,
                );
              }
              if (state.vehicles.isEmpty) {
                return AppEmptyState(
                  title: 'No vehicles registered',
                  message:
                      'Add your car or two-wheeler to track maintenance and book services.',
                  icon: Icons.directions_car_outlined,
                  actionLabel: 'Add First Vehicle',
                  onAction: () => _showAddVehicleSheet(context, ref),
                );
              }
              return ListView.builder(
                itemCount: state.vehicles.length,
                itemBuilder: (ctx, index) {
                  final veh = state.vehicles[index];
                  return VehicleCardItem(
                    vehicle: veh,
                    onTap: () => onSelectVehicle(veh.id),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicleSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Vehicle'),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AddVehicleSheet extends ConsumerStatefulWidget {
  const _AddVehicleSheet();

  @override
  ConsumerState<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends ConsumerState<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _makeCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: '2023');
  final _plateCtrl = TextEditingController();
  final _odometerCtrl = TextEditingController(text: '15000');
  final _colorCtrl = TextEditingController();

  String _selectedFuel = 'Petrol';

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _odometerCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(customerVehiclesViewModelProvider.notifier)
        .registerVehicle(
          make: _makeCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          year: int.tryParse(_yearCtrl.text.trim()) ?? 2023,
          licensePlate: _plateCtrl.text.trim().toUpperCase(),
          fuelType: _selectedFuel,
          currentOdometer: int.tryParse(_odometerCtrl.text.trim()) ?? 0,
          color: _colorCtrl.text.trim(),
        )
        .then((success) {
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle registered successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerVehiclesViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Register New Vehicle',
                style: AppFonts.titleLarge(color: primaryTextColor),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _makeCtrl,
                      label: 'Make',
                      hint: 'e.g. Hyundai',
                      required: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _modelCtrl,
                      label: 'Model',
                      hint: 'e.g. Creta',
                      required: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _plateCtrl,
                      label: 'License Plate',
                      hint: 'KL 07 CD 1234',
                      required: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _yearCtrl,
                      label: 'Year',
                      hint: '2023',
                      keyboardType: TextInputType.number,
                      required: true,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _odometerCtrl,
                      label: 'Current Odometer (km)',
                      hint: '15000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: _colorCtrl,
                      label: 'Color',
                      hint: 'e.g. White',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Fuel Type',
                value: _selectedFuel,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedFuel = val;
                    });
                  }
                },
                items: const [
                  AppDropdownItem(value: 'Petrol', title: 'Petrol'),
                  AppDropdownItem(value: 'Diesel', title: 'Diesel'),
                  AppDropdownItem(value: 'Electric', title: 'Electric (EV)'),
                  AppDropdownItem(value: 'CNG', title: 'CNG'),
                  AppDropdownItem(value: 'Hybrid', title: 'Hybrid'),
                ],
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Save Vehicle',
                onPressed: _save,
                isLoading: state.isSaving,
                height: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
