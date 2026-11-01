import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';

import '../models/customer_model.dart';
import '../models/vehicle_model.dart';
import 'garage_repository_store.dart';

mixin CustomerDataRepository on GarageRepositoryStore {
  Future<List<CustomerModel>> getCustomers({
    required String garageId,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
    if (garageId.isEmpty) return [];

    if (FirebaseConfig.isInitialized &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('customers')
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 4));
        var items = snap.docs
            .map((d) => CustomerModel.fromFirestore(d.data(), d.id))
            .toList();

        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          items = items.where((c) {
            return c.name.toLowerCase().contains(q) ||
                c.phone.toLowerCase().contains(q) ||
                c.email.toLowerCase().contains(q);
          }).toList();
        }

        return items;
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_CUSTOMERS_ERROR: $e');
        return [];
      }
    }

    var query = customers.where((c) {
      if (c.garageId != garageId) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchName = c.name.toLowerCase().contains(q);
        final matchPhone = c.phone.toLowerCase().contains(q);
        final matchEmail = c.email.toLowerCase().contains(q);
        if (!matchName && !matchPhone && !matchEmail) return false;
      }
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final newCust = customer.copyWith(
      id: customer.id.isNotEmpty ? customer.id : const Uuid().v4(),
      createdAt: customer.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized && newCust.garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newCust.garageId)
            .collection('customers')
            .doc(newCust.id)
            .set(newCust.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_CREATE_CUSTOMER_ERROR: $e');
      }
    }

    customers.insert(0, newCust);
    return newCust;
  }

  Future<List<VehicleModel>> getVehicles({
    String? garageId,
    String? customerId,
    String? userEmail,
    String? search,
    int page = 0,
    int limit = 20,
  }) async {
    final effectiveCustomerId = (customerId != null && customerId.isNotEmpty)
        ? customerId
        : (userEmail != null && userEmail.isNotEmpty ? userEmail : null);
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer =
        effectiveCustomerId != null && effectiveCustomerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    if (FirebaseConfig.isInitialized &&
        FirebaseConfig.isFirestoreDatabaseReady &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        List<VehicleModel> items = [];
        if (hasCustomer) {
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(effectiveCustomerId)
              .collection('vehicles')
              .limit(limit)
              .get()
              .timeout(const Duration(seconds: 4));

          items = snapshot.docs
              .map((d) => VehicleModel.fromFirestore(d.data(), d.id))
              .toList();

          if (items.isEmpty) {
            final groupSnap = await FirebaseFirestore.instance
                .collectionGroup('vehicles')
                .where('customerId', isEqualTo: effectiveCustomerId)
                .limit(limit)
                .get()
                .timeout(const Duration(seconds: 4));

            items = groupSnap.docs
                .map((d) => VehicleModel.fromFirestore(d.data(), d.id))
                .toList();
          }
        } else if (hasGarage) {
          final garageVehSnap = await FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('vehicles')
              .limit(limit)
              .get()
              .timeout(const Duration(seconds: 4));

          items = garageVehSnap.docs
              .map((d) => VehicleModel.fromFirestore(d.data(), d.id))
              .toList();
        }

        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          items = items.where((v) {
            return v.licensePlate.toLowerCase().contains(q) ||
                v.make.toLowerCase().contains(q) ||
                v.model.toLowerCase().contains(q);
          }).toList();
        }

        return items;
      } on FirebaseException catch (e) {
        if (e.code == 'not-found' ||
            (e.message?.contains('database (default) does not exist') ==
                true)) {
          FirebaseConfig.markFirestoreUnavailable();
        }
        return [];
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_VEHICLES_ERROR: $e');
        return [];
      }
    }

    var query = vehicles.where((v) {
      if (hasGarage && v.garageId != garageId) return false;
      if (hasCustomer && v.customerId != effectiveCustomerId) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchPlate = v.licensePlate.toLowerCase().contains(q);
        final matchMake = v.make.toLowerCase().contains(q);
        final matchModel = v.model.toLowerCase().contains(q);
        if (!matchPlate && !matchMake && !matchModel) return false;
      }
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    final id = vehicle.id.isNotEmpty ? vehicle.id : const Uuid().v4();
    final newVeh = vehicle.copyWith(
      id: id,
      createdAt: vehicle.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized &&
        FirebaseConfig.isFirestoreDatabaseReady &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        if (newVeh.customerId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(newVeh.customerId)
              .collection('vehicles')
              .doc(newVeh.id)
              .set(newVeh.toFirestore(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 4));
        }
        if (newVeh.garageId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('garages')
              .doc(newVeh.garageId)
              .collection('vehicles')
              .doc(newVeh.id)
              .set(newVeh.toFirestore(), SetOptions(merge: true))
              .timeout(const Duration(seconds: 4));
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_CREATE_VEHICLE_ERROR: $e');
      }
    }

    vehicles.insert(0, newVeh);
    return newVeh;
  }
}
