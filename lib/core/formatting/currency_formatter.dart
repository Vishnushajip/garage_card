import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String currencyCode = 'INR'}) {
    final symbol = switch (currencyCode.toUpperCase()) {
      'INR' => '₹',
      'AED' => 'AED ',
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      'SAR' => 'SAR ',
      'QAR' => 'QAR ',
      'OMR' => 'OMR ',
      _ => '$currencyCode ',
    };

    final formatter = NumberFormat('#,##0.00');
    return '$symbol${formatter.format(amount)}';
  }

  static String formatWithoutDecimals(
    double amount, {
    String currencyCode = 'INR',
  }) {
    final symbol = switch (currencyCode.toUpperCase()) {
      'INR' => '₹',
      'AED' => 'AED ',
      'USD' => '\$',
      'EUR' => '€',
      'GBP' => '£',
      'SAR' => 'SAR ',
      'QAR' => 'QAR ',
      'OMR' => 'OMR ',
      _ => '$currencyCode ',
    };

    final formatter = NumberFormat('#,##0');
    return '$symbol${formatter.format(amount)}';
  }
}
