import 'package:url_launcher/url_launcher.dart';

class WhatsAppShareService {
  WhatsAppShareService._();

  static Future<bool> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  static Future<bool> makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      return true;
    }
    return false;
  }

  static Future<bool> openMapDirections({
    required double latitude,
    required double longitude,
    required String label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label);
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$encodedLabel',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  static String composeJobStatusMessage({
    required String customerName,
    required String garageName,
    required String vehicleDisplay,
    required String jobNumber,
    required String status,
    required String notes,
  }) {
    return 'Hello $customerName,\n\n'
        'Here is an update on your vehicle repair at $garageName:\n'
        '• Vehicle: $vehicleDisplay\n'
        '• Job No: $jobNumber\n'
        '• Status: $status\n'
        '${notes.isNotEmpty ? '• Details: $notes\n' : ''}\n'
        'Track repair progress in your Garage Card app.\n'
        'Thank you,\n$garageName';
  }

  static String composeEstimateMessage({
    required String customerName,
    required String garageName,
    required String vehicleDisplay,
    required String estimateNumber,
    required String totalAmount,
  }) {
    return 'Hello $customerName,\n\n'
        'Your repair estimate from $garageName is ready for review:\n'
        '• Estimate No: $estimateNumber\n'
        '• Vehicle: $vehicleDisplay\n'
        '• Estimated Total: $totalAmount\n\n'
        'Please open your Garage Card app to review and approve the estimate.\n'
        'Thank you,\n$garageName';
  }

  static String composeInvoiceMessage({
    required String customerName,
    required String garageName,
    required String vehicleDisplay,
    required String invoiceNumber,
    required String balanceDue,
  }) {
    return 'Hello $customerName,\n\n'
        'Your invoice from $garageName has been generated:\n'
        '• Invoice No: $invoiceNumber\n'
        '• Vehicle: $vehicleDisplay\n'
        '• Balance Due: $balanceDue\n\n'
        'You can view and download your PDF invoice directly in the Garage Card app.\n'
        'Thank you,\n$garageName';
  }

  static String composeServiceReminderMessage({
    required String customerName,
    required String garageName,
    required String vehicleDisplay,
    required String reminderTitle,
    required String dueDate,
  }) {
    return 'Hello $customerName,\n\n'
        'This is a friendly service reminder from $garageName for your vehicle $vehicleDisplay:\n'
        '• Service: $reminderTitle\n'
        '• Due Date: $dueDate\n\n'
        'Book your service appointment conveniently via the Garage Card app.\n'
        'Thank you,\n$garageName';
  }
}
