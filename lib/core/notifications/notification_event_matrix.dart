enum NotificationEventType {
  serviceRequestSubmitted,
  serviceRequestAccepted,
  serviceRequestRejected,
  appointmentConfirmed,
  appointmentCancelled,
  inspectionCompleted,
  workStarted,
  partsDelayed,
  readyForCollection,
  estimateCreated,
  estimateApproved,
  estimateRejected,
  invoiceIssued,
  paymentRecorded,
  paymentOverdue,
  serviceReminderDue,
  dailyMorningBriefing,
}

class NotificationEventDefinition {
  const NotificationEventDefinition({
    required this.type,
    required this.targetRole,
    required this.defaultTitle,
    required this.defaultBody,
    required this.defaultImageUrl,
    required this.defaultDeepLink,
  });

  final NotificationEventType type;
  final String targetRole;
  final String defaultTitle;
  final String defaultBody;
  final String? defaultImageUrl;
  final String defaultDeepLink;
}

class NotificationEventMatrix {
  NotificationEventMatrix._();

  static const String fallbackCarImage =
      'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80';
  static const String fallbackInspectionImage =
      'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=800&q=80';
  static const String fallbackEstimateImage =
      'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&q=80';
  static const String fallbackInvoiceImage =
      'https://images.unsplash.com/photo-1554224154-26032ffc0d07?w=800&q=80';
  static const String fallbackReminderImage =
      'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800&q=80';

  static final Map<NotificationEventType, NotificationEventDefinition> definitions = {
    NotificationEventType.serviceRequestSubmitted: const NotificationEventDefinition(
      type: NotificationEventType.serviceRequestSubmitted,
      targetRole: 'merchant',
      defaultTitle: 'New Service Request Received',
      defaultBody: 'A customer submitted a new service booking request for their vehicle.',
      defaultImageUrl: fallbackCarImage,
      defaultDeepLink: '/merchant/jobs',
    ),
    NotificationEventType.serviceRequestAccepted: const NotificationEventDefinition(
      type: NotificationEventType.serviceRequestAccepted,
      targetRole: 'customer',
      defaultTitle: 'Service Request Accepted',
      defaultBody: 'Your service request has been confirmed by the garage team.',
      defaultImageUrl: fallbackCarImage,
      defaultDeepLink: '/customer/jobs',
    ),
    NotificationEventType.serviceRequestRejected: const NotificationEventDefinition(
      type: NotificationEventType.serviceRequestRejected,
      targetRole: 'customer',
      defaultTitle: 'Service Request Update',
      defaultBody: 'Your service booking could not be scheduled at this time.',
      defaultImageUrl: null,
      defaultDeepLink: '/customer/garages',
    ),
    NotificationEventType.appointmentConfirmed: const NotificationEventDefinition(
      type: NotificationEventType.appointmentConfirmed,
      targetRole: 'customer',
      defaultTitle: 'Appointment Confirmed',
      defaultBody: 'Your garage appointment is scheduled and confirmed.',
      defaultImageUrl: fallbackCarImage,
      defaultDeepLink: '/customer/jobs',
    ),
    NotificationEventType.appointmentCancelled: const NotificationEventDefinition(
      type: NotificationEventType.appointmentCancelled,
      targetRole: 'both',
      defaultTitle: 'Appointment Cancelled',
      defaultBody: 'The scheduled appointment was cancelled.',
      defaultImageUrl: null,
      defaultDeepLink: '/customer/jobs',
    ),
    NotificationEventType.inspectionCompleted: const NotificationEventDefinition(
      type: NotificationEventType.inspectionCompleted,
      targetRole: 'customer',
      defaultTitle: 'Digital Inspection Completed',
      defaultBody: 'Our technician completed the digital health check for your vehicle.',
      defaultImageUrl: fallbackInspectionImage,
      defaultDeepLink: '/customer/jobs',
    ),
    NotificationEventType.workStarted: const NotificationEventDefinition(
      type: NotificationEventType.workStarted,
      targetRole: 'customer',
      defaultTitle: 'Service Work In Progress',
      defaultBody: 'Repair and maintenance work has commenced on your vehicle.',
      defaultImageUrl: fallbackInspectionImage,
      defaultDeepLink: '/customer/jobs',
    ),
    NotificationEventType.partsDelayed: const NotificationEventDefinition(
      type: NotificationEventType.partsDelayed,
      targetRole: 'customer',
      defaultTitle: 'Parts Order Update',
      defaultBody: 'Specialized parts are in transit. We will update you as soon as they arrive.',
      defaultImageUrl: null,
      defaultDeepLink: '/customer/jobs',
    ),
    NotificationEventType.readyForCollection: const NotificationEventDefinition(
      type: NotificationEventType.readyForCollection,
      targetRole: 'customer',
      defaultTitle: 'Vehicle Ready for Collection!',
      defaultBody: 'All service tasks are complete. Your vehicle is ready for pickup.',
      defaultImageUrl: fallbackCarImage,
      defaultDeepLink: '/customer/jobs',
    ),
    NotificationEventType.estimateCreated: const NotificationEventDefinition(
      type: NotificationEventType.estimateCreated,
      targetRole: 'customer',
      defaultTitle: 'New Repair Estimate Ready',
      defaultBody: 'An itemized repair estimate requires your review and approval.',
      defaultImageUrl: fallbackEstimateImage,
      defaultDeepLink: '/customer/estimates',
    ),
    NotificationEventType.estimateApproved: const NotificationEventDefinition(
      type: NotificationEventType.estimateApproved,
      targetRole: 'merchant',
      defaultTitle: 'Estimate Approved by Customer',
      defaultBody: 'The customer approved estimate. You can now begin work.',
      defaultImageUrl: fallbackEstimateImage,
      defaultDeepLink: '/merchant/estimates',
    ),
    NotificationEventType.estimateRejected: const NotificationEventDefinition(
      type: NotificationEventType.estimateRejected,
      targetRole: 'merchant',
      defaultTitle: 'Estimate Declined',
      defaultBody: 'The customer requested modifications or declined the estimate.',
      defaultImageUrl: null,
      defaultDeepLink: '/merchant/estimates',
    ),
    NotificationEventType.invoiceIssued: const NotificationEventDefinition(
      type: NotificationEventType.invoiceIssued,
      targetRole: 'customer',
      defaultTitle: 'Invoice Issued',
      defaultBody: 'Your service invoice has been generated and is ready for payment.',
      defaultImageUrl: fallbackInvoiceImage,
      defaultDeepLink: '/customer/invoices',
    ),
    NotificationEventType.paymentRecorded: const NotificationEventDefinition(
      type: NotificationEventType.paymentRecorded,
      targetRole: 'customer',
      defaultTitle: 'Payment Received',
      defaultBody: 'Thank you! Your payment was recorded successfully.',
      defaultImageUrl: fallbackInvoiceImage,
      defaultDeepLink: '/customer/invoices',
    ),
    NotificationEventType.paymentOverdue: const NotificationEventDefinition(
      type: NotificationEventType.paymentOverdue,
      targetRole: 'customer',
      defaultTitle: 'Payment Reminder',
      defaultBody: 'A pending service invoice has a balance awaiting settlement.',
      defaultImageUrl: fallbackInvoiceImage,
      defaultDeepLink: '/customer/invoices',
    ),
    NotificationEventType.serviceReminderDue: const NotificationEventDefinition(
      type: NotificationEventType.serviceReminderDue,
      targetRole: 'customer',
      defaultTitle: 'Upcoming Service Due',
      defaultBody: 'Your vehicle service interval is due soon. Book in advance.',
      defaultImageUrl: fallbackReminderImage,
      defaultDeepLink: '/customer/reminders',
    ),
    NotificationEventType.dailyMorningBriefing: const NotificationEventDefinition(
      type: NotificationEventType.dailyMorningBriefing,
      targetRole: 'merchant',
      defaultTitle: 'Daily Garage Briefing',
      defaultBody: 'Check today deliveries, in-progress jobs, and pending invoices.',
      defaultImageUrl: fallbackCarImage,
      defaultDeepLink: '/merchant/analytics',
    ),
  };

