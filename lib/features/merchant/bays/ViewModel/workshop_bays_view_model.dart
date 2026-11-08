import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/notifications/app_notification_service.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:uuid/uuid.dart';

import '../Model/workshop_bay_model.dart';

final workshopBaysViewModelProvider =
    NotifierProvider<WorkshopBaysViewModel, WorkshopBaysState>(
      WorkshopBaysViewModel.new,
    );

class WorkshopBaysViewModel extends Notifier<WorkshopBaysState> {
  String _effectiveGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    if (user?.garageId != null && user!.garageId!.isNotEmpty) {
      return user.garageId!;
    }
    return '';
  }

  @override
  WorkshopBaysState build() {
    Future.microtask(_loadBays);
    return const WorkshopBaysState(isLoading: true);
  }

  Future<void> _loadBays() async {
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
            .collection('bays')
            .get();

        if (snap.docs.isEmpty) {
          final defaultBays = await _seedDefaultBays(garageId);
          state = state.copyWith(isLoading: false, bays: defaultBays);
          return;
        }

        final bays = snap.docs
            .map((doc) => WorkshopBayModel.fromFirestore(doc.data(), doc.id))
            .toList();

        bays.sort((a, b) => a.name.compareTo(b.name));
        state = state.copyWith(isLoading: false, bays: bays);
      } else {
        final mockBays = _fallbackBays(garageId);
        state = state.copyWith(isLoading: false, bays: mockBays);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<List<WorkshopBayModel>> _seedDefaultBays(String garageId) async {
    final defaults = [
      WorkshopBayModel(
        id: const Uuid().v4(),
        garageId: garageId,
        name: 'Ramp 1 (Hydraulic Lift)',
        type: 'twoWheeler',
        status: 'available',
      ),
      WorkshopBayModel(
        id: const Uuid().v4(),
        garageId: garageId,
        name: 'Bay 2 (Quick Service)',
        type: 'quickService',
        status: 'available',
      ),
      WorkshopBayModel(
        id: const Uuid().v4(),
        garageId: garageId,
        name: 'Bay 3 (Washing & Detailing)',
        type: 'detailing',
        status: 'available',
      ),
    ];

    if (FirebaseConfig.isInitialized) {
      final batch = FirebaseFirestore.instance.batch();
      for (final b in defaults) {
        final ref = FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('bays')
            .doc(b.id);
        batch.set(ref, b.toFirestore());
      }
      await batch.commit();
    }

    return defaults;
  }

  List<WorkshopBayModel> _fallbackBays(String garageId) {
    return [
      WorkshopBayModel(
        id: 'bay-1',
        garageId: garageId,
        name: 'Ramp 1 (Hydraulic Lift)',
        type: 'twoWheeler',
        status: 'available',
      ),
      WorkshopBayModel(
        id: 'bay-2',
        garageId: garageId,
        name: 'Bay 2 (Quick Service)',
        type: 'quickService',
        status: 'available',
      ),
      WorkshopBayModel(
        id: 'bay-3',
        garageId: garageId,
        name: 'Bay 3 (Washing & Detailing)',
        type: 'detailing',
        status: 'available',
      ),
    ];
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status);
  }

  Future<bool> createBay({required String name, required String type}) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty || name.trim().isEmpty) return false;

    try {
      final newBay = WorkshopBayModel(
        id: const Uuid().v4(),
        garageId: garageId,
        name: name.trim(),
        type: type,
        status: 'available',
        updatedAt: DateTime.now(),
      );

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('bays')
            .doc(newBay.id)
            .set(newBay.toFirestore());
      }

      state = state.copyWith(bays: [...state.bays, newBay]);
      AppNotificationService.success('Bay created successfully');
      return true;
    } catch (e) {
      AppNotificationService.error('Failed to create bay: $e');
      return false;
    }
  }

  Future<bool> assignJobToBay({
    required String bayId,
    required String jobId,
    required String vehicleDisplay,
    required String mechanic,
  }) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return false;

    try {
      final now = DateTime.now();
      final updatedBays = state.bays.map((b) {
        if (b.id == bayId) {
          return b.copyWith(
            status: 'occupied',
            currentJobId: jobId,
            currentVehicleDisplay: vehicleDisplay,
            currentMechanic: mechanic,
            assignedAt: now,
            updatedAt: now,
          );
        }
        return b;
      }).toList();

      state = state.copyWith(bays: updatedBays);

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('bays')
            .doc(bayId)
            .update({
              'status': 'occupied',
              'currentJobId': jobId,
              'currentVehicleDisplay': vehicleDisplay,
              'currentMechanic': mechanic,
              'assignedAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            });
      }

      AppNotificationService.success('Job assigned to bay');
      return true;
    } catch (e) {
      AppNotificationService.error('Failed to assign job: $e');
      return false;
    }
  }

  Future<bool> releaseBay(String bayId) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return false;

    try {
      final now = DateTime.now();
      final updatedBays = state.bays.map((b) {
        if (b.id == bayId) {
          return WorkshopBayModel(
            id: b.id,
            garageId: b.garageId,
            name: b.name,
            type: b.type,
            status: 'available',
            updatedAt: now,
          );
        }
        return b;
      }).toList();

      state = state.copyWith(bays: updatedBays);

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('bays')
            .doc(bayId)
            .update({
              'status': 'available',
              'currentJobId': null,
              'currentVehicleDisplay': null,
              'currentMechanic': null,
              'assignedAt': null,
              'updatedAt': now.toIso8601String(),
            });
      }

      AppNotificationService.success('Bay marked available');
      return true;
    } catch (e) {
      AppNotificationService.error('Failed to release bay: $e');
      return false;
    }
  }

  Future<void> toggleMaintenance(String bayId) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return;

    try {
      final bay = state.bays.firstWhere((b) => b.id == bayId);
      final newStatus = bay.isMaintenance ? 'available' : 'maintenance';
      final now = DateTime.now();

      final updatedBays = state.bays.map((b) {
        if (b.id == bayId) {
          return b.copyWith(status: newStatus, updatedAt: now);
        }
        return b;
      }).toList();

      state = state.copyWith(bays: updatedBays);

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('bays')
            .doc(bayId)
            .update({'status': newStatus, 'updatedAt': now.toIso8601String()});
      }

      AppNotificationService.info('Bay status: $newStatus');
    } catch (e) {
      AppNotificationService.error('Failed to update status: $e');
    }
  }

  Future<void> deleteBay(String bayId) async {
    final garageId = _effectiveGarageId();
    if (garageId.isEmpty) return;

    try {
      state = state.copyWith(
        bays: state.bays.where((b) => b.id != bayId).toList(),
      );

      if (FirebaseConfig.isInitialized) {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('bays')
            .doc(bayId)
            .delete();
      }

      AppNotificationService.success('Bay removed');
    } catch (e) {
      AppNotificationService.error('Failed to remove bay: $e');
    }
  }

  Future<void> refresh() async {
    await _loadBays();
  }
}
