import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';

import '../models/notification_model.dart';
import '../models/qc_checklist_model.dart';
import '../models/service_job_model.dart';
import '../models/supplemental_work_model.dart';
import '../models/vehicle_inspection_model.dart';
import 'garage_repository_store.dart';

mixin JobWorkflowRepository on GarageRepositoryStore {
  Future<void> addSupplementalWork(
    String garageId,
    String jobId,
    SupplementalWorkItem item,
  ) async {
    final id = item.id.isNotEmpty ? item.id : const Uuid().v4();
    final newItem = item.copyWith(
      id: id,
      jobId: jobId,
      createdAt: DateTime.now(),
    );
    final jobIdx = jobs.indexWhere((j) => j.id == jobId);
    if (jobIdx >= 0) {
      final job = jobs[jobIdx];
      final updatedItems = [...job.supplementalItems, newItem];
      jobs[jobIdx] = job.copyWith(
        supplementalItems: updatedItems,
        updatedAt: DateTime.now(),
      );

      final notifId = 'supp_${newItem.id}_requested';
      notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: job.customerId,
          title: 'Additional Repair Required: ${newItem.title}',
          body:
              'Mechanic found extra work: ${newItem.title} (+₹${newItem.totalAmount.toStringAsFixed(0)}). Review & approve in app.',
          type: 'supplemental_request',
          referenceId: jobId,
          referenceType: 'service_job',
          deepLink: '/customer/jobs/$jobId',
          garageId: garageId,
          eventId: notifId,
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final jobRef = FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId);
        final snap = await jobRef.get();
        if (snap.exists && snap.data() != null) {
          final currentJob = ServiceJobModel.fromFirestore(
            snap.data()!,
            snap.id,
          );
          final updatedItems = [...currentJob.supplementalItems, newItem];
          await jobRef.update({
            'supplementalItems': updatedItems.map((s) => s.toMap()).toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          });

          final notifId = 'supp_${newItem.id}_requested';
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentJob.customerId)
              .collection('notifications')
              .doc(notifId)
              .set({
                'recipientUid': currentJob.customerId,
                'title': 'Additional Repair Required: ${newItem.title}',
                'body':
                    'Mechanic found extra work: ${newItem.title} (+₹${newItem.totalAmount.toStringAsFixed(0)}). Tap to approve.',
                'type': 'supplemental_request',
                'referenceId': jobId,
                'referenceType': 'service_job',
                'deepLink': '/customer/jobs/$jobId',
                'garageId': garageId,
                'eventId': notifId,
                'isRead': false,
                'createdAt': DateTime.now().toIso8601String(),
              }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_ADD_SUPPLEMENTAL_ERROR: $e');
      }
    }
  }

  Future<void> decideSupplementalWork(
    String garageId,
    String jobId,
    String itemId,
    bool approved, {
    String? rejectionReason,
  }) async {
    final jobIdx = jobs.indexWhere((j) => j.id == jobId);
    if (jobIdx >= 0) {
      final job = jobs[jobIdx];
      final itemIdx = job.supplementalItems.indexWhere((s) => s.id == itemId);
      if (itemIdx >= 0) {
        final target = job.supplementalItems[itemIdx];
        final updatedTarget = target.copyWith(
          status: approved ? 'approved' : 'declined',
          decidedAt: DateTime.now(),
          declinedReason: rejectionReason,
        );
        final updatedList = List<SupplementalWorkItem>.from(
          job.supplementalItems,
        );
        updatedList[itemIdx] = updatedTarget;
        jobs[jobIdx] = job.copyWith(
          supplementalItems: updatedList,
          updatedAt: DateTime.now(),
        );

        final notifId = 'supp_${itemId}_${approved ? "approved" : "declined"}';
        notifications.insert(
          0,
          NotificationModel(
            id: const Uuid().v4(),
            recipientUid: job.garageId,
            title: approved
                ? 'Supplemental Work Approved'
                : 'Supplemental Work Declined',
            body: approved
                ? 'Customer approved ${target.title} (+₹${target.totalAmount.toStringAsFixed(0)}).'
                : 'Customer declined ${target.title}${rejectionReason != null && rejectionReason.isNotEmpty ? ": $rejectionReason" : ""}.',
            type: 'supplemental_decision',
            referenceId: jobId,
            referenceType: 'service_job',
            deepLink: '/merchant/jobs/$jobId',
            garageId: garageId,
            eventId: notifId,
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final jobRef = FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId);
        final snap = await jobRef.get();
        if (snap.exists && snap.data() != null) {
          final currentJob = ServiceJobModel.fromFirestore(
            snap.data()!,
            snap.id,
          );
          final itemIdx = currentJob.supplementalItems.indexWhere(
            (s) => s.id == itemId,
          );
          if (itemIdx >= 0) {
            final target = currentJob.supplementalItems[itemIdx];
            final updatedTarget = target.copyWith(
              status: approved ? 'approved' : 'declined',
              decidedAt: DateTime.now(),
              declinedReason: rejectionReason,
            );
            final updatedList = List<SupplementalWorkItem>.from(
              currentJob.supplementalItems,
            );
            updatedList[itemIdx] = updatedTarget;
            await jobRef.update({
              'supplementalItems': updatedList.map((s) => s.toMap()).toList(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

            final notifId =
                'supp_${itemId}_${approved ? "approved" : "declined"}';
            await FirebaseFirestore.instance
                .collection('users')
                .doc(garageId)
                .collection('notifications')
                .doc(notifId)
                .set({
                  'recipientUid': garageId,
                  'title': approved
                      ? 'Supplemental Work Approved'
                      : 'Supplemental Work Declined',
                  'body': approved
                      ? 'Customer approved ${target.title} (+₹${target.totalAmount.toStringAsFixed(0)}).'
                      : 'Customer declined ${target.title}.',
                  'type': 'supplemental_decision',
                  'referenceId': jobId,
                  'referenceType': 'service_job',
                  'deepLink': '/merchant/jobs/$jobId',
                  'garageId': garageId,
                  'eventId': notifId,
                  'isRead': false,
                  'createdAt': DateTime.now().toIso8601String(),
                }, SetOptions(merge: true));
          }
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_DECIDE_SUPPLEMENTAL_ERROR: $e');
      }
    }
  }

  Future<void> updateQcChecklist(
    String garageId,
    String jobId,
    Map<String, bool> checklist, {
    required String inspectorName,
  }) async {
    final isPassed = QCChecklistModel.isAllPassed(checklist);
    final jobIdx = jobs.indexWhere((j) => j.id == jobId);
    if (jobIdx >= 0) {
      final job = jobs[jobIdx];
      jobs[jobIdx] = job.copyWith(
        qcChecklist: checklist,
        isQcPassed: isPassed,
        qcInspectorName: inspectorName,
        qcInspectedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .update({
              'qcChecklist': checklist,
              'isQcPassed': isPassed,
              'qcInspectorName': inspectorName,
              'qcInspectedAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            });
      } catch (e) {
        debugPrint('GARAGE_REPO_UPDATE_QC_ERROR: $e');
      }
    }
  }

  @override
  Future<String> generateGatePass(String garageId, String jobId) async {
    final random = math.Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    final jobIdx = jobs.indexWhere((j) => j.id == jobId);
    if (jobIdx >= 0) {
      final job = jobs[jobIdx];
      jobs[jobIdx] = job.copyWith(
        gatePassCode: otp,
        isGatePassVerified: false,
        updatedAt: DateTime.now(),
      );

      final notifId = 'gatepass_${jobId}_generated';
      notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: job.customerId,
          title: 'Digital Gate Pass Ready: OTP $otp',
          body:
              'Your vehicle ${job.vehicleDisplay} is ready for collection. Show this 6-digit OTP ($otp) to garage security to release vehicle.',
          type: 'gate_pass',
          referenceId: jobId,
          referenceType: 'service_job',
          deepLink: '/customer/jobs/$jobId',
          garageId: garageId,
          eventId: notifId,
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final jobRef = FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId);
        await jobRef.update({
          'gatePassCode': otp,
          'isGatePassVerified': false,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('GARAGE_REPO_GENERATE_GATE_PASS_ERROR: $e');
      }
    }
    return otp;
  }

  Future<bool> verifyGatePass(
    String garageId,
    String jobId,
    String enteredOtp,
  ) async {
    final trimmed = enteredOtp.trim();
    final jobIdx = jobs.indexWhere((j) => j.id == jobId);
    if (jobIdx < 0) return false;
    final job = jobs[jobIdx];

    if (job.gatePassCode == null || job.gatePassCode!.trim() != trimmed) {
      return false;
    }

    final now = DateTime.now();
    jobs[jobIdx] = job.copyWith(
      isGatePassVerified: true,
      gatePassVerifiedAt: now,
      status: 'completed',
      completedDate: now,
      updatedAt: now,
    );

    final notifId = 'gatepass_${jobId}_verified';
    notifications.insert(
      0,
      NotificationModel(
        id: const Uuid().v4(),
        recipientUid: job.customerId,
        title: 'Vehicle Released & Delivered',
        body:
            'Digital Gate Pass verified for ${job.vehicleDisplay}. Your vehicle has been delivered.',
        type: 'delivery_completed',
        referenceId: jobId,
        referenceType: 'service_job',
        deepLink: '/customer/garages/$garageId?action=review&jobId=$jobId',
        garageId: garageId,
        eventId: notifId,
        isRead: false,
        createdAt: now,
      ),
    );

    if (FirebaseConfig.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(garageId)
            .collection('serviceJobs')
            .doc(jobId)
            .update({
              'isGatePassVerified': true,
              'gatePassVerifiedAt': now.toIso8601String(),
              'status': 'completed',
              'completedDate': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            });
      } catch (e) {
        debugPrint('GARAGE_REPO_VERIFY_GATE_PASS_ERROR: $e');
      }
    }
    return true;
  }

  Future<List<VehicleInspectionModel>> getInspections(String jobId) async {
    return inspections.where((i) => i.jobId == jobId).toList();
  }

  Future<void> saveInspection(VehicleInspectionModel inspection) async {
    inspections.removeWhere((i) => i.id == inspection.id);
    inspections.add(inspection);

    final job = jobs.where((j) => j.id == inspection.jobId).firstOrNull;
    if (job != null) {
      notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: job.customerId,
          title: 'Digital Inspection Completed',
          body:
              'Vehicle health check completed for ${job.vehicleDisplay}. Tap to view items.',
          type: 'inspectionCompleted',
          referenceId: inspection.id,
          referenceType: 'inspection',
          imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80',
          deepLink: '/customer/jobs/${job.id}',
          garageId: job.garageId,
          eventId: 'insp_${inspection.id}_saved',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}
