import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:garage_card/core/firebase/firebase_config.dart';

import '../models/estimate_model.dart';
import '../models/invoice_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/payment_record_model.dart';
import '../models/warranty_item_model.dart';
import 'garage_repository_store.dart';

mixin InvoiceRepository on GarageRepositoryStore {
  Future<List<InvoiceModel>> getInvoices({
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

    if (FirebaseConfig.isInitialized &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        Query<Map<String, dynamic>> query;
        if (hasGarage) {
          query = FirebaseFirestore.instance
              .collection('garages')
              .doc(garageId)
              .collection('invoices');
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('invoices')
              .where('customerId', isEqualTo: customerId);
        }

        final snapshot = await query
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 4));

        final items = snapshot.docs
            .map((d) => InvoiceModel.fromFirestore(d.data(), d.id))
            .toList();
        items.sort(
          (a, b) => (b.createdAt ?? b.issuedAt ?? DateTime.now()).compareTo(
            a.createdAt ?? a.issuedAt ?? DateTime.now(),
          ),
        );
        return items;
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_INVOICES_ERROR: $e');
        return [];
      }
    }

    var query = invoices.where((inv) {
      if (hasGarage && inv.garageId != garageId) return false;
      if (hasCustomer && inv.customerId != customerId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }

  Future<InvoiceModel> createInvoiceFromEstimate(EstimateModel estimate) async {
    final inv = InvoiceModel(
      id: const Uuid().v4(),
      garageId: estimate.garageId,
      jobId: estimate.jobId,
      estimateId: estimate.id,
      customerId: estimate.customerId,
      invoiceNumber: 'INV-${DateTime.now().millisecondsSinceEpoch % 100000}',
      items: estimate.items,
      subtotal: estimate.subtotal,
      taxRate: estimate.taxRate,
      taxAmount: estimate.taxAmount,
      discountAmount: estimate.discountAmount,
      totalAmount: estimate.totalAmount,
      paidAmount: 0.0,
      balanceDue: estimate.totalAmount,
      currencyCode: estimate.currencyCode,
      status: 'unpaid',
      issuedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    if (FirebaseConfig.isInitialized && inv.garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(inv.garageId)
            .collection('invoices')
            .doc(inv.id)
            .set(inv.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_CREATE_INVOICE_ERROR: $e');
      }
    }

    invoices.insert(0, inv);

    notifications.insert(
      0,
      NotificationModel(
        id: const Uuid().v4(),
        recipientUid: estimate.customerId,
        title: 'New Service Invoice Issued',
        body:
            'Invoice ${inv.invoiceNumber} has been generated and is ready for payment.',
        type: 'invoiceIssued',
        referenceId: inv.id,
        referenceType: 'invoice',
        imageUrl: 'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80',
        deepLink: '/customer/invoices',
        garageId: estimate.garageId,
        eventId: 'inv_${inv.id}_issued',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    return inv;
  }

  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    final id = invoice.id.isNotEmpty ? invoice.id : const Uuid().v4();
    final newInv = invoice.copyWith(
      id: id,
      createdAt: invoice.createdAt ?? DateTime.now(),
    );

    if (FirebaseConfig.isInitialized && newInv.garageId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(newInv.garageId)
            .collection('invoices')
            .doc(newInv.id)
            .set(newInv.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_CREATE_INVOICE_ERROR: $e');
      }
    }

    invoices.removeWhere((i) => i.id == newInv.id);
    invoices.insert(0, newInv);
    return newInv;
  }

  Future<PaymentModel> recordPayment({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    required String referenceNumber,
    required String notes,
    required String recordedByUid,
    double discountAdjustment = 0.0,
  }) async {
    final invIndex = invoices.indexWhere((inv) => inv.id == invoiceId);
    if (invIndex < 0) {
      throw Exception('Invoice not found');
    }

    final currentInv = invoices[invIndex];
    final updatedDiscount = currentInv.discountAmount + discountAdjustment;
    final updatedTotal = (currentInv.totalAmount - discountAdjustment).clamp(
      0.0,
      double.infinity,
    );
    final updatedPaid = currentInv.paidAmount + amount;
    final updatedBalance = (updatedTotal - updatedPaid).clamp(
      0.0,
      double.infinity,
    );
    final updatedStatus = updatedBalance <= 0.0 ? 'paid' : 'partially_paid';

    invoices[invIndex] = currentInv.copyWith(
      discountAmount: updatedDiscount,
      totalAmount: updatedTotal,
      paidAmount: updatedPaid,
      balanceDue: updatedBalance,
      status: updatedStatus,
    );

    final payment = PaymentModel(
      id: const Uuid().v4(),
      garageId: currentInv.garageId,
      invoiceId: invoiceId,
      customerId: currentInv.customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      recordedByUid: recordedByUid,
      notes: notes,
      createdAt: DateTime.now(),
    );
    payments.insert(0, payment);

    final newPaymentRecord = PaymentRecordModel(
      id: payment.id,
      invoiceId: invoiceId,
      amount: amount,
      method: paymentMethod,
      reference: referenceNumber,
      recordedAt: DateTime.now(),
      notes: notes,
    );
    final updatedPaymentRecords = [
      ...currentInv.paymentRecords,
      newPaymentRecord,
    ];

    invoices[invIndex] = currentInv.copyWith(
      discountAmount: updatedDiscount,
      totalAmount: updatedTotal,
      paidAmount: updatedPaid,
      balanceDue: updatedBalance,
      status: updatedStatus,
      paymentRecords: updatedPaymentRecords,
    );

    if (updatedBalance <= 0.0 && currentInv.jobId.isNotEmpty) {
      final jIdx = jobs.indexWhere((j) => j.id == currentInv.jobId);
      if (jIdx >= 0 &&
          (jobs[jIdx].gatePassCode == null ||
              jobs[jIdx].gatePassCode!.isEmpty)) {
        await generateGatePass(currentInv.garageId, currentInv.jobId);
      }
    }

    notifications.insert(
      0,
      NotificationModel(
        id: const Uuid().v4(),
        recipientUid: currentInv.customerId,
        title: 'Payment Received',
        body:
            'Payment of ₹${amount.toStringAsFixed(0)} recorded for invoice ${currentInv.invoiceNumber}. Balance: ₹${updatedBalance.toStringAsFixed(0)}',
        type: 'paymentRecorded',
        referenceId: payment.id,
        referenceType: 'payment',
        imageUrl: 'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80',
        deepLink: '/customer/invoices',
        garageId: currentInv.garageId,
        eventId: 'pay_${payment.id}_recorded',
        isRead: false,
        createdAt: DateTime.now(),
      ),
    );

    if (FirebaseConfig.isInitialized &&
        FirebaseAuth.instance.currentUser != null) {
      try {
        await FirebaseFirestore.instance
            .collection('garages')
            .doc(currentInv.garageId)
            .collection('invoices')
            .doc(invoiceId)
            .update({
              'discountAmount': updatedDiscount,
              'totalAmount': updatedTotal,
              'paidAmount': updatedPaid,
              'balanceDue': updatedBalance,
              'status': updatedStatus,
              'paymentRecords': updatedPaymentRecords
                  .map((p) => p.toMap())
                  .toList(),
              'updatedAt': DateTime.now().toIso8601String(),
            });

        await FirebaseFirestore.instance
            .collection('garages')
            .doc(currentInv.garageId)
            .collection('payments')
            .doc(payment.id)
            .set(payment.toFirestore(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('GARAGE_REPO_RECORD_PAYMENT_ERROR: $e');
      }
    }

    return payment;
  }

  Future<List<WarrantyItemModel>> getCustomerWarranties(
    String customerId,
  ) async {
    final invList = await getInvoices(customerId: customerId, limit: 100);
    final List<WarrantyItemModel> list = [];
    for (final inv in invList) {
      list.addAll(inv.warrantyItems);
    }
    return list;
  }

  Future<List<InvoiceModel>> getInvoicesForTaxExport(
    String garageId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final invList = await getInvoices(garageId: garageId, limit: 200);
    return invList.where((inv) {
      final date = inv.issuedAt ?? inv.createdAt ?? DateTime.now();
      if (startDate != null && date.isBefore(startDate)) return false;
      if (endDate != null && date.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  Future<List<PaymentModel>> getPayments({
    String? garageId,
    String? invoiceId,
    String? customerId,
    int page = 0,
    int limit = 20,
  }) async {
    final hasGarage = garageId != null && garageId.isNotEmpty;
    final hasInvoice = invoiceId != null && invoiceId.isNotEmpty;
    final hasCustomer = customerId != null && customerId.isNotEmpty;
    if (!hasGarage && !hasInvoice && !hasCustomer) {
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
              .collection('payments');
          if (hasInvoice) {
            query = query.where('invoiceId', isEqualTo: invoiceId);
          }
          if (hasCustomer) {
            query = query.where('customerId', isEqualTo: customerId);
          }
        } else if (hasCustomer) {
          query = FirebaseFirestore.instance
              .collectionGroup('payments')
              .where('customerId', isEqualTo: customerId);
          if (hasInvoice) {
            query = query.where('invoiceId', isEqualTo: invoiceId);
          }
        } else {
          query = FirebaseFirestore.instance
              .collectionGroup('payments')
              .where('invoiceId', isEqualTo: invoiceId);
        }

        final snapshot = await query
            .limit(limit)
            .get()
            .timeout(const Duration(seconds: 4));

        return snapshot.docs
            .map((d) => PaymentModel.fromFirestore(d.data(), d.id))
            .toList();
      } catch (e) {
        debugPrint('GARAGE_REPO_GET_PAYMENTS_ERROR: $e');
        return [];
      }
    }

    var query = payments.where((p) {
      if (hasGarage && p.garageId != garageId) return false;
      if (hasInvoice && p.invoiceId != invoiceId) return false;
      if (hasCustomer && p.customerId != customerId) return false;
      return true;
    }).toList();

    final start = page * limit;
    if (start >= query.length) return [];
    final end = (start + limit) > query.length ? query.length : (start + limit);
    return query.sublist(start, end);
  }
}
