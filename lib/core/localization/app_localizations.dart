import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Garage Card',
      'login': 'Sign In',
      'register': 'Create Account',
      'email': 'Email Address',
      'password': 'Password',
      'fullName': 'Full Name',
      'phoneNumber': 'Phone Number',
      'selectRole': 'Select Experience',
      'roleCustomer': 'Customer',
      'roleMerchant': 'Merchant (Garage Owner)',
      'home': 'Home',
      'garages': 'Nearby Garages',
      'myVehicles': 'My Vehicles',
      'myServices': 'My Services',
      'estimates': 'Estimates',
      'invoices': 'Invoices',
      'payments': 'Payments',
      'notifications': 'Notifications',
      'profile': 'Profile',
      'settings': 'Settings',
      'dashboard': 'Dashboard',
      'customers': 'Customers',
      'vehicles': 'Vehicles',
      'jobs': 'Service Jobs',
      'inspections': 'Inspections',
      'appointments': 'Appointments',
      'reminders': 'Reminders',
      'serviceCatalog': 'Services Catalog',
      'activeJobs': 'Active Jobs',
      'completedJobs': 'Completed Jobs',
      'readyForPickup': 'Ready for Pickup',
      'call': 'Call',
      'whatsapp': 'WhatsApp',
      'directions': 'Directions',
      'requestService': 'Request Service',
      'approve': 'Approve',
      'reject': 'Reject',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'search': 'Search',
      'filter': 'Filter',
      'refresh': 'Refresh',
      'statusDraft': 'Draft',
      'statusReceived': 'Received',
      'statusInspectionPending': 'Inspection Pending',
      'statusEstimatePending': 'Estimate Pending',
      'statusEstimateApproved': 'Estimate Approved',
      'statusInProgress': 'In Progress',
      'statusReady': 'Ready for Collection',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',
      'statusOverdue': 'Overdue',
      'statusPending': 'Pending',
      'statusPaid': 'Paid',
      'statusPartiallyPaid': 'Partially Paid',
      'noDataFound': 'No records found',
      'somethingWentWrong': 'Something went wrong',
      'tryAgain': 'Try Again',
      'signOut': 'Sign Out',
      'language': 'Language',
      'theme': 'Theme',
      'currency': 'Currency',
      'odometer': 'Odometer Reading',
      'licensePlate': 'Registration Number',
      'makeAndModel': 'Vehicle Make & Model',
      'year': 'Model Year',
      'nextServiceDue': 'Next Service Due',
      'lastServiceDate': 'Last Service Date',
    },
    'ml': {
      'appName': 'ഗാരേജ് കാർഡ്',
      'login': 'ലോഗിൻ ചെയ്യുക',
      'register': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
      'email': 'ഇമെയിൽ വിലാസം',
      'password': 'പാസ്‌വേഡ്',
      'fullName': 'പൂർണ്ണ നാമം',
      'phoneNumber': 'ഫോൺ നമ്പർ',
      'selectRole': 'റോൾ തിരഞ്ഞെടുക്കുക',
      'roleCustomer': 'ഉപഭോക്താവ്',
      'roleMerchant': 'ഗാരേജ് ഉടമ (മെർച്ചന്റ്)',
      'home': 'ഹോം',
      'garages': 'സമീപമുള്ള ഗാരേജുകൾ',
      'myVehicles': 'എന്റെ വാഹനങ്ങൾ',
      'myServices': 'എന്റെ സർവീസുകൾ',
      'estimates': 'എസ്റ്റിമേറ്റുകൾ',
      'invoices': 'ഇൻവോയ്സുകൾ',
      'payments': 'പേയ്‌മെന്റുകൾ',
      'notifications': 'അറിയിപ്പുകൾ',
      'profile': 'പ്രൊഫൈൽ',
      'settings': 'സെറ്റിംഗ്സ്',
      'dashboard': 'ഡാഷ്‌ബോർഡ്',
      'customers': 'ഉപഭോക്താക്കൾ',
      'vehicles': 'വാഹനങ്ങൾ',
      'jobs': 'സർവീസ് ജോബ്സ്',
      'inspections': 'പരിശോധനകൾ',
      'appointments': 'അപ്പോയിന്റ്മെന്റുകൾ',
      'reminders': 'ഓർമ്മപ്പെടുത്തലുകൾ',
      'serviceCatalog': 'സർവീസ് കാറ്റലോഗ്',
      'activeJobs': 'നിലവിലെ ജോലികൾ',
      'completedJobs': 'പൂർത്തിയായ ജോലികൾ',
      'readyForPickup': 'വാഹനം റെഡിയാണ്',
      'call': 'വിളിക്കുക',
      'whatsapp': 'വാട്ട്‌സ്ആപ്പ്',
      'directions': 'റൂട്ട്',
      'requestService': 'സർവീസ് ആവശ്യപ്പെടുക',
      'approve': 'അംഗീകരിക്കുക',
      'reject': 'നിരസിക്കുക',
      'save': 'സേവ് ചെയ്യുക',
      'cancel': 'റദ്ദാക്കുക',
      'delete': 'ഡിലീറ്റ് ചെയ്യുക',
      'search': 'തിരയുക',
      'filter': 'ഫിൽട്ടർ',
      'refresh': 'പുതുക്കുക',
      'statusDraft': 'ഡ്രാഫ്റ്റ്',
      'statusReceived': 'ലഭിച്ചു',
      'statusInspectionPending': 'പരിശോധന ബാക്കി',
      'statusEstimatePending': 'എസ്റ്റിമേറ്റ് ബാക്കി',
      'statusEstimateApproved': 'എസ്റ്റിമേറ്റ് അംഗീകരിച്ചു',
      'statusInProgress': 'പുരോഗമിക്കുന്നു',
      'statusReady': 'എടുക്കാൻ തയ്യാറാണ്',
      'statusCompleted': 'പൂർത്തിയായി',
      'statusCancelled': 'റദ്ദാക്കി',
      'statusOverdue': 'കാലഹരണപ്പെട്ടു',
      'statusPending': 'ബാക്കി',
      'statusPaid': 'നൽകി',
      'statusPartiallyPaid': 'ഭാഗികമായി നൽകി',
      'noDataFound': 'വിവരങ്ങൾ ഒന്നും ലഭ്യമല്ല',
      'somethingWentWrong': 'എന്തോ തകരാർ സംഭവിച്ചു',
      'tryAgain': 'വീണ്ടും ശ്രമിക്കുക',
      'signOut': 'പുറത്തുകടക്കുക',
      'language': 'ഭാഷ',
      'theme': 'തീം',
      'currency': 'കറൻസി',
      'odometer': 'ഓഡോമീറ്റർ റീഡിംഗ്',
      'licensePlate': 'രജിസ്ട്രേഷൻ നമ്പർ',
      'makeAndModel': 'വാഹന മോഡൽ',
      'year': 'നിർമ്മിത വർഷം',
      'nextServiceDue': 'അടുത്ത സർവീസ് തീയതി',
      'lastServiceDate': 'കഴിഞ്ഞ സർവീസ് തീയതി',
    },
  };

  String translate(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ml'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const String _localePrefKey = 'selected_locale_code';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadPersistedLocale();
    return const Locale('en');
  }

  Future<void> _loadPersistedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localePrefKey);
    if (savedCode != null && (savedCode == 'en' || savedCode == 'ml')) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'ml') return;
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