  static String generateIdempotencyKey({
    required NotificationEventType type,
    required String entityId,
    required String qualifier,
  }) {
    return '${type.name}_${entityId}_$qualifier';
  }

  static String resolveDeepLink({
    required NotificationEventType type,
    String? entityId,
  }) {
    switch (type) {
      case NotificationEventType.serviceRequestSubmitted:
      case NotificationEventType.serviceRequestAccepted:
      case NotificationEventType.serviceRequestRejected:
      case NotificationEventType.appointmentConfirmed:
      case NotificationEventType.appointmentCancelled:
      case NotificationEventType.inspectionCompleted:
      case NotificationEventType.workStarted:
      case NotificationEventType.partsDelayed:
      case NotificationEventType.readyForCollection:
        if (entityId != null && entityId.isNotEmpty) {
          return '/customer/jobs/$entityId';
        }
        return '/customer/jobs';
      case NotificationEventType.estimateCreated:
        return '/customer/estimates';
      case NotificationEventType.estimateApproved:
      case NotificationEventType.estimateRejected:
        return '/merchant/estimates';
      case NotificationEventType.invoiceIssued:
      case NotificationEventType.paymentRecorded:
      case NotificationEventType.paymentOverdue:
        return '/customer/invoices';
      case NotificationEventType.serviceReminderDue:
        return '/customer/reminders';
      case NotificationEventType.dailyMorningBriefing:
        return '/merchant/analytics';
    }
  }
}
