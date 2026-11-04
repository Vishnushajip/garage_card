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

  static Future<bool> openWhatsApp({
    String? phoneNumber,
    String? phone,
    String message = '',
  }) => sendWhatsAppMessage(
    phoneNumber: phoneNumber ?? phone ?? '',
    message: message,
  );

  static Future<bool> openWhatsAppChat({
    String? phoneNumber,
    String? phone,
    String text = '',
  }) => sendWhatsAppMessage(
    phoneNumber: phoneNumber ?? phone ?? '',
    message: text,
  );

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
          'കൂടുതൽ വിവരങ്ങൾക്ക് വിഫിക്സ് ആപ്പ് സന്ദർശിക്കുക.\n'
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
        'Track live progress in your WeFix app / കൂടുതൽ വിവരങ്ങൾക്ക് വിഫിക്സ് ആപ്പ് കാണുക.\n\n'
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
    final link = 'https://wefix.app/customer/garages/$garageId';
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

  static String composeJobCreatedNotification({
    required String customerName,
    required String garageName,
    required String bikeNumber,
    String? bikeModel,
    required String problem,
    required String jobNumber,
    required String mechanic,
    String language = 'english',
  }) {
    final vehicle = (bikeModel != null && bikeModel.isNotEmpty)
        ? '$bikeNumber ($bikeModel)'
        : bikeNumber;
    if (language.toLowerCase() == 'malayalam') {
      return 'നമസ്കാരം $customerName,\n\n'
          'താങ്കളുടെ വാഹനം ($vehicle) സർവീസിനായി $garageName-ൽ രജിസ്റ്റർ ചെയ്തിട്ടുണ്ട്.\n'
          '• ജോബ് നമ്പർ: $jobNumber\n'
          '• വാഹനം: $vehicle\n'
          '• പ്രശ്നം: $problem\n'
          '• ചുമതലയുള്ള മെക്കാനിക്ക്: $mechanic\n'
          '• നിലവിലെ അവസ്ഥ: രജിസ്റ്റർ ചെയ്തു\n\n'
          'റിപ്പയർ ജോലികൾ പുരോഗമിക്കുമ്പോൾ ഞങ്ങൾ വിവരങ്ങൾ അറിയിക്കുന്നതാണ്.\n'
          'നന്ദി,\n$garageName';
    }
    return 'Hello $customerName,\n\n'
        'Your vehicle ($vehicle) has been registered for service at $garageName.\n'
        '• Job Number: $jobNumber\n'
        '• Vehicle: $vehicle\n'
        '• Reported Problem: $problem\n'
        '• Assigned Mechanic: $mechanic\n'
        '• Status: Pending / Registered\n\n'
        'We will keep you updated as the work progresses.\n'
        'Thank you,\n$garageName';
  }

  static String composeExtraWorkNotification({
    required String customerName,
    required String garageName,
    required String bikeNumber,
    required String extraWorkTitle,
    required double estimatedCharge,
    String language = 'english',
  }) {
    final formattedCharge = '₹${estimatedCharge.toStringAsFixed(0)}';
    if (language.toLowerCase() == 'malayalam') {
      return 'നമസ്കാരം $customerName,\n\n'
          '$garageName-ൽ നൽകിയ താങ്കളുടെ വാഹനം ($bikeNumber) പരിശോധിച്ചപ്പോൾ അധിക റിപ്പയർ ജോലി ആവശ്യമായി വന്നിട്ടുണ്ട്:\n'
          '• അധിക ജോലി: $extraWorkTitle\n'
          '• അധിക തുക: $formattedCharge\n\n'
          'ഈ അധിക ജോലി മുന്നോട്ട് കൊണ്ടുപോകുന്നതിനായി താങ്കളുടെ അനുമതി അറിയിക്കുമല്ലോ.\n'
          'നന്ദി,\n$garageName';
    }
    return 'Hello $customerName,\n\n'
        'During the inspection of your vehicle ($bikeNumber) at $garageName, additional work was found to be needed:\n'
        '• Extra Work: $extraWorkTitle\n'
        '• Estimated Additional Charge: $formattedCharge\n\n'
        'Please confirm if you approve this additional work.\n'
        'Thank you,\n$garageName';
  }

  static String composeWorkCompletedNotification({
    required String customerName,
    required String garageName,
    required String bikeNumber,
    String? bikeModel,
    required String originalWork,
    String? extraWork,
    required double finalBillAmount,
    String language = 'english',
  }) {
    final vehicle = (bikeModel != null && bikeModel.isNotEmpty)
        ? '$bikeNumber ($bikeModel)'
        : bikeNumber;
    final formattedTotal = '₹${finalBillAmount.toStringAsFixed(0)}';
    if (language.toLowerCase() == 'malayalam') {
      final extraText = (extraWork != null && extraWork.isNotEmpty)
          ? '\n• അധിക ജോലി: $extraWork'
          : '';
      return 'നമസ്കാരം $customerName,\n\n'
          '$garageName-ൽ നൽകിയിരുന്ന താങ്കളുടെ വാഹനം ($vehicle) റിപ്പയർ ജോലികൾ വിജയകരമായി പൂർത്തിയായി!\n'
          '• പൂർത്തിയാക്കിയ ജോലി: $originalWork'
          '$extraText\n'
          '• ആകെ ബിൽ തുക: $formattedTotal\n\n'
          'താങ്കളുടെ വാഹനം ഡെലിവറിക്ക് തയ്യാറാണ്.\n'
          'നന്ദി,\n$garageName';
    }
    final extraText = (extraWork != null && extraWork.isNotEmpty)
        ? '\n• Extra Work: $extraWork'
        : '';
    return 'Hello $customerName,\n\n'
        'Your vehicle ($vehicle) service and repairs have been completed at $garageName!\n'
        '• Completed Work: $originalWork'
        '$extraText\n'
        '• Final Bill Amount: $formattedTotal\n\n'
        'Your vehicle is ready for pickup.\n'
        'Thank you,\n$garageName';
  }

  static String composeJobInvoiceNotification({
    required String customerName,
    required String garageName,
    required String bikeNumber,
    required String invoiceNumber,
    required double finalAmount,
    required double paidAmount,
    required double balanceDue,
    required String paymentStatus,
    String language = 'english',
  }) {
    final formattedFinal = '₹${finalAmount.toStringAsFixed(0)}';
    final formattedPaid = '₹${paidAmount.toStringAsFixed(0)}';
    final formattedBalance = '₹${balanceDue.toStringAsFixed(0)}';
    if (language.toLowerCase() == 'malayalam') {
      String mlStatus = 'അടച്ചിട്ടില്ല';
      if (paymentStatus.toLowerCase().contains('paid') &&
          !paymentStatus.toLowerCase().contains('unpaid') &&
          !paymentStatus.toLowerCase().contains('partially')) {
        mlStatus = 'പൂർണ്ണമായി അടച്ചു';
      } else if (paymentStatus.toLowerCase().contains('partially')) {
        mlStatus = 'ഭാഗികമായി അടച്ചു';
      }
      return 'നമസ്കാരം $customerName,\n\n'
          '$garageName-ൽ നിന്നുള്ള താങ്കളുടെ വാഹനം ($bikeNumber) സർവീസ് ഇൻവോയ്സ് വിവരങ്ങൾ:\n'
          '• ഇൻവോയ്സ് നമ്പർ: $invoiceNumber\n'
          '• ആകെ ബിൽ തുക: $formattedFinal\n'
          '• അടച്ച തുക: $formattedPaid\n'
          '• ബാക്കി നൽകാനുള്ള തുക: $formattedBalance\n'
          '• പേയ്‌മെന്റ് അവസ്ഥ: $mlStatus\n\n'
          'ഞങ്ങളുടെ സർവീസ് തിരഞ്ഞെടുത്തതിന് നന്ദി!\n$garageName';
    }
    return 'Hello $customerName,\n\n'
        'Here are the invoice details from $garageName for your vehicle ($bikeNumber):\n'
        '• Invoice Number: $invoiceNumber\n'
        '• Total Amount: $formattedFinal\n'
        '• Amount Paid: $formattedPaid\n'
        '• Balance Due: $formattedBalance\n'
        '• Payment Status: ${paymentStatus.toUpperCase()}\n\n'
        'Thank you for your business!\n$garageName';
  }
}
