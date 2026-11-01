import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';

import '../models/appointment_model.dart';
import '../models/notification_model.dart';
import '../models/service_reminder_model.dart';
import 'garage_repository_store.dart';

mixin AppointmentRepository on GarageRepositoryStore {
  Future<List<ServiceReminderModel>> getReminders({
    String? garageId,
    String? customerId,
    String? userEmail,
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
        FirebaseAuth.instance.currentUser != null) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('reminders');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: effectiveCustomerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('reminders')
              .where('customerId', isEqualTo: effectiveCustomerId);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 4));

        return snapshot.docs
            .map((d) => ServiceReminderModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_REMINDERS_ERROR: $e');
        return [];
      }
    }

    return reminders.where((r) {
      if (hasGarage && r.garageId != garageId) return false;
      if (hasCustomer && r.customerId != effectiveCustomerId) return false;
      return true;
    }).toList();
  }

  Future<ServiceReminderModel> createReminder(
    ServiceReminderModel reminder,
  ) async {
    final id = reminder.id.isNotEmpty ? reminder.id : const Uuid().v4();
    final newRem = reminder.copyWith(
      id: id,
      createdAt: reminder.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        if (newRem.garageId.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('garages')
              .doc(newRem.garageId)
              .collection('reminders')
              .doc(newRem.id)
              .set(newRem.toFirestore(), SetOptions(merge: true));
        }
      } catch (_) {}
    }

    reminders.insert(0, newRem);
    return newRem;
  }

  Future<List<AppointmentModel>> getAppointments({
    String? garageId,
    String? customerId,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    if (FirebaseConfig.isInitialized &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('appointments');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('appointments')
              .where('customerId', isEqualTo: customerId);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 4));

        return snapshot.docs
            .map((d) => AppointmentModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_APPOINTMENTS_ERROR: $e');
        return [];
      }
    }

    return appointments.where((a) {
      if (hasGarage && a.garageId != garageId) return false;
      if (hasCustomer && a.customerId != customerId) return false;
      return true;
    }).toList();
  }

  Future<AppointmentModel> createAppointment(
    AppointmentModel appointment,
  ) async {
    final id = appointment.id.isNotEmpty ? appointment.id : const Uuid().v4();
    final newApp = appointment.copyWith(
      id: id,
      createdAt: appointment.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized && newApp.garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newApp.garageId)
            .collection('appointments')
            .doc(newApp.id)
            .set(newApp.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_CREATE_APPOINTMENT_ERROR: $e');
      }
    }

    appointments.insert(0, newApp);

    notifications.insert(
      0,
      NotificationModel(
        id: const Uuid().v4(),
        recipientUid: newApp.garageId,
        title: 'New Service Request Received',
        body:
            '${appointment.customerName} requested an appointment for ${appointment.vehicleInfo}.',
        type: 'serviceRequestSubmitted',
        referenceId: newApp.id,
        referenceType: 'appointment',
        imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
        deepLink: '/merchant/jobs',
        garageId: appointment.garageId,
        eventId: 'app_${newApp.id}_submitted',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    return newApp;
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    final idx = appointments.indexWhere((a) => a.id == appointmentId);
    if (idx >= 0) {
      appointments[idx] = appointments[idx].copyWith(status: newStatus);
    }
  }
}
