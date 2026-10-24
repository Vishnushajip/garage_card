class FirestorePaths {
  FirestorePaths._();

  static String users() => 'users';
  static String user(String uid) => 'users/$uid';
  static String userDeviceTokens(String uid) => 'users/$uid/deviceTokens';
  static String userNotifications(String uid) => 'users/$uid/notifications';
  static String userNotification(String uid, String notificationId) =>
      'users/$uid/notifications/$notificationId';

  static String garages() => 'garages';
  static String garage(String garageId) => 'garages/$garageId';
  static String garageMembers(String garageId) => 'garages/$garageId/members';
  static String garageMember(String garageId, String uid) =>
      'garages/$garageId/members/$uid';

  static String garageCustomers(String garageId) =>
      'garages/$garageId/customers';
  static String garageCustomer(String garageId, String customerId) =>
      'garages/$garageId/customers/$customerId';

  static String garageVehicles(String garageId) => 'garages/$garageId/vehicles';
  static String garageVehicle(String garageId, String vehicleId) =>
      'garages/$garageId/vehicles/$vehicleId';

  static String garageServiceJobs(String garageId) =>
      'garages/$garageId/serviceJobs';
  static String garageServiceJob(String garageId, String jobId) =>
      'garages/$garageId/serviceJobs/$jobId';
  static String garageJobHistory(String garageId, String jobId) =>
      'garages/$garageId/serviceJobs/$jobId/history';

  static String garageInspections(String garageId) =>
      'garages/$garageId/inspections';
  static String garageInspection(String garageId, String inspectionId) =>
      'garages/$garageId/inspections/$inspectionId';

  static String garageServiceCatalog(String garageId) =>
      'garages/$garageId/serviceCatalog';
  static String garageServiceCatalogItem(String garageId, String serviceId) =>
      'garages/$garageId/serviceCatalog/$serviceId';

  static String garageEstimates(String garageId) =>
      'garages/$garageId/estimates';
  static String garageEstimate(String garageId, String estimateId) =>
      'garages/$garageId/estimates/$estimateId';

  static String garageInvoices(String garageId) => 'garages/$garageId/invoices';
  static String garageInvoice(String garageId, String invoiceId) =>
      'garages/$garageId/invoices/$invoiceId';

  static String garagePayments(String garageId) => 'garages/$garageId/payments';
  static String garagePayment(String garageId, String paymentId) =>
      'garages/$garageId/payments/$paymentId';

  static String garageAppointments(String garageId) =>
      'garages/$garageId/appointments';
  static String garageAppointment(String garageId, String appointmentId) =>
      'garages/$garageId/appointments/$appointmentId';

  static String garageServiceRequests(String garageId) =>
      'garages/$garageId/serviceRequests';
  static String garageServiceRequest(String garageId, String requestId) =>
      'garages/$garageId/serviceRequests/$requestId';

  static String garageReminders(String garageId) =>
      'garages/$garageId/reminders';
  static String garageReminder(String garageId, String reminderId) =>
      'garages/$garageId/reminders/$reminderId';

  static String garageSubscriptions(String garageId) =>
      'garages/$garageId/subscriptions';
  static String garageSettings(String garageId) => 'garages/$garageId/settings';
}
