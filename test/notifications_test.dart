import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/notifications/fcm_token_model.dart';
import 'package:garage_card/core/notifications/notification_event_matrix.dart';
import 'package:garage_card/features/merchant/notifications/Model/merchant_notifications_state.dart';
import 'package:garage_card/features/shared/models/notification_model.dart';
import 'package:garage_card/features/shared/models/vehicle_inspection_model.dart';
import 'package:garage_card/features/shared/repository/garage_repository.dart';

void main() {
  group('Notification Models & Serialization Tests', () {
    test('NotificationModel serializes and deserializes image and deepLink fields', () {
      final now = DateTime.now();
      const imageUrl = 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80';
      const deepLink = '/customer/jobs/job_123';

      final notification = NotificationModel(
        id: 'notif_test_1',
        recipientUid: 'user_cust_1',
        title: 'Vehicle Ready for Collection!',
        body: 'Your Hyundai Creta service is complete.',
        type: 'readyForCollection',
        referenceId: 'job_123',
        referenceType: 'service_job',
        imageUrl: imageUrl,
        deepLink: deepLink,
        garageId: 'garage_test_1',
        eventId: 'job_123_readyForCollection',
        isRead: false,
        createdAt: now,
      );

      expect(notification.imageUrl, imageUrl);
      expect(notification.deepLink, deepLink);
      expect(notification.eventId, 'job_123_readyForCollection');

      final map = notification.toFirestore();
      expect(map['imageUrl'], imageUrl);
      expect(map['deepLink'], deepLink);
      expect(map['eventId'], 'job_123_readyForCollection');
      expect(map['garageId'], 'garage_test_1');

      final reconstructed = NotificationModel.fromFirestore(map, 'notif_test_1');
      expect(reconstructed.id, 'notif_test_1');
      expect(reconstructed.imageUrl, imageUrl);
      expect(reconstructed.deepLink, deepLink);
      expect(reconstructed.eventId, 'job_123_readyForCollection');
      expect(reconstructed.isRead, isFalse);
    });

    test('FcmTokenModel serializes and deserializes platform metadata', () {
      final now = DateTime.now();
      final token = FcmTokenModel(
        token: 'fcm_token_sample_abc',
        userId: 'user_456',
        platform: 'android',
        deviceId: 'device_pixel_8',
        updatedAt: now,
        isActive: true,
      );

      final map = token.toFirestore();
      expect(map['token'], 'fcm_token_sample_abc');
      expect(map['platform'], 'android');
      expect(map['deviceId'], 'device_pixel_8');
      expect(map['isActive'], isTrue);

      final reconstructed = FcmTokenModel.fromFirestore(map, 'fcm_token_sample_abc');
      expect(reconstructed.token, 'fcm_token_sample_abc');
      expect(reconstructed.userId, 'user_456');
      expect(reconstructed.platform, 'android');
      expect(reconstructed.isActive, isTrue);

      final webToken = token.copyWith(platform: 'web', isActive: false);
      expect(webToken.platform, 'web');
      expect(webToken.isActive, isFalse);
    });
  });

  group('Notification Event Matrix & Routing Tests', () {
    test('NotificationEventMatrix definitions contain valid targets and images', () {
      final readyDef = NotificationEventMatrix.definitions[NotificationEventType.readyForCollection];
      expect(readyDef, isNotNull);
      expect(readyDef!.targetRole, 'customer');
      expect(readyDef.defaultImageUrl, isNotEmpty);

      final estimateApprovedDef = NotificationEventMatrix.definitions[NotificationEventType.estimateApproved];
      expect(estimateApprovedDef, isNotNull);
      expect(estimateApprovedDef!.targetRole, 'merchant');
      expect(estimateApprovedDef.defaultDeepLink, '/merchant/estimates');
    });

    test('NotificationEventMatrix resolves deep links accurately', () {
      final jobLink = NotificationEventMatrix.resolveDeepLink(
        type: NotificationEventType.readyForCollection,
        entityId: 'job_abc',
      );
      expect(jobLink, '/customer/jobs/job_abc');

      final estimateLink = NotificationEventMatrix.resolveDeepLink(
        type: NotificationEventType.estimateCreated,
      );
      expect(estimateLink, '/customer/estimates');

      final invoiceLink = NotificationEventMatrix.resolveDeepLink(
        type: NotificationEventType.invoiceIssued,
      );
      expect(invoiceLink, '/customer/invoices');

      final reminderLink = NotificationEventMatrix.resolveDeepLink(
        type: NotificationEventType.serviceReminderDue,
      );
      expect(reminderLink, '/customer/reminders');

      final briefingLink = NotificationEventMatrix.resolveDeepLink(
        type: NotificationEventType.dailyMorningBriefing,
      );
      expect(briefingLink, '/merchant/analytics');
    });

    test('NotificationEventMatrix generates stable idempotency keys', () {
      final key1 = NotificationEventMatrix.generateIdempotencyKey(
        type: NotificationEventType.readyForCollection,
        entityId: 'job_999',
        qualifier: 'ready',
      );
      final key2 = NotificationEventMatrix.generateIdempotencyKey(
        type: NotificationEventType.readyForCollection,
        entityId: 'job_999',
        qualifier: 'ready',
      );

      expect(key1, 'readyForCollection_job_999_ready');
      expect(key1, key2);
    });
  });

  group('Merchant Notifications State Tests', () {
    test('MerchantNotificationsState filters unread items correctly', () {
      final notif1 = NotificationModel(
        id: '1',
        recipientUid: 'm_1',
        title: 'New Booking',
        body: 'Booking 1',
        isRead: false,
      );
      final notif2 = NotificationModel(
        id: '2',
        recipientUid: 'm_1',
        title: 'Estimate Approved',
        body: 'Approved',
        isRead: true,
      );

      final state = MerchantNotificationsState(
        notifications: [notif1, notif2],
        filterOnlyUnread: false,
      );

      expect(state.unreadCount, 1);
      expect(state.filteredNotifications.length, 2);

      final filteredState = state.copyWith(filterOnlyUnread: true);
      expect(filteredState.filteredNotifications.length, 1);
      expect(filteredState.filteredNotifications.first.id, '1');
    });
  });

  group('Garage Repository Notification Lifecycle Integration Tests', () {
    test('Job status change creates customer notification with rich image and deep link', () async {
      final repo = GarageRepository();
      final initialJobs = await repo.getServiceJobs(garageId: 'garage_demo_1');
      expect(initialJobs, isNotEmpty);
      final job = initialJobs.first;

      await repo.updateJobStatus(
        jobId: job.id,
        newStatus: 'readyForCollection',
        notes: 'Vehicle washed and ready for collection.',
        updatedBy: 'Lead Mechanic',
      );

      final notifs = await repo.getNotifications(recipientUid: job.customerId);
      expect(notifs, isNotEmpty);
      final latest = notifs.first;
      expect(latest.type, 'job_status');
      expect(latest.referenceId, job.id);
      expect(latest.imageUrl, contains('unsplash.com'));
      expect(latest.deepLink, '/customer/jobs/${job.id}');
      expect(latest.eventId, 'job_${job.id}_readyForCollection');
      expect(latest.isRead, isFalse);
    });

    test('Estimate approval creates merchant notification with estimate image', () async {
      final repo = GarageRepository();
      final estimates = await repo.getEstimates(garageId: 'garage_demo_1');
      expect(estimates, isNotEmpty);
      final est = estimates.first;

      final success = await repo.approveEstimate(est.id);
      expect(success, isTrue);

      final merchantNotifs = await repo.getNotifications(recipientUid: 'user_merchant_1');
      expect(merchantNotifs, isNotEmpty);
      final approvalNotif = merchantNotifs.firstWhere((n) => n.eventId == 'est_${est.id}_approved');
      expect(approvalNotif.type, 'estimateApproved');
      expect(approvalNotif.referenceId, est.id);
      expect(approvalNotif.imageUrl, isNotNull);
      expect(approvalNotif.deepLink, '/merchant/estimates');
    });

    test('Invoice issuance from estimate creates customer notification with invoice image', () async {
      final repo = GarageRepository();
      final estimates = await repo.getEstimates(garageId: 'garage_demo_1');
      final est = estimates.first;

      final invoice = await repo.createInvoiceFromEstimate(est);
      expect(invoice.id, isNotEmpty);

      final customerNotifs = await repo.getNotifications(recipientUid: est.customerId);
      final invoiceNotif = customerNotifs.firstWhere((n) => n.eventId == 'inv_${invoice.id}_issued');
      expect(invoiceNotif.type, 'invoiceIssued');
      expect(invoiceNotif.imageUrl, contains('unsplash.com'));
      expect(invoiceNotif.deepLink, '/customer/invoices');
    });

    test('Payment recording creates customer notification with balance update', () async {
      final repo = GarageRepository();
      final invoices = await repo.getInvoices(garageId: 'garage_demo_1');
      final inv = invoices.first;

      final payment = await repo.recordPayment(
        invoiceId: inv.id,
        amount: 2000.0,
        paymentMethod: 'UPI',
        referenceNumber: 'UPI-TEST-9988',
        notes: 'Partial advance payment',
        recordedByUid: 'staff_1',
      );
      expect(payment.id, isNotEmpty);

      final customerNotifs = await repo.getNotifications(recipientUid: inv.customerId);
      final paymentNotif = customerNotifs.firstWhere((n) => n.eventId == 'pay_${payment.id}_recorded');
      expect(paymentNotif.type, 'paymentRecorded');
      expect(paymentNotif.body, contains('₹2000'));
      expect(paymentNotif.deepLink, '/customer/invoices');
      expect(paymentNotif.imageUrl, isNotNull);
    });

    test('Customer appointment booking creates merchant notification', () async {
      final repo = GarageRepository();
      final initialAppointments = await repo.getAppointments(garageId: 'garage_demo_1');
      final app = initialAppointments.first;

      await repo.createAppointment(app);

      final merchantNotifs = await repo.getNotifications(recipientUid: 'user_merchant_1');
      expect(merchantNotifs, isNotEmpty);
      final bookingNotif = merchantNotifs.firstWhere((n) => n.type == 'serviceRequestSubmitted');
      expect(bookingNotif.imageUrl, isNotNull);
      expect(bookingNotif.deepLink, '/merchant/jobs');
    });

    test('Saving digital inspection creates customer notification with inspection photo', () async {
      final repo = GarageRepository();
      final jobs = await repo.getServiceJobs(garageId: 'garage_demo_1');
      final job = jobs.first;

      final inspection = VehicleInspectionModel(
        id: 'insp_test_99',
        garageId: job.garageId,
        jobId: job.id,
        vehicleId: job.vehicleId,
        inspectorName: 'Chief Diagnostics Technician',
        summaryNotes: 'Multipoint health inspection complete. Brake pads at 40%.',
        createdAt: DateTime.now(),
      );

      await repo.saveInspection(inspection);

      final customerNotifs = await repo.getNotifications(recipientUid: job.customerId);
      final inspNotif = customerNotifs.firstWhere((n) => n.eventId == 'insp_${inspection.id}_saved');
      expect(inspNotif.type, 'inspectionCompleted');
      expect(inspNotif.imageUrl, isNotNull);
      expect(inspNotif.deepLink, '/customer/jobs/${job.id}');
    });

    test('Marking notification as read updates read state', () async {
      final repo = GarageRepository();
      final notifs = await repo.getNotifications(recipientUid: 'customer_demo_uid');
      expect(notifs, isNotEmpty);
      final unread = notifs.firstWhere((n) => !n.isRead);

      await repo.markNotificationAsRead(unread.id);

      final updated = await repo.getNotifications(recipientUid: 'customer_demo_uid');
      final target = updated.firstWhere((n) => n.id == unread.id);
      expect(target.isRead, isTrue);
    });
  });
}
