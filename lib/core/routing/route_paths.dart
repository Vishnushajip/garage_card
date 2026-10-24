class RoutePaths {
  RoutePaths._();

  static const String auth = '/auth';

  static const String customer = '/customer';
  static const String customerGarages = '/customer/garages';
  static const String customerVehicles = '/customer/vehicles';
  static const String customerInvoices = '/customer/invoices';
  static const String customerEstimates = '/customer/estimates';
  static const String customerReminders = '/customer/reminders';
  static const String customerNotifications = '/customer/notifications';
  static const String customerProfile = '/customer/profile';
  static const String customerJobDetail = '/customer/jobs/:id';

  static const String merchant = '/merchant';
  static const String merchantJobs = '/merchant/jobs';
  static const String merchantJobDetail = '/merchant/jobs/:id';
  static const String merchantCustomers = '/merchant/customers';
  static const String merchantEstimates = '/merchant/estimates';
  static const String merchantInvoices = '/merchant/invoices';
  static const String merchantSettings = '/merchant/settings';
}
