import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/core/services/location_service.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_custom_app_bar.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:latlong2/latlong.dart';

class LocationPickResult {
  const LocationPickResult({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.city,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String? city;
}

class AppMapLocationPicker extends StatefulWidget {
  const AppMapLocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  static Future<LocationPickResult?> show(
    BuildContext context, {
    double? initialLatitude,
    double? initialLongitude,
    String? initialAddress,
  }) {
    return Navigator.of(context).push<LocationPickResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AppMapLocationPicker(
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
          initialAddress: initialAddress,
        ),
      ),
    );
  }

  @override
  State<AppMapLocationPicker> createState() => _AppMapLocationPickerState();
}

class _AppMapLocationPickerState extends State<AppMapLocationPicker> {
  late final MapController _mapController;
  late LatLng _selectedPoint;
  String _currentAddress = '';
  String? _detectedCity;
  bool _isLocating = false;
  bool _isReverseGeocoding = false;

  final TextEditingController _searchCtrl = TextEditingController();
  List<LocationDetails> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  int _searchSeq = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPoint = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      _currentAddress = widget.initialAddress ?? '';
    } else {
      _selectedPoint = LocationService.defaultKeralaCenter;
      _currentAddress = widget.initialAddress ?? 'Kochi, Kerala';
      _autoDetectCurrentLocation(silent: true);
    }

    if (_currentAddress.isEmpty) {
      _reverseGeocodePoint(_selectedPoint);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _reverseGeocodePoint(LatLng point) async {
    setState(() => _isReverseGeocoding = true);
    final details = await LocationService.instance.reverseGeocode(
      latitude: point.latitude,
      longitude: point.longitude,
    );
    if (mounted) {
      setState(() {
        _isReverseGeocoding = false;
        if (details != null && details.shortAddress.isNotEmpty) {
          _currentAddress = details.shortAddress;
          _detectedCity = details.city;
        } else if (_currentAddress.isEmpty) {
          _currentAddress =
              '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
        }
      });
    }
  }

  Future<void> _autoDetectCurrentLocation({bool silent = false}) async {
    setState(() => _isLocating = true);
    final pos = await LocationService.instance.getCurrentPosition();
    if (!mounted) return;
    setState(() => _isLocating = false);

    if (pos != null) {
      final newPoint = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedPoint = newPoint);
      _mapController.move(newPoint, 16.0);
      _reverseGeocodePoint(newPoint);
      if (!silent) {
        AppNotificationService.success(
          'Current GPS location detected!',
          duration: const Duration(seconds: 2),
        );
      }
    } else if (!silent) {
      AppNotificationService.error(
        'Could not access current GPS location. Please allow location access or pick manually on map.',
      );
    }
  }

  void _performSearch(String query, {bool immediate = false}) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    if (immediate) {
      _executeSearch(trimmed);
    } else {
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _executeSearch(trimmed);
      });
    }
  }

  Future<void> _executeSearch(String query) async {
    final currentSeq = ++_searchSeq;
    setState(() => _isSearching = true);
    final results = await LocationService.instance.searchPlaces(
      query,
      proximityLat: _selectedPoint.latitude,
      proximityLng: _selectedPoint.longitude,
    );
    if (mounted && currentSeq == _searchSeq) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(LocationDetails details) {
    final point = details.latLng;
    setState(() {
      _selectedPoint = point;
      _currentAddress = details.shortAddress;
      _detectedCity = details.city;
      _searchResults = [];
      _searchCtrl.text = details.shortAddress;
    });
    _mapController.move(point, 16.0);
    FocusScope.of(context).unfocus();
  }

  void _showPasteUrlDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Paste Google Maps Link',
          style: AppFonts.titleMedium(color: primaryTextColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paste a Google Maps share link, or coordinates copied from Google Maps:',
              style: AppFonts.bodySmall(color: secondaryTextColor),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: textCtrl,
              hint: 'https://maps.app.goo.gl/... or 9.9674, 76.2891',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
            ),
            onPressed: () {
              final text = textCtrl.text.trim();
              Navigator.of(ctx).pop();
              final coords = LocationService.instance.parseCoordinatesFromUrl(
                text,
              );
              if (coords != null) {
                setState(() => _selectedPoint = coords);
                _mapController.move(coords, 16.0);
                _reverseGeocodePoint(coords);
              } else {
                AppNotificationService.error(
                  'Could not parse coordinates from this link. Try picking on map or using GPS.',
                );
              }
            },
            child: const Text(
              'Locate on Map',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: AppCustomAppBar(
        title: 'Select Workshop Location',
        actions: [
          IconButton(
            tooltip: 'Paste Google Maps link',
            icon: const Icon(Icons.link_rounded),
            onPressed: _showPasteUrlDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPoint,
              initialZoom: 15.0,
              minZoom: 4.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                setState(() => _selectedPoint = point);
                _reverseGeocodePoint(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}&key=${LocationService.googleMapsApiKey}',
                fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.inspirezest.wefix',
                tileBuilder: (context, tileWidget, tile) {
                  if (isDark) {
                    return ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.3,
                        0.3,
                        0.3,
                        0,
                        0,
                        0.3,
                        0.3,
                        0.3,
                        0,
                        0,
                        0.3,
                        0.3,
                        0.3,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: tileWidget,
                    );
                  }
                  return tileWidget;
                },
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint,
                    width: 60,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 8,
                          color: AppColors.primaryRed,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  color: cardBg,
                  child: TextField(
                    controller: _searchCtrl,
                    style: AppFonts.bodyMedium(color: primaryTextColor),
                    decoration: InputDecoration(
                      hintText: 'Search city, area, or landmark...',
                      hintStyle: AppFonts.bodySmall(color: secondaryTextColor),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryRed,
                                ),
                              ),
                            )
                          : _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (val) => _performSearch(val, immediate: true),
                    onChanged: (val) => _performSearch(val),
                  ),
                ),
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    color: cardBg,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final item = _searchResults[i];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primaryRed,
                              size: 20,
                            ),
                            title: Text(
                              (item.street != null && item.street!.isNotEmpty)
                                  ? item.street!
                                  : item.shortAddress,
                              style: AppFonts.bodySmall(color: primaryTextColor)
                                  .copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.displayName.isNotEmpty
                                  ? item.displayName
                                  : '${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                              style: AppFonts.labelSmall(
                                color: secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(item),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 180,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'gps_button',
              backgroundColor: cardBg,
              foregroundColor: AppColors.primaryRed,
              elevation: 4,
              onPressed: _isLocating
                  ? null
                  : () => _autoDetectCurrentLocation(),
              child: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryRed,
                      ),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.pin_drop_rounded,
                            color: AppColors.primaryRed,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isReverseGeocoding
                                    ? 'Resolving address...'
                                    : (_currentAddress.isNotEmpty
                                          ? _currentAddress
                                          : 'Selected Location'),
                                style: AppFonts.titleSmall(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Lat: ${_selectedPoint.latitude.toStringAsFixed(5)}, Lng: ${_selectedPoint.longitude.toStringAsFixed(5)}',
                                style: AppFonts.labelSmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: AppFonts.bodySmall(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            label: 'Confirm Location',
                            onPressed: () {
                              Navigator.of(context).pop(
                                LocationPickResult(
                                  latitude: _selectedPoint.latitude,
                                  longitude: _selectedPoint.longitude,
                                  address: _currentAddress,
                                  city: _detectedCity,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
