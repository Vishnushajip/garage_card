import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppShareService {
  WhatsAppShareService._();

  static Future<bool> sendWhatsAppMessage({
    required String phoneNumber,
    required String message,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final encodedMessage = Uri.encodeComponent(message);

    final waUrl = Uri.parse('https://wa.me/$cleanPhone?text=$encodedMessage');

    if (kIsWeb) {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    }

    final nativeUrl = Uri.parse(
      'whatsapp://send?phone=$cleanPhone&text=$encodedMessage',
    );
    try {
      if (await canLaunchUrl(nativeUrl)) {
        await launchUrl(nativeUrl, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}

    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
        return true;
      }
      return await launchUrl(waUrl);
    } catch (_) {
      return false;
    }
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
        'Track repair progress in your WeFix app.\n'
        'Thank you,\n$garageName';
  }

  static String composeJobStatusMessageWithDetails({
    required String customerName,
    required String garageName,
    required String vehicleDisplay,
    required String jobNumber,
    required String status,
    required String statusMalayalam,
    required String notes,
    String? partsNeeded,
    String language = 'bilingual',
  }) {
    final partsEng = partsNeeded != null && partsNeeded.isNotEmpty
        ? '• Parts Needed: $partsNeeded\n'
        : '';
    final partsMl = partsNeeded != null && partsNeeded.isNotEmpty
        ? '• ആവശ്യമായ പാർട്സുകൾ: $partsNeeded\n'
        : '';
    final notesEng = notes.isNotEmpty ? '• Notes: $notes\n' : '';
    final notesMl = notes.isNotEmpty ? '• വിവരണം: $notes\n' : '';

    if (language == 'malayalam') {
      return 'നമസ്കാരം $customerName,\n\n'
          '$garageName-ൽ നൽകിയിട്ടുള്ള താങ്കളുടെ വാഹനത്തിന്റെ റിപ്പയർ വിവരങ്ങൾ:\n'
          '• വാഹനം: $vehicleDisplay\n'
          '• ജോബ് നമ്പർ: $jobNumber\n'
          '• നിലവിലെ അവസ്ഥ: $statusMalayalam\n'
          '$partsMl'
          '$notesMl\n'
          'കൂടുതൽ വിവരങ്ങൾക്ക് WeFix ആപ്പ് സന്ദർശിക്കുക.\n'
          'നന്ദി,\n$garageName';
    }

    if (language == 'english') {
      return 'Hello $customerName,\n\n'
          'Here is an update on your vehicle service at $garageName:\n'
          '• Vehicle: $vehicleDisplay\n'
          '• Job No: $jobNumber\n'
          '• Status: $status\n'
          '$partsEng'
          '$notesEng\n'
          'Track live repair status in the WeFix app.\n'
          'Thank you,\n$garageName';
    }

    return 'Hello $customerName / നമസ്കാരം,\n\n'
        'Vehicle Service Update from $garageName:\n'
        '• Vehicle / വാഹനം: $vehicleDisplay\n'
        '• Job No / ജോബ് നമ്പർ: $jobNumber\n'
        '• Status / അവസ്ഥ: $status ($statusMalayalam)\n'
        '${partsNeeded != null && partsNeeded.isNotEmpty ? '• Parts Needed / പാർട്സുകൾ: $partsNeeded\n' : ''}'
        '${notes.isNotEmpty ? '• Details / വിവരണം: $notes\n' : ''}\n'
        'Track live progress in your WeFix app / കൂടുതൽ വിവരങ്ങൾക്ക് WeFix ആപ്പ് കാണുക.\n\n'
        'Thank you / നന്ദി,\n$garageName';
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
        'Please open your WeFix app to review and approve the estimate.\n'
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
        'You can view and download your PDF invoice directly in the WeFix app.\n'
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
        'Book your service appointment conveniently via the WeFix app.\n'
        'Thank you,\n$garageName';
  }

  static String composeReviewRequestMessage({
    required String customerName,
    required String garageName,
    required String garageId,
    String language = 'english',
  }) {
    final link = 'https://wefixgarage.web.app/customer/garages/$garageId';
    if (language == 'malayalam') {
      return 'നമസ്കാരം $customerName,\n\n'
          '$garageName തിരഞ്ഞെടുത്തതിന് ഞങ്ങളുടെ ഹൃദയം നിറഞ്ഞ നന്ദി. നിങ്ങളുടെ വാഹനത്തിന്റെ സർവീസ് തൃപ്തികരമായി പൂർത്തിയായി എന്ന് കരുതുന്നു.\n\n'
          'നിങ്ങളുടെ വിലയേറിയ അഭിപ്രായങ്ങളും റേറ്റിംഗും പങ്കുവെക്കാൻ ഒരു മിനിറ്റ് സമയം നൽകാമോ? ഇത് ഞങ്ങളുടെ സേവനം കൂടുതൽ മികച്ചതാക്കാൻ സഹായിക്കും:\n'
          '$link\n\n'
          'നന്ദി,\n$garageName';
    }

    if (language == 'bilingual') {
      return 'Hello $customerName / നമസ്കാരം,\n\n'
          'Thank you for choosing $garageName! We hope your vehicle service went well.\n'
          'Could you spare a minute to rate your experience and share your feedback?\n'
          'നിങ്ങളുടെ വിലയേറിയ അഭിപ്രായങ്ങളും റേറ്റിംഗും പങ്കുവെക്കാൻ താഴെയുള്ള ലിങ്ക് സന്ദർശിക്കുക:\n'
          '$link\n\n'
          'Thank you / നന്ദി,\n$garageName';
    }

    return 'Hi $customerName,\n\n'
        'Thank you for choosing $garageName! We hope your vehicle service went well.\n\n'
        'Could you spare a minute to rate your experience and share your feedback? Your feedback helps us improve our service:\n'
        '$link\n\n'
        'Thank you,\n$garageName';
  }
}
