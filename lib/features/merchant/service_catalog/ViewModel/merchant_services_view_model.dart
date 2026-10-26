import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/garage_service_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

import '../Model/merchant_services_state.dart';

class MerchantServicesViewModel extends Notifier<MerchantServicesState> {
  late final GarageRepository _repo;

  @override
  MerchantServicesState build() {
    _repo = ref.watch(garageRepositoryProvider);
    Future.microtask(loadServices);
    return const MerchantServicesState(isLoading: true);
  }

  String _getGarageId() {
    final user = ref.read(authViewModelProvider).userProfile;
    return user?.garageId != null && user!.garageId!.isNotEmpty
        ? user.garageId!
        : 'garage_demo_1';
  }

  Future<void> loadServices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final garageId = _getGarageId();
      final list = await _repo.getGarageServices(garageId);
      state = state.copyWith(services: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load service catalog: $e',
      );
    }
  }

  Future<bool> saveService(GarageServiceModel service) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final garageId = _getGarageId();
      await _repo.saveGarageService(garageId, service);
      await loadServices();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save service: $e',
      );
      return false;
    }
  }

  Future<void> toggleActive(String serviceId, bool isActive) async {
    final garageId = _getGarageId();
    await _repo.toggleServiceActive(garageId, serviceId, isActive);
    final updated = state.services.map((s) {
      if (s.id == serviceId) {
        return s.copyWith(isActive: isActive);
      }
      return s;
    }).toList();
    state = state.copyWith(services: updated);
  }

  Future<void> deleteService(String serviceId) async {
    final garageId = _getGarageId();
    await _repo.deleteGarageService(garageId, serviceId);
    final updated = state.services.where((s) => s.id != serviceId).toList();
    state = state.copyWith(services: updated);
  }

  void filterCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final merchantServicesViewModelProvider =
    NotifierProvider<MerchantServicesViewModel, MerchantServicesState>(
      MerchantServicesViewModel.new,
    );
