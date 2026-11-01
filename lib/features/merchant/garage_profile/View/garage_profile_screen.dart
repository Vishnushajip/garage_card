import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/notifications/push_notification_service.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/services/location_service.dart';
import 'package:garage_card/core/shared_widgets/account_switcher_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_map_location_picker.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/merchant/dashboard/ViewModel/merchant_dashboard_view_model.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import 'package:garage_card/features/shared/models/working_hours_model.dart';
import 'package:go_router/go_router.dart';

import '../Model/garage_profile_state.dart';
import '../ViewModel/garage_profile_view_model.dart';
import '../Widgets/garage_profile_business_form.dart';
import '../Widgets/garage_profile_header_card.dart';
import '../Widgets/garage_profile_preferences_card.dart';

class GarageProfileScreen extends ConsumerStatefulWidget {
  const GarageProfileScreen({super.key});

  @override
  ConsumerState<GarageProfileScreen> createState() =>
      _GarageProfileScreenState();
}

class _GarageProfileScreenState extends ConsumerState<GarageProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _taxCtrl;
  late final TextEditingController _hoursCtrl;
  List<DayWorkingHours> _workingSchedule =
      WorkingHoursSchedule.defaultSchedule();

  String _selectedCurrency = 'INR';
  bool _hasInitializedFields = false;
  double? _detectedLat;
  double? _detectedLng;
  String? _googleAddress;
  bool _isLocatingGps = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _taxCtrl = TextEditingController();
    _hoursCtrl = TextEditingController(text: '8:30 AM - 7:30 PM');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _taxCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  String _stripCountryCode(String phone) {
    var cleaned = phone.trim();
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3).trim();
    } else if (cleaned.startsWith('+')) {
      final match = RegExp(r'^\+\d{1,3}\s*').firstMatch(cleaned);
      if (match != null) {
        cleaned = cleaned.substring(match.end).trim();
      }
    }
    return cleaned;
  }

  String _sanitizePhoneForField(String phone) {
    final stripped = _stripCountryCode(phone);
    final digits = stripped.replaceAll(RegExp(r'\D'), '');
    if (digits == '9846077889' ||
        digits == '9876500000' ||
        digits == '9846012345') {
      return '';
    }
    return stripped;
  }

  String _sanitizeNameForField(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        trimmed.contains('Vishnu') ||
        trimmed == 'Garage Workshop' ||
        trimmed == 'My Garage' ||
        trimmed == 'Garage' ||
        trimmed.endsWith('\'s Garage')) {
      return '';
    }
    return trimmed;
  }

  void _populateFieldsIfNeeded(
    GarageProfileState state,
    UserProfileModel? user,
  ) {
    if (_hasInitializedFields) return;
    final garage = state.garage;
    if (garage != null) {
      _nameCtrl.text = _sanitizeNameForField(garage.name);
      _phoneCtrl.text = _sanitizePhoneForField(garage.phone);
      _emailCtrl.text = garage.email;
      _addressCtrl.text = garage.address;
      _googleAddress = garage.googleAddress;
      _detectedLat = garage.latitude;
      _detectedLng = garage.longitude;
      _taxCtrl.text = garage.taxNumber;
      _workingSchedule = WorkingHoursSchedule.parse(
        garage.dailyWorkingHours,
        garage.openHours,
      );
      _hoursCtrl.text = WorkingHoursSchedule.toDisplaySummary(_workingSchedule);
      if (garage.currencyCode.isNotEmpty) {
        _selectedCurrency = garage.currencyCode;
      }
      _hasInitializedFields = true;
    } else if (user != null) {
      _nameCtrl.text = '';
      _phoneCtrl.text = _sanitizePhoneForField(user.phoneNumber);
      _emailCtrl.text = user.email;
      _hasInitializedFields = true;
    }
  }

  Future<void> _openMapPicker() async {
    final result = await AppMapLocationPicker.show(
      context,
      initialLatitude: _detectedLat,
      initialLongitude: _detectedLng,
      initialAddress: _googleAddress ?? _addressCtrl.text.trim(),
    );

    if (result != null && mounted) {
      setState(() {
        _detectedLat = result.latitude;
        _detectedLng = result.longitude;
        if (result.address.isNotEmpty) {
          _googleAddress = result.address;
        }
      });
      AppNotificationService.success(
        result.address.isNotEmpty
            ? 'Workshop location pinned: ${result.address}'
            : 'Workshop location pinned (${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)})',
      );
    }
  }

  Future<void> _autoDetectCurrentGpsLocation() async {
    setState(() => _isLocatingGps = true);
    try {
      final pos = await LocationService.instance.getCurrentPosition();
      if (pos == null) {
        if (mounted) {
          AppNotificationService.error(
            'Could not detect current location. Please grant location permissions in your browser or device settings.',
          );
        }
        return;
      }

      final lat = pos.latitude;
      final lng = pos.longitude;
      final details = await LocationService.instance.reverseGeocode(
        latitude: lat,
        longitude: lng,
      );

      if (mounted) {
        setState(() {
          _detectedLat = lat;
          _detectedLng = lng;
          if (details != null && details.shortAddress.isNotEmpty) {
            _googleAddress = details.shortAddress;
          } else {
            _googleAddress =
                'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
          }
        });
        AppNotificationService.success(
          details != null && details.shortAddress.isNotEmpty
              ? 'GPS Location detected: ${details.shortAddress}'
              : 'GPS coordinates detected: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotificationService.error('Failed to detect GPS location: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLocatingGps = false);
      }
    }
  }

  double _calculateCompletionPercentage() {
    int total = 7;
    int filled = 0;
    if (_nameCtrl.text.trim().isNotEmpty) filled++;
    if (_addressCtrl.text.trim().isNotEmpty) filled++;
    if (_detectedLat != null && _detectedLng != null) filled++;
    if (_phoneCtrl.text.trim().isNotEmpty) filled++;
    if (_emailCtrl.text.trim().isNotEmpty) filled++;
    if (_taxCtrl.text.trim().isNotEmpty) filled++;
    if (_hoursCtrl.text.trim().isNotEmpty) filled++;
    return filled / total;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    ref
        .read(garageProfileViewModelProvider.notifier)
        .updateProfile(
          name: _nameCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          googleAddress:
              _googleAddress != null && _googleAddress!.trim().isNotEmpty
              ? _googleAddress!.trim()
              : (_detectedLat != null && _detectedLng != null
                    ? 'Lat: ${_detectedLat!.toStringAsFixed(4)}, Lng: ${_detectedLng!.toStringAsFixed(4)}'
                    : null),
          googleMapsUrl: _detectedLat != null && _detectedLng != null
              ? 'https://www.google.com/maps/search/?api=1&query=$_detectedLat,$_detectedLng'
              : null,
          latitude: _detectedLat,
          longitude: _detectedLng,
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          taxNumber: _taxCtrl.text.trim(),
          currencyCode: _selectedCurrency,
          openHours: _hoursCtrl.text.trim(),
          dailyWorkingHours: _workingSchedule.map((d) => d.toMap()).toList(),
        )
        .then((success) {
          if (mounted) {
            if (success) {
              AppNotificationService.success(
                'Garage profile updated successfully!',
              );
              ref.read(merchantDashboardViewModelProvider.notifier).refresh();
              Future.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  if (context.canPop()) {
                    context.pop(true);
                  } else {
                    context.go(RoutePaths.merchant);
                  }
                }
              });
            } else {
              final err = ref.read(garageProfileViewModelProvider).errorMessage;
              AppNotificationService.error(
                err != null && err.isNotEmpty
                    ? 'Unable to save: $err'
                    : 'Unable to save garage details. Please try again.',
              );
            }
          }
        })
        .catchError((e) {
          if (mounted) {
            AppNotificationService.error('Unable to save: $e');
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(garageProfileViewModelProvider);
    final vm = ref.read(garageProfileViewModelProvider.notifier);
    final user = ref.watch(authViewModelProvider).userProfile;
    final locale = ref.watch(localeProvider);

    _populateFieldsIfNeeded(state, user);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    if (state.isLoading) {
      return const Scaffold(
        body: AppLoading(message: 'Loading garage settings...'),
      );
    }

    final sanitizedGarageName = _sanitizeNameForField(state.garage?.name ?? '');
    final displayName = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text
        : (sanitizedGarageName.isNotEmpty
              ? sanitizedGarageName
              : 'Garage Workspace');
    final displayEmail = _emailCtrl.text.isNotEmpty
        ? _emailCtrl.text
        : (state.garage?.email ?? user?.email ?? '');
    final displayPhone = _phoneCtrl.text.isNotEmpty
        ? _phoneCtrl.text
        : _sanitizePhoneForField(
            state.garage?.phone ?? user?.phoneNumber ?? '',
          );
    final completionPct = _calculateCompletionPercentage();

    return Scaffold(
      appBar: const AppCustomAppBar(title: 'Garage Profile & Settings'),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: SingleChildScrollView(
          child: AppResponsiveLayout(
            maxWidth: AppResponsiveLayout.kMaxFormWidth,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GarageProfileHeaderCard(
                    state: state,
                    vm: vm,
                    displayName: displayName,
                    displayEmail: displayEmail,
                    displayPhone: displayPhone,
                    completionPct: completionPct,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 740;

                      final businessSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Business Information',
                            style: AppFonts.titleLarge(color: primaryTextColor),
                          ),
                          const SizedBox(height: 12),
                          GarageProfileBusinessForm(
                            nameCtrl: _nameCtrl,
                            addressCtrl: _addressCtrl,
                            googleAddress: _googleAddress,
                            phoneCtrl: _phoneCtrl,
                            emailCtrl: _emailCtrl,
                            taxCtrl: _taxCtrl,
                            hoursCtrl: _hoursCtrl,
                            workingSchedule: _workingSchedule,
                            onScheduleChanged: (schedule) {
                              setState(() {
                                _workingSchedule = schedule;
                                _hoursCtrl.text =
                                    WorkingHoursSchedule.toDisplaySummary(
                                      schedule,
                                    );
                              });
                            },
                            selectedCurrency: _selectedCurrency,
                            onCurrencyChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedCurrency = val);
                              }
                            },
                            detectedLat: _detectedLat,
                            detectedLng: _detectedLng,
                            isLocatingGps: _isLocatingGps,
                            onOpenMapPicker: _openMapPicker,
                            onAutoDetectGps: _autoDetectCurrentGpsLocation,
                            onSave: _save,
                            isSaving: state.isSaving,
                            onChanged: () => setState(() {}),
                          ),
                        ],
                      );

                      final settingsSection = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GarageProfilePreferencesCard(
                            languageCode: locale.languageCode,
                            onLanguageChanged: (code) {
                              if (code != null) {
                                ref
                                    .read(localeProvider.notifier)
                                    .setLocale(code);
                              }
                            },
                            isDoorstepRepairAvailable:
                                state.garage?.isDoorstepRepairAvailable ?? true,
                            onDoorstepRepairChanged: (val) =>
                                vm.setDoorstepRepair(val),
                            isRoadsideAssistanceAvailable:
                                state.garage?.isRoadsideAssistanceAvailable ??
                                true,
                            onRoadsideAssistanceChanged: (val) =>
                                vm.setRoadsideAssistance(val),
                            onEnablePushNotifications: () async {
                              final service = ref.read(
                                pushNotificationServiceProvider,
                              );
                              final settings = await service
                                  .requestPermission();
                              if (context.mounted) {
                                AppNotificationService.info(
                                  settings != null
                                      ? 'Notification permissions updated.'
                                      : 'Push notification service initialized.',
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Card(
                            color: cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: borderColor),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentAmber
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.swap_horiz_rounded,
                                          color: AppColors.accentAmber,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Account Switching',
                                              style:
                                                  AppFonts.titleMedium(
                                                    color: primaryTextColor,
                                                  ).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              'Switch between Merchant & Customer workspaces',
                                              style: AppFonts.labelSmall(
                                                color: secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  AccountSwitcherListView(
                                    onSwitched: (target) {
                                      if (context.mounted) {
                                        context.go(
                                          target == 'merchant'
                                              ? RoutePaths.merchant
                                              : RoutePaths.customer,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'WeFix Garage',
                                      style: AppFonts.labelSmall(
                                        color: primaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Version 1.0.0 (Build 2026.1)',
                                      style: AppFonts.labelSmall(
                                        color: secondaryTextColor,
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    side: BorderSide(
                                      color: AppColors.error.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.power_settings_new_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    'Sign Out',
                                    style: AppFonts.labelSmall(
                                      color: AppColors.error,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: () async {
                                    final confirm = await AppDialog.confirm(
                                      context,
                                      title: 'Sign Out?',
                                      message: 'Are you sure you want to securely exit your merchant workspace?',
                                      confirmLabel: 'Sign Out',
                                      isDestructive: true,
                                    );
                                    if (confirm == true) {
                                      ref
                                          .read(authViewModelProvider.notifier)
                                          .signOut();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: businessSection),
                            const SizedBox(width: 24),
                            Expanded(flex: 5, child: settingsSection),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          businessSection,
                          const SizedBox(height: 24),
                          settingsSection,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
