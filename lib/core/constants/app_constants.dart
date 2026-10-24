class AppConstants {
  AppConstants._();

  static const int defaultPageSize = 20;
  static const double paginationPrefetchThreshold = 0.75;

  static const List<String> supportedCurrencies = [
    'INR',
    'AED',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'QAR',
    'OMR',
  ];

  static const double defaultNearbyRadiusKm = 25.0;

  static const int defaultServiceIntervalMonths = 6;
  static const int defaultServiceIntervalKm = 10000;

  static const String roleCustomer = 'customer';
  static const String roleMerchant = 'merchant';
  static const String roleAdmin = 'admin';
  static const String roleStaff = 'staff';
}
