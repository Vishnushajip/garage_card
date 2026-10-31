import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/constants/app_constants.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/core/notifications/notification_event_matrix.dart';
import 'package:garage_card/core/notifications/push_notification_service.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/core/shared_widgets/account_switcher_list_view.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_dialog.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_loading.dart';
import 'package:garage_card/core/shared_widgets/app_refresh.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';
import 'package:garage_card/core/shared_widgets/app_status_badge.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/customer/profile/Widgets/preference_tile.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../Model/garage_profile_state.dart';
import '../ViewModel/garage_profile_view_model.dart';

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
  late final TextEditingController _googleAddressCtrl;
  late final TextEditingController _googleMapsUrlCtrl;
  late final TextEditingController _taxCtrl;
  late final TextEditingController _hoursCtrl;

  String _selectedCurrency = 'INR';
  bool _hasInitializedFields = false;
  double? _detectedLat;
  double? _detectedLng;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _googleAddressCtrl = TextEditingController();
    _googleMapsUrlCtrl = TextEditingController();
    _taxCtrl = TextEditingController();
    _hoursCtrl = TextEditingController(text: '8:30 AM - 7:30 PM');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _googleAddressCtrl.dispose();
    _googleMapsUrlCtrl.dispose();
    _taxCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _populateFieldsIfNeeded(
    GarageProfileState state,
    UserProfileModel? user,
  ) {
    if (_hasInitializedFields) return;
    final garage = state.garage;
    if (garage != null) {
      _nameCtrl.text = garage.name;
      _phoneCtrl.text = garage.phone;
      _emailCtrl.text = garage.email;
      _addressCtrl.text = garage.address;
      if (garage.googleAddress != null) {
        _googleAddressCtrl.text = garage.googleAddress!;
      }
      if (garage.googleMapsUrl != null) {
        _googleMapsUrlCtrl.text = garage.googleMapsUrl!;
      }
      _detectedLat = garage.latitude;
      _detectedLng = garage.longitude;
      _taxCtrl.text = garage.taxNumber;
      _hoursCtrl.text = garage.openHours.isNotEmpty
          ? garage.openHours
          : '8:30 AM - 7:30 PM';
      if (garage.currencyCode.isNotEmpty) {
        _selectedCurrency = garage.currencyCode;
      }
      _hasInitializedFields = true;
    } else if (user != null) {
      _nameCtrl.text = user.fullName.isNotEmpty
          ? '${user.fullName}\'s Garage'
          : 'My Garage';
      _phoneCtrl.text = user.phoneNumber;
      _emailCtrl.text = user.email;
      _hasInitializedFields = true;
    }
  }

  void _detectCoordinatesFromUrl(String url) {
    if (url.isEmpty) return;
    final regex = RegExp(r'[@\?&](?:q=)?(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = regex.firstMatch(url);
    if (match != null) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null) {
        setState(() {
          _detectedLat = lat;
          _detectedLng = lng;
        });
      }
    }
  }

  Future<void> _geocodeAddress() async {
    final query = _googleAddressCtrl.text.trim().isNotEmpty
        ? _googleAddressCtrl.text.trim()
        : _addressCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() => _isGeocoding = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );
      final client = http.Client();
      final response = await client
          .get(uri, headers: {'User-Agent': 'GarageCardApp/1.0'})
          .timeout(const Duration(seconds: 5));
      client.close();

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty) {
          final first = data.first as Map<String, dynamic>;
          final lat = double.tryParse(first['lat']?.toString() ?? '');
          final lon = double.tryParse(first['lon']?.toString() ?? '');
          if (lat != null && lon != null && mounted) {
            setState(() {
              _detectedLat = lat;
              _detectedLng = lon;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location coordinates detected: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isGeocoding = false);
  }

  Future<void> _testLocationOnMap() async {
    final urlString = _googleMapsUrlCtrl.text.trim();
    Uri? launchUri;
    if (urlString.isNotEmpty &&
        (urlString.startsWith('http://') || urlString.startsWith('https://'))) {
      launchUri = Uri.tryParse(urlString);
    } else if (_detectedLat != null && _detectedLng != null) {
      launchUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$_detectedLat,$_detectedLng',
      );
    } else if (_googleAddressCtrl.text.trim().isNotEmpty) {
      launchUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_googleAddressCtrl.text.trim())}',
      );
    }

    if (launchUri != null) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  double _calculateCompletionPercentage() {
    int total = 7;
    int filled = 0;
    if (_nameCtrl.text.trim().isNotEmpty) filled++;
    if (_addressCtrl.text.trim().isNotEmpty) filled++;
    if (_googleAddressCtrl.text.trim().isNotEmpty ||
        _googleMapsUrlCtrl.text.trim().isNotEmpty) {
      filled++;
    }
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
          googleAddress: _googleAddressCtrl.text.trim().isNotEmpty
              ? _googleAddressCtrl.text.trim()
              : null,
          googleMapsUrl: _googleMapsUrlCtrl.text.trim().isNotEmpty
              ? _googleMapsUrlCtrl.text.trim()
              : null,
          latitude: _detectedLat,
          longitude: _detectedLng,
          phone: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          taxNumber: _taxCtrl.text.trim(),
          currencyCode: _selectedCurrency,
          openHours: _hoursCtrl.text.trim(),
        )
        .then((success) {
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Garage profile updated successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        });
  }

  Widget _buildLogoFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentBlue, AppColors.primaryRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppFonts.displayMedium(color: Colors.white)
              .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCoverFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.storefront_rounded, size: 40, color: Colors.white24),
      ),
    );
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

    final displayName = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text
        : (state.garage?.name ??
              (user?.fullName.isNotEmpty == true
                  ? '${user!.fullName}\'s Garage'
                  : 'Garage Workspace'));
    final displayEmail = _emailCtrl.text.isNotEmpty
        ? _emailCtrl.text
        : (state.garage?.email ?? user?.email ?? '');
    final displayPhone = _phoneCtrl.text.isNotEmpty
        ? _phoneCtrl.text
        : (state.garage?.phone ?? user?.phoneNumber ?? '');
    final completionPct = _calculateCompletionPercentage();

    return Scaffold(
      appBar: const AppCustomAppBar(title: 'Garage Profile & Settings'),
      body: AppRefresh(
        onRefresh: vm.refresh,
        child: SingleChildScrollView(
          child: AppResponsiveLayout(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: cardBg,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 2.8,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              state.garage?.coverImageUrl != null &&
                                      state.garage!.coverImageUrl!.isNotEmpty
                                  ? Image.network(
                                      state.garage!.coverImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          _buildCoverFallback(),
                                    )
                                  : _buildCoverFallback(),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.1),
                                      Colors.black.withValues(alpha: 0.6),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.photo_camera_rounded,
                                    size: 14,
                                  ),
                                  label: Text(
                                    state.garage?.coverImageUrl != null
                                        ? 'Change Banner'
                                        : 'Upload Banner',
                                    style: AppFonts.labelSmall(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.65,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85,
                                    );
                                    if (picked != null && context.mounted) {
                                      final ok = await vm.uploadGarageCover(
                                        picked,
                                      );
                                      if (ok && context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Garage banner updated successfully!',
                                            ),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      state.garage?.logoUrl != null &&
                                              state.garage!.logoUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image.network(
                                                state.garage!.logoUrl!,
                                                width: 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (ctx, err, stack) =>
                                                        _buildLogoFallback(
                                                          displayName,
                                                        ),
                                              ),
                                            )
                                          : _buildLogoFallback(displayName),
                                      Positioned(
                                        bottom: -4,
                                        right: -4,
                                        child: Material(
                                          color: AppColors.accentBlue,
                                          shape: const CircleBorder(),
                                          elevation: 2,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () async {
                                              final picker = ImagePicker();
                                              final picked = await picker
                                                  .pickImage(
                                                    source: ImageSource.gallery,
                                                    imageQuality: 85,
                                                  );
                                              if (picked != null &&
                                                  context.mounted) {
                                                final ok = await vm
                                                    .uploadGarageLogo(picked);
                                                if (ok && context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Garage logo updated successfully!',
                                                          ),
                                                          backgroundColor:
                                                              AppColors.success,
                                                        ),
                                                      );
                                                }
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(
                                                Icons.camera_alt_rounded,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style:
                                              AppFonts.titleLarge(
                                                color: primaryTextColor,
                                              ).copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          displayEmail,
                                          style: AppFonts.bodySmall(
                                            color: secondaryTextColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (displayPhone.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            displayPhone,
                                            style: AppFonts.labelSmall(
                                              color: secondaryTextColor,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const AppStatusBadge(
                                              status: 'approved',
                                              customLabel: 'VERIFIED GARAGE',
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.infoBg,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'PLAN: PRO TIER',
                                                style: AppFonts.labelSmall(
                                                  color: AppColors.info,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 28),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Profile Completion',
                                    style: AppFonts.labelMedium(
                                      color: secondaryTextColor,
                                    ).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${(completionPct * 100).toInt()}% Complete',
                                    style: AppFonts.labelMedium(
                                      color: completionPct == 1.0
                                          ? AppColors.success
                                          : AppColors.accentAmber,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: completionPct,
                                  minHeight: 6,
                                  backgroundColor: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    completionPct == 1.0
                                        ? AppColors.success
                                        : AppColors.accentAmber,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 14,
                                        color: secondaryTextColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Last Active: Today, Active Session',
                                        style: AppFonts.labelSmall(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Online',
                                        style: AppFonts.labelSmall(
                                          color: AppColors.success,
                                        ).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Business Information',
                    style: AppFonts.titleLarge(color: primaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _nameCtrl,
                            label: 'Garage Trading Name',
                            required: true,
                            onChanged: (_) => setState(() {}),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _addressCtrl,
                            label: 'Business Address & City',
                            required: true,
                            onChanged: (_) => setState(() {}),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _googleAddressCtrl,
                            label: 'Google Address (No Maps API Required)',
                            hint:
                                'Paste Google formatted address or locality...',
                            prefixIcon: const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _googleMapsUrlCtrl,
                            label: 'Google Maps Share Link / URL',
                            hint: 'https://maps.app.goo.gl/... or google.com/maps/...',
                            prefixIcon: const Icon(
                              Icons.link_rounded,
                              size: 18,
                            ),
                            onChanged: (val) {
                              _detectCoordinatesFromUrl(val);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : AppColors.cardLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _detectedLat != null &&
                                              _detectedLng != null
                                          ? Icons.check_circle_rounded
                                          : Icons.info_outline_rounded,
                                      size: 16,
                                      color:
                                          _detectedLat != null &&
                                              _detectedLng != null
                                          ? AppColors.success
                                          : AppColors.accentAmber,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _detectedLat != null &&
                                                _detectedLng != null
                                            ? 'Coordinates: ${_detectedLat!.toStringAsFixed(4)}, ${_detectedLng!.toStringAsFixed(4)}'
                                            : 'No coordinates detected yet',
                                        style: AppFonts.labelSmall(
                                          color: primaryTextColor,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: _isGeocoding
                                          ? const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.my_location_rounded,
                                              size: 14,
                                            ),
                                      label: Text(
                                        _isGeocoding
                                            ? 'Detecting...'
                                            : 'Auto-Detect Coordinates',
                                        style: AppFonts.labelSmall(
                                          color: AppColors.accentBlue,
                                        ),
                                      ),
                                      onPressed: _isGeocoding
                                          ? null
                                          : _geocodeAddress,
                                    ),
                                    OutlinedButton.icon(
                                      icon: const Icon(
                                        Icons.open_in_new_rounded,
                                        size: 14,
                                      ),
                                      label: Text(
                                        'Test Location on Maps',
                                        style: AppFonts.labelSmall(
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                      onPressed: _testLocationOnMap,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _phoneCtrl,
                                  label: 'Contact Phone',
                                  required: true,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  controller: _emailCtrl,
                                  label: 'Contact Email',
                                  required: true,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _taxCtrl,
                                  label: 'Tax / GSTIN Number',
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppDropdown<String>(
                                  label: 'Shop Currency',
                                  value: _selectedCurrency,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedCurrency = val);
                                    }
                                  },
                                  items: AppConstants.supportedCurrencies
                                      .map(
                                        (code) => AppDropdownItem(
                                          value: code,
                                          title: code,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _hoursCtrl,
                            label: 'Working Hours',
                            hint: '8:30 AM - 7:30 PM',
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            label: 'Save Business Profile',
                            onPressed: _save,
                            isLoading: state.isSaving,
                            isFullWidth: true,
                            height: 48,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Application Preferences',
                    style: AppFonts.titleLarge(color: primaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: AppDropdown<String>(
                            label: 'Interface Language',
                            value: locale.languageCode,
                            onChanged: (code) {
                              if (code != null) {
                                ref
                                    .read(localeProvider.notifier)
                                    .setLocale(code);
                              }
                            },
                            items: const [
                              AppDropdownItem(value: 'en', title: 'English'),
                              AppDropdownItem(
                                value: 'ml',
                                title: 'മലയാളം (Malayalam)',
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            'Doorstep Repair / Pickup',
                            style: AppFonts.bodyMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Mechanics travel to customer home or pickup vehicle',
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                          value:
                              state.garage?.isDoorstepRepairAvailable ?? true,
                          activeColor: AppColors.primaryRed,
                          onChanged: (val) => vm.setDoorstepRepair(val),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            'On-Road Breakdown Assistance',
                            style: AppFonts.bodyMedium(color: primaryTextColor)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Mechanics reach stranded vehicles on the road for emergency fixes',
                            style: AppFonts.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                          value:
                              state.garage?.isRoadsideAssistanceAvailable ??
                              true,
                          activeColor: AppColors.primaryRed,
                          onChanged: (val) => vm.setRoadsideAssistance(val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Push Notifications & Alerts',
                    style: AppFonts.titleLarge(color: primaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        PreferenceTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Enable Push Notifications',
                          subtitle: 'Receive customer bookings, status updates and approval alerts',
                          onTap: () async {
                            final service = ref.read(
                              pushNotificationServiceProvider,
                            );
                            final settings = await service.requestPermission();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    settings != null
                                        ? 'Notification permissions updated.'
                                        : 'Push notification service initialized.',
                                  ),
                                  backgroundColor: AppColors.accentBlue,
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        PreferenceTile(
                          icon: Icons.image_rounded,
                          title: 'Send Test Alert with Image',
                          subtitle: 'Preview a rich merchant alert with estimate breakdown image',
                          onTap: () async {
                            final service = ref.read(
                              pushNotificationServiceProvider,
                            );
                            await service.triggerEventNotification(
                              eventType: NotificationEventType.estimateApproved,
                              recipientUid: user?.uid ?? 'user_merchant_1',
                              entityId: 'est_m_1',
                              qualifier:
                                  'test_${DateTime.now().millisecondsSinceEpoch}',
                              title: 'Test: Estimate Approved by Customer',
                              body: 'Customer approved estimate EST-2024-001. Ready to begin work.',
                              customImageUrl:
                                  NotificationEventMatrix.fallbackEstimateImage,
                              customDeepLink: '/merchant/estimates',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Merchant test alert dispatched with image!',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
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
                                  color: AppColors.accentAmber.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account Switching',
                                      style: AppFonts.titleMedium(
                                        color: primaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.bold),
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
                              color: AppColors.error.withValues(alpha: 0.4),
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
                            style: AppFonts.labelSmall(color: AppColors.error)
                                .copyWith(fontWeight: FontWeight.w600),
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
