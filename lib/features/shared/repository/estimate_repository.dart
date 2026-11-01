import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';

import '../models/estimate_model.dart';
import '../models/notification_model.dart';
import 'garage_repository_store.dart';

mixin EstimateRepository on GarageRepositoryStore {
  Future<List<EstimateModel>> getEstimates({
    String? garageId,
    String? customerId,
    int page = 0,
    int limit = 20,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasCustomer) {
      return [];
    }

    if (FirebaseConfig.isInitialized) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('estimates');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('estimates')
              .where('customerId', isEqualTo: customerId);
        }

        final snapshot = await query
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 4));

        return snapshot.docs
            .map((d) => EstimateModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_ESTIMATES_ERROR: $e');
        return [];
      }
    }

    var query = estimates.where((e) {
      if (hasGarage && e.garageId != garageId) return false;
      if (hasCustomer && e.customerId != customerId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<EstimateModel> createEstimate(EstimateModel estimate) async {
    final id = estimate.id.isNotEmpty ? estimate.id : const Uuid().v4();
    final newEst = estimate.copyWith(
      id: id,
      createdAt: estimate.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized && newEst.garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newEst.garageId)
            .collection('estimates')
            .doc(newEst.id)
            .set(newEst.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_CREATE_ESTIMATE_ERROR: $e');
      }
    }

    estimates.removeWhere((e) => e.id == newEst.id);
    estimates.insert(0, newEst);
    return newEst;
  }

  Future<bool> approveEstimate(String estimateId) async {
    final index = estimates.indexWhere((e) => e.id == estimateId);
    EstimateModel? est;
    if (index >= 0) {
      est = estimates[index].copyWith(
        status: 'approved',
        approvedAt: DateTime.now(),
      );
      estimates[index] = est;

      final jobId = est.jobId;
      final jobIdx = jobs.indexWhere((j) => j.id == jobId);
      if (jobIdx >= 0) {
        jobs[jobIdx] = jobs[jobIdx].copyWith(status: 'estimateApproved');
      }

      notifications.insert(
        0,
        NotificationModel(
          id: const Uuid().v4(),
          recipientUid: est.garageId,
          title: 'Estimate Approved by Customer',
          body:
              'Customer approved estimate ${est.estimateNumber}. Ready to start work.',
          type: 'estimateApproved',
          referenceId: estimateId,
          referenceType: 'estimate',
          imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80',
          deepLink: '/merchant/estimates',
          garageId: est.garageId,
          eventId: 'est_${estimateId}_approved',
          isRead: false,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collectionGroup('estimates')
            .where('id', isEqualTo: estimateId)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          await doc.reference.update({
            'status': 'approved',
            'approvedAt': DateTime.now().toIso8601String(),
          });
          final garageId = doc.reference.parent.parent?.id ?? est?.garageId;
          final jobId = doc.data()['jobId'] as String?;
          if (garageId != null && jobId != null && jobId.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('garages')
                .doc(garageId)
                .collection('jobs')
                .doc(jobId)
                .update({'status': 'estimateApproved'});
          }
          return true;
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_APPROVE_ESTIMATE_ERROR: $e');
      }
    }

    return index >= 0;
  }

  Future<bool> rejectEstimate(String estimateId, String reason) async {
    final index = estimates.indexWhere((e) => e.id == estimateId);
    if (index >= 0) {
      estimates[index] = estimates[index].copyWith(
        status: 'rejected',
        rejectionReason: reason,
      );
    }

    if (FirebaseConfig.isInitialized) {
      try {
        final query = await FirebaseFirestore.instance
            .collectionGroup('estimates')
            .where('id', isEqualTo: estimateId)
            .limit(1)
            .get();
        if (query.docs.isNotEmpty) {
          final doc = query.docs.first;
          await doc.reference.update({
            'status': 'rejected',
            'rejectionReason': reason,
          });
          return true;
        }
      } catch (e) {
        debugPrint('GARAGE_REPO_REJECT_ESTIMATE_ERROR: $e');
      }
    }

    return index >= 0;
  }
}
