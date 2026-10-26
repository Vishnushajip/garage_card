class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String noInternet = '/no-internet';

  static const String customer = '/customer';
  static const String customerJobs = '/customer/jobs';
  static const String customerGarages = '/customer/garages';
  static const String customerVehicles = '/customer/vehicles';
  static const String customerInvoices = '/customer/invoices';
  static const String customerEstimates = '/customer/estimates';
  static const String customerReminders = '/customer/reminders';
  static const String customerNotifications = '/customer/notifications';
  static const String customerProfile = '/customer/profile';
  static const String customerJobDetail = '/customer/jobs/:id';
  static const String customerGarageDetail = '/customer/garages/:id';
  static const String chatList = '/messages';
  static const String chatDetail = '/chat/:id';

  static const String merchant = '/merchant';
  static const String merchantJobs = '/merchant/jobs';
  static const String merchantJobDetail = '/merchant/jobs/:id';
  static const String merchantCustomers = '/merchant/customers';
  static const String merchantEstimates = '/merchant/estimates';
  static const String merchantInvoices = '/merchant/invoices';
  static const String merchantAnalytics = '/merchant/analytics';
  static const String merchantServices = '/merchant/services';
  static const String merchantNotifications = '/merchant/notifications';
  static const String merchantSettings = '/merchant/settings';
}
