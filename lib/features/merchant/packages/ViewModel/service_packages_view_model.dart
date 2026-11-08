import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:uuid/uuid.dart';

import '../Model/service_package_model.dart';

final servicePackagesViewModelProvider =
    NotifierProvider<ServicePackagesViewModel, ServicePackagesState>(
      ServicePackagesViewModel.new,
    );

class ServicePackagesViewModel extends Notifier<ServicePackagesState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return '';
  }

  @override
  ServicePackagesState build() {
    Future.microtask(_loadPackages);
    return const ServicePackagesState(isLoading: true);
  }

  Future<void> _loadPackages() async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (FirebaseConfig.isInitialized) {
        final snap = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('packages')
            .get();

        if (snap.docs.isEmpty) {
          final defaults = await _seedDefaultPackages(garageId);
          state = state.copyWith(isLoading: false, packages: defaults);
          return;
        }

        final packages = snap.docs
            .map((doc) => ServicePackageModel.fromFirestore(doc.data(), doc.id))
            .toList();

        packages.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

        state = state.copyWith(isLoading: false, packages: packages);
      } else {
        final mockPackages = _fallbackPackages(garageId);
        state = state.copyWith(isLoading: false, packages: mockPackages);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<List<ServicePackageModel>> _seedDefaultPackages(
    String garageId,
  ) async {
    final defaults = [
      ServicePackageModel(
        id: const Uuid().v4(),
        garageId: garageId,
        title: 'Monsoon Special Care',
        description: 'Comprehensive rain check, electrical waterproofing & brake overhaul.',
        includedServices: const [
          'Full High-Pressure Water Wash',
          'Chain Clean & Synthetic Lube',
          'Front & Rear Brake Pad Cleaning',
          'Electrical Wire Moisture Proofing',
          'Air Filter Inspection',
        ],
        originalPrice: 850.0,
        packagePrice: 499.0,
        vehicleType: 'twoWheeler',
        validityDays: 30,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      ServicePackageModel(
        id: const Uuid().v4(),
        garageId: garageId,
        title: 'Festival Complete Overhaul',
        description: 'All-in-one general service with oil change, engine tuning & multi-point checkup.',
        includedServices: const [
          'Engine Oil & Filter Replacement',
          'Spark Plug Cleaning & Gap Check',
          'Carburetor / Injector Fine Tuning',
          'Clutch & Throttle Cable Free Play',
          'Battery Health & Terminal Grease',
          'Final Polish & Wash',
        ],
        originalPrice: 1600.0,
        packagePrice: 999.0,
        vehicleType: 'all',
        validityDays: 45,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    if (FirebaseConfig.isInitialized) {
      final batch = FirebaseFirestore.instance.batch();
      for (final p in defaults) {
        final ref = FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('packages')
            .doc(p.id);
        batch.set(ref, p.toFirestore());
      }
      await batch.commit();
    }

    return defaults;
  }

  List<ServicePackageModel> _fallbackPackages(String garageId) {
    return [
      ServicePackageModel(
        id: 'pkg-1',
        garageId: garageId,
        title: 'Monsoon Special Care',
        description: 'Comprehensive rain check, electrical waterproofing & brake overhaul.',
        includedServices: const [
          'Full High-Pressure Water Wash',
          'Chain Clean & Synthetic Lube',
          'Front & Rear Brake Pad Cleaning',
        ],
        originalPrice: 850.0,
        packagePrice: 499.0,
        vehicleType: 'twoWheeler',
        validityDays: 30,
        isActive: true,
      ),
    ];
  }

  void setFilterActiveOnly(bool activeOnly) {
    state = state.copyWith(filterActiveOnly: activeOnly);
  }

  Future<bool> createPackage({
    required String title,
    required String description,
    required List<String> includedServices,
    required double originalPrice,
    required double packagePrice,
    required String vehicleType,
    required int validityDays,
  }) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty || title.trim().isEmpty) return false;

    try {
      final newPkg = ServicePackageModel(
        id: const Uuid().v4(),
        garageId: garageId,
        title: title.trim(),
        description: description.trim(),
        includedServices: includedServices,
        originalPrice: originalPrice,
        packagePrice: packagePrice,
        vehicleType: vehicleType,
        validityDays: validityDays,
        isActive: true,
        createdAt: DateTime.now(),
      );

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('packages')
            .doc(newPkg.id)
            .set(newPkg.toFirestore());
      }

      state = state.copyWith(packages: [newPkg, ...state.packages]);
      AppNotificationService.success('Package created successfully');
      return true;
    } catch (e) {
      AppNotificationService.error('Failed to create package: $e');
      return false;
    }
  }

  Future<void> toggleActive(String packageId) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return;

    try {
      final pkg = state.packages.firstWhere((p) => p.id == packageId);
      final newStatus = !pkg.isActive;

      final updated = state.packages.map((p) {
        if (p.id == packageId) {
          return p.copyWith(isActive: newStatus);
        }
        return p;
      }).toList();

      state = state.copyWith(packages: updated);

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('packages')
            .doc(packageId)
            .update({'isActive': newStatus});
      }

      AppNotificationService.info(
        newStatus ? 'Package activated' : 'Package paused',
      );
    } catch (e) {
      AppNotificationService.error('Failed to update package: $e');
    }
  }

  Future<void> deletePackage(String packageId) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return;

    try {
      state = state.copyWith(
        packages: state.packages.where((p) => p.id != packageId).toList(),
      );

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('packages')
            .doc(packageId)
            .delete();
      }

      AppNotificationService.success('Package deleted');
    } catch (e) {
      AppNotificationService.error('Failed to delete package: $e');
    }
  }

  Future<void> refresh() async {
    await _loadPackages();
  }
}
