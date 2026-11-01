import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/pagination/paginated_result.dart';

import '../models/job_status_history_model.dart';
import '../models/notification_model.dart';
import '../models/service_job_model.dart';
import '../models/service_reminder_model.dart';
import 'garage_repository_store.dart';

mixin ServiceJobRepository on GarageRepositoryStore {
  Future<List<ServiceJobModel>> getServiceJobs({
    String? garageId,
    String? customerId,
    String? userEmail,
    String? status,
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
        FirebaseAuth.instance.currentUser != null) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('serviceJobs');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: effectiveCustomerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('serviceJobs')
              .where('customerId', isEqualTo: effectiveCustomerId);
        }

        if (status != null && status.isNotEmpty) {
          query = query.where('status', isEqualTo: status);
        }

        query = query.limit(limit);
        final snapshot = await query.get().timeout(const Duration(seconds: 4));
        var items = snapshot.docs
            .map((d) => ServiceJobModel.fromFirestore(d.data(), d.id))
            .toList();

        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          items = items.where((j) {
            return j.jobNumber.toLowerCase().contains(q) ||
                j.vehicleDisplay.toLowerCase().contains(q) ||
                j.customerName.toLowerCase().contains(q);
          }).toList();
        }

        items.sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

        return items;
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_SERVICE_JOBS_ERROR: $e');
        return [];
      }
    }

    var query = jobs.where((j) {
      if (hasGarage && j.garageId != garageId) return false;
      if (hasCustomer && j.customerId != effectiveCustomerId) return false;
      if (status != null && status.isNotEmpty && j.status != status) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchJobNo = j.jobNumber.toLowerCase().contains(q);
        final matchVehicle = j.vehicleDisplay.toLowerCase().contains(q);
        final matchCustomer = j.customerName.toLowerCase().contains(q);
        if (!matchJobNo && !matchVehicle && !matchCustomer) return false;
      }
      return true;
    }).toList();

    query.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<PaginatedResult<ServiceJobModel>> getServiceJobsPaginated({
    String? garageId,
    String? customerId,
    String? status,
    String? search,
    int limit = 10,
    Object? lastDocument,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return const PaginatedResult<ServiceJobModel>(
        items: [],
        lastDocument: null,
        hasMore: false,
      );
    }

    if (FirebaseConfig.isInitialized &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('serviceJobs');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('serviceJobs')
              .where('customerId', isEqualTo: customerId);
        }

        if (status != null && status.isNotEmpty) {
          query = query.where('status', isEqualTo: status);
        }

        query = query.limit(limit);

        if (lastDocument is DocumentSnapshot<Map<String, dynamic>>) {
          query = query.startAfterDocument(lastDocument);
        }

        final snapshot = await query.get().timeout(const Duration(seconds: 4));
        var items = snapshot.docs
            .map((d) => ServiceJobModel.fromFirestore(d.data(), d.id))
            .toList();

        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          items = items.where((j) {
            return j.jobNumber.toLowerCase().contains(q) ||
                j.vehicleDisplay.toLowerCase().contains(q) ||
                j.customerName.toLowerCase().contains(q);
          }).toList();
        }

        final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        final hasMore = snapshot.docs.length >= limit;

        return PaginatedResult<ServiceJobModel>(
          items: items,
          lastDocument: lastDoc,
          hasMore: hasMore,
        );
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_SERVICE_JOBS_PAGINATED_ERROR: $e');
        return const PaginatedResult<ServiceJobModel>(
          items: [],
          lastDocument: null,
          hasMore: false,
        );
      }
    }

    var query = jobs.where((j) {
      if (hasGarage && j.garageId != garageId) return false;
      if (hasCustomer && j.customerId != customerId) return false;
      if (status != null && status.isNotEmpty && j.status != status) {
        return false;
      }
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        final matchJobNo = j.jobNumber.toLowerCase().contains(q);
        final matchVehicle = j.vehicleDisplay.toLowerCase().contains(q);
        final matchCustomer = j.customerName.toLowerCase().contains(q);
        if (!matchJobNo && !matchVehicle && !matchCustomer) return false;
      }
      return true;
    }).toList();

    query.sort(
      (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
        a.createdAt ?? DateTime.now(),
      ),
    );

    int startIndex = 0;
    if (lastDocument is int) {
      startIndex = lastDocument;
    }

    if (startIndex >= query.length) {
      return const PaginatedResult<ServiceJobModel>(
        items: [],
        lastDocument: null,
        hasMore: false,
      );
    }

    final endIndex = math.min(startIndex + limit, query.length);
    final pageItems = query.sublist(startIndex, endIndex);
    final nextDoc = endIndex < query.length ? endIndex : null;

    return PaginatedResult<ServiceJobModel>(
      items: pageItems,
      lastDocument: nextDoc,
      hasMore: nextDoc != null,
    );
  }

  Future<ServiceJobModel> createServiceJob(ServiceJobModel job) async {
    final id = job.id.isNotEmpty ? job.id : const Uuid().v4();
    final newJob = job.copyWith(
      id: id,
      createdAt: job.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (FirebaseConfig.isInitialized && newJob.garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newJob.garageId)
            .collection('serviceJobs')
            .doc(newJob.id)
            .set(newJob.toFirestore(), SetOptions(merge: true));

        final history = JobStatusHistoryModel(
          id: const Uuid().v4(),
          jobId: newJob.id,
          fromStatus: 'none',
          toStatus: newJob.status,
          notes: 'Job created',
          updatedBy: 'Staff',
          timestamp: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newJob.garageId)
            .collection('serviceJobs')
            .doc(newJob.id)
            .collection('history')
            .doc(history.id)
            .set(history.toFirestore());
      } catch (_) {}
    }

    jobs.insert(0, newJob);

    jobHistory.insert(
      0,
      JobStatusHistoryModel(
        id: const Uuid().v4(),
        jobId: newJob.id,
        fromStatus: 'none',
        toStatus: newJob.status,
        notes: 'Job created',
        updatedBy: 'Staff',
        timestamp: DateTime.now(),
      ),
    );

    return newJob;
  }

  Future<ServiceJobModel> startRepair({
    required String garageId,
    required String jobId,
    required String startedByUid,
    String? technicianName,
    String? notes,
  }) async {
    final index = jobs.indexWhere((j) => j.id == jobId);
    final now = DateTime.now();
    ServiceJobModel targetJob;
    if (index >= 0) {
      final old = jobs[index];
      targetJob = old.copyWith(
        status: 'in_progress',
        actualStartTime: now,
        technicianName: (technicianName != null && technicianName.isNotEmpty)
            ? technicianName
            : old.technicianName,
        customerNotes: (notes != null && notes.isNotEmpty)
            ? notes
            : old.customerNotes,
        updatedAt: now,
      );
      jobs[index] = targetJob;
    } else {
      targetJob = ServiceJobModel(
        id: jobId,
        garageId: garageId,
        customerId: '',
        vehicleId: '',
        jobNumber: '',
        status: 'in_progress',
        actualStartTime: now,
        technicianName: technicianName ?? '',
        customerNotes: notes ?? '',
        updatedAt: now,
      );
    }

    final historyItem = JobStatusHistoryModel(
      id: const Uuid().v4(),
      jobId: jobId,
      fromStatus: index >= 0 ? jobs[index].status : 'received',
      toStatus: 'in_progress',
      notes: (notes != null && notes.isNotEmpty)
          ? notes
          : 'Repair work commenced.',
      updatedBy: startedByUid,
      isCustomerVisible: true,
      timestamp: now,
    );
    jobHistory.insert(0, historyItem);

    if (targetJob.customerId.isNotEmpty) {
      notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: targetJob.customerId,
          title: 'Repair Started: ${targetJob.vehicleDisplay}',
          body: (notes != null && notes.isNotEmpty)
              ? notes
              : 'Work has officially started on your vehicle.',
          type: 'job_status',
          referenceId: jobId,
          referenceType: 'service_job',
          deepLink: '/customer/jobs/$jobId',
          garageId: garageId,
          eventId: 'job_${jobId}_in_progress',
          isRead: false,
          createdAt: now,
        ),
      );
    }

    if (FirebaseConfig.isInitialized && garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .update({
              'status': 'in_progress',
              'actualStartTime': now.toIso8601String(),
              if (technicianName != null && technicianName.isNotEmpty)
                'technicianName': technicianName,
              if (notes != null && notes.isNotEmpty) 'customerNotes': notes,
              'updatedAt': now.toIso8601String(),
            });

        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .collection('history')
            .doc(historyItem.id)
            .set(historyItem.toFirestore());

        if (targetJob.customerId.isNotEmpty) {
          final notifId = 'job_${jobId}_in_progress';
          await FirebaseFirestore.instance
              .collection('users')
              .doc(targetJob.customerId)
              .collection('notifications')
              .doc(notifId)
              .set({
                'recipientUid': targetJob.customerId,
                'title': 'Repair Started: ${targetJob.vehicleDisplay}',
                'body': (notes != null && notes.isNotEmpty)
                    ? notes
                    : 'Work has officially started on your vehicle.',
                'type': 'job_status',
                'referenceId': jobId,
                'referenceType': 'service_job',
                'deepLink': '/customer/jobs/$jobId',
                'garageId': garageId,
                'eventId': notifId,
                'isRead': false,
                'createdAt': now.toIso8601String(),
              }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_START_REPAIR_ERROR: $e');
      }
    }

    return targetJob;
  }

  Future<ServiceJobModel> completeRepair({
    required String garageId,
    required String jobId,
    required String completedByUid,
    int? finalOdometer,
    DateTime? nextServiceDue,
    int? nextServiceOdometer,
    String? nextServiceType,
    String? notes,
  }) async {
    final gatePass = await generateGatePass(garageId, jobId);
    final now = DateTime.now();
    final index = jobs.indexWhere((j) => j.id == jobId);
    ServiceJobModel targetJob;

    if (index >= 0) {
      final old = jobs[index];
      targetJob = old.copyWith(
        status: 'completed',
        completedDate: now,
        odometerReading: finalOdometer ?? old.odometerReading,
        nextRecommendedServiceDate: nextServiceDue,
        nextRecommendedOdometer: nextServiceOdometer,
        nextRecommendedServiceType: nextServiceType,
        customerNotes: (notes != null && notes.isNotEmpty)
            ? notes
            : old.customerNotes,
        gatePassCode: gatePass,
        updatedAt: now,
      );
      jobs[index] = targetJob;
    } else {
      targetJob = ServiceJobModel(
        id: jobId,
        garageId: garageId,
        customerId: '',
        vehicleId: '',
        jobNumber: '',
        status: 'completed',
        completedDate: now,
        odometerReading: finalOdometer ?? 0,
        nextRecommendedServiceDate: nextServiceDue,
        nextRecommendedOdometer: nextServiceOdometer,
        nextRecommendedServiceType: nextServiceType,
        customerNotes: notes ?? '',
        gatePassCode: gatePass,
        updatedAt: now,
      );
    }

    final historyItem = JobStatusHistoryModel(
      id: const Uuid().v4(),
      jobId: jobId,
      fromStatus: index >= 0 ? jobs[index].status : 'in_progress',
      toStatus: 'completed',
      notes: (notes != null && notes.isNotEmpty)
          ? notes
          : 'Service completed and vehicle released for delivery.',
      updatedBy: completedByUid,
      isCustomerVisible: true,
      timestamp: now,
    );
    jobHistory.insert(0, historyItem);

    final vehicleIndex = vehicles.indexWhere(
      (v) =>
          v.id == targetJob.vehicleId ||
          (targetJob.vehicleId.isNotEmpty && v.id == targetJob.vehicleId),
    );
    if (vehicleIndex >= 0) {
      final v = vehicles[vehicleIndex];
      vehicles[vehicleIndex] = v.copyWith(
        currentOdometer: finalOdometer ?? v.currentOdometer,
        lastServiceDate: now,
        lastServiceType: nextServiceType ?? 'General Service',
        nextServiceDue: nextServiceDue,
        nextServiceOdometer: nextServiceOdometer,
        lastServicedGarageId: garageId,
        lastServiceJobId: jobId,
      );
    }

    if (nextServiceDue != null || nextServiceOdometer != null) {
      reminders.removeWhere(
        (r) => r.vehicleId == targetJob.vehicleId && r.status == 'pending',
      );
      reminders.insert(
        0,
        ServiceReminderModel(
          id: const Uuid().v4(),
          garageId: garageId,
          customerId: targetJob.customerId,
          vehicleId: targetJob.vehicleId,
          vehicleDisplay: targetJob.vehicleDisplay,
          title: '${nextServiceType ?? "Next Service"} Due',
          serviceType: nextServiceType ?? 'Routine Service',
          dueDate: nextServiceDue ?? now.add(const Duration(days: 90)),
          dueMileage: nextServiceOdometer ?? 0,
          status: 'pending',
          isCustomerReported: false,
          notes: 'Scheduled upon job completion #${targetJob.jobNumber}',
          createdAt: now,
        ),
      );
    }

    if (targetJob.customerId.isNotEmpty) {
      notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: targetJob.customerId,
          title: 'Service Completed: ${targetJob.vehicleDisplay}',
          body:
              'Your service is complete and ready for pickup! Gate pass: $gatePass.',
          type: 'job_status',
          referenceId: jobId,
          referenceType: 'service_job',
          deepLink:
              '/customer/garages/${targetJob.garageId}?action=review&jobId=$jobId',
          garageId: garageId,
          eventId: 'job_${jobId}_completed',
          isRead: false,
          createdAt: now,
        ),
      );
    }

    if (FirebaseConfig.isInitialized && garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .update({
              'status': 'completed',
              'completedDate': now.toIso8601String(),
              'odometerReading': ?finalOdometer,
              'nextRecommendedServiceDate': ?nextServiceDue?.toIso8601String(),
              'nextRecommendedOdometer': ?nextServiceOdometer,
              'nextRecommendedServiceType': ?nextServiceType,
              if (notes != null && notes.isNotEmpty) 'customerNotes': notes,
              'gatePassCode': gatePass,
              'updatedAt': now.toIso8601String(),
            });

        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .collection('history')
            .doc(historyItem.id)
            .set(historyItem.toFirestore());

        if (targetJob.vehicleId.isNotEmpty) {
          final vehUpdates = <String, dynamic>{
            'currentOdometer': ?finalOdometer,
            'lastServiceDate': now.toIso8601String(),
            'lastServiceType': ?nextServiceType,
            'nextServiceDue': ?nextServiceDue?.toIso8601String(),
            'nextServiceOdometer': ?nextServiceOdometer,
            'lastServicedGarageId': garageId,
            'lastServiceJobId': jobId,
          };

          if (targetJob.customerId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(targetJob.customerId)
                .collection('vehicles')
                .doc(targetJob.vehicleId)
                .update(vehUpdates);
          }
          await FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('vehicles')
              .doc(targetJob.vehicleId)
              .update(vehUpdates);
        }

        if (targetJob.customerId.isNotEmpty) {
          final notifId = 'job_${jobId}_completed';
          await FirebaseFirestore.instance
              .collection('users')
              .doc(targetJob.customerId)
              .collection('notifications')
              .doc(notifId)
              .set({
                'recipientUid': targetJob.customerId,
                'title': 'Service Completed: ${targetJob.vehicleDisplay}',
                'body':
                    'Your service is complete and ready for pickup! Gate pass: $gatePass.',
                'type': 'job_status',
                'referenceId': jobId,
                'referenceType': 'service_job',
                'deepLink':
                    '/customer/garages/${targetJob.garageId}?action=review&jobId=$jobId',
                'garageId': garageId,
                'eventId': notifId,
                'isRead': false,
                'createdAt': now.toIso8601String(),
              }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_COMPLETE_REPAIR_ERROR: $e');
      }
    }

    return targetJob;
  }

  Future<void> updateJobStatus({
    required String jobId,
    required String newStatus,
    required String notes,
    required String updatedBy,
    bool isCustomerVisible = true,
  }) async {
    final index = jobs.indexWhere((j) => j.id == jobId);
    ServiceJobModel? targetJob;
    if (index >= 0) {
      final old = jobs[index];
      targetJob = old.copyWith(
        status: newStatus,
        customerNotes: notes.isNotEmpty ? notes : old.customerNotes,
        updatedAt: DateTime.now(),
      );
      jobs[index] = targetJob;

      jobHistory.insert(
        0,
        JobStatusHistoryModel(
          id: const Uuid().v4(),
          jobId: jobId,
          fromStatus: old.status,
          toStatus: newStatus,
          notes: notes,
          updatedBy: updatedBy,
          isCustomerVisible: isCustomerVisible,
          timestamp: DateTime.now(),
        ),
      );

      final isCompletion = newStatus == 'completed';
      final deepLink = isCompletion
          ? '/customer/garages/${old.garageId}?action=review&jobId=$jobId'
          : '/customer/jobs/$jobId';
      final notifTitle = isCompletion
          ? 'Service Completed: ${old.vehicleDisplay}'
          : 'Status Updated: ${old.vehicleDisplay}';
      final notifBody = isCompletion
          ? (notes.isNotEmpty
                ? notes
                : 'Your vehicle service is complete! Tap to rate your experience.')
          : (notes.isNotEmpty
                ? notes
                : 'Your vehicle repair status is now $newStatus.');

      notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: old.customerId,
          title: notifTitle,
          body: notifBody,
          type: 'job_status',
          referenceId: jobId,
          referenceType: 'service_job',
          imageUrl: isCompletion
              ? 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80'
              : 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
          deepLink: deepLink,
          garageId: old.garageId,
          eventId: 'job_${jobId}_$newStatus',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (FirebaseConfig.isInitialized && targetJob != null) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(targetJob.garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .update({
              'status': newStatus,
              if (notes.isNotEmpty) 'customerNotes': notes,
              'updatedAt': DateTime.now().toIso8601String(),
            });

        final historyId = const Uuid().v4();
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(targetJob.garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .collection('history')
            .doc(historyId)
            .set({
              'id': historyId,
              'jobId': jobId,
              'fromStatus': targetJob.status,
              'toStatus': newStatus,
              'notes': notes,
              'updatedBy': updatedBy,
              'isCustomerVisible': isCustomerVisible,
              'timestamp': DateTime.now().toIso8601String(),
            });

        final isCompletion = newStatus == 'completed';
        final deepLink = isCompletion
            ? '/customer/garages/${targetJob.garageId}?action=review&jobId=$jobId'
            : '/customer/jobs/$jobId';
        final notifTitle = isCompletion
            ? 'Service Completed: ${targetJob.vehicleDisplay}'
            : 'Status Updated: ${targetJob.vehicleDisplay}';
        final notifBody = isCompletion
            ? (notes.isNotEmpty
                  ? notes
                  : 'Your vehicle service is complete! Tap to rate your experience.')
            : (notes.isNotEmpty
                  ? notes
                  : 'Your vehicle repair status is now $newStatus.');

        final notifId = 'job_${jobId}_$newStatus';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(targetJob.customerId)
            .collection('notifications')
            .doc(notifId)
            .set({
              'recipientUid': targetJob.customerId,
              'title': notifTitle,
              'body': notifBody,
              'type': 'job_status',
              'referenceId': jobId,
              'referenceType': 'service_job',
              'imageUrl': isCompletion
                  ? 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80'
                  : 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
              'deepLink': deepLink,
              'garageId': targetJob.garageId,
              'eventId': notifId,
              'isRead': false,
              'createdAt': DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<List<JobStatusHistoryModel>> getJobHistory(
    String jobId, {
    bool customerOnly = false,
  }) async {
    List<JobStatusHistoryModel> list = [];
    if (FirebaseConfig.isInitialized &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collectionGroup('history')
            .where('jobId', isEqualTo: jobId)
            .get()
            .timeout(const Duration(seconds: 3));
        if (snapshot.docs.isNotEmpty) {
          list = snapshot.docs
              .map((d) => JobStatusHistoryModel.fromFirestore(d.data(), d.id))
              .toList();
        }
      } catch (_) {}
    }
    if (list.isEmpty) {
      list = jobHistory.where((h) => h.jobId == jobId).toList();
    }
    if (customerOnly) {
      list = list.where((h) => h.isCustomerVisible).toList();
    }
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
}
