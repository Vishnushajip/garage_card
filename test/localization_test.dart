import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations English and Malayalam tests', () {
    final enLoc = AppLocalizations(const Locale('en'));
    final mlLoc = AppLocalizations(const Locale('ml'));

    test('Translates core keys accurately in English and Malayalam', () {
      expect(enLoc.translate('home'), equals('Home'));
      expect(mlLoc.translate('home'), equals('ഹോം'));

      expect(enLoc.translate('garages'), equals('Garages'));
      expect(mlLoc.translate('garages'), equals('വർക്ക്‌ഷോപ്പുകൾ'));

      expect(enLoc.translate('nearbyGarages'), equals('Nearby Garages'));
      expect(mlLoc.translate('nearbyGarages'), equals('സമീപമുള്ള ഗാരേജുകൾ'));

      expect(enLoc.translate('invoices'), equals('Invoices'));
      expect(mlLoc.translate('invoices'), equals('ഇൻവോയ്സുകൾ'));

      expect(enLoc.translate('profile'), equals('Profile'));
      expect(mlLoc.translate('profile'), equals('പ്രൊഫൈൽ'));

      expect(enLoc.translate('accountProfile'), equals('Account Profile'));
      expect(mlLoc.translate('accountProfile'), equals('അക്കൗണ്ട് പ്രൊഫൈൽ'));

      expect(
        enLoc.translate('languagePreference'),
        equals('Language Preference'),
      );
      expect(mlLoc.translate('languagePreference'), equals('ഭാഷാ മുൻഗണന'));

      expect(enLoc.translate('warrantyVault'), equals('Warranty Vault'));
      expect(mlLoc.translate('warrantyVault'), equals('വാറന്റി വോൾട്ട്'));
    });

    test('Phrase-to-key mapping resolves raw UI strings accurately', () {
      expect(enLoc.translate('Account Profile'), equals('Account Profile'));
      expect(mlLoc.translate('Account Profile'), equals('അക്കൗണ്ട് പ്രൊഫൈൽ'));

      expect(
        enLoc.translate('Personal details & mode switching'),
        equals('Personal details & mode switching'),
      );
      expect(
        mlLoc.translate('Personal details & mode switching'),
        equals('വ്യക്തിഗത വിവരങ്ങളും അക്കൗണ്ട് മാറ്റവും'),
      );

      expect(
        mlLoc.translate('Select your preferred display language'),
        equals('നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക'),
      );

      expect(
        mlLoc.translate('Profile Incomplete'),
        equals('പ്രൊഫൈൽ പൂർണ്ണമല്ല'),
      );
      expect(
        mlLoc.translate('Complete Profile Now'),
        equals('പ്രൊഫൈൽ പൂർത്തിയാക്കുക'),
      );
      expect(
        mlLoc.translate('Edit Profile Details'),
        equals('പ്രൊഫൈൽ തിരുത്തുക'),
      );
    });

    test('Dynamic status mapping converts raw database status codes', () {
      expect(enLoc.repairStatus('in_progress'), equals('In Progress'));
      expect(mlLoc.repairStatus('in_progress'), equals('പുരോഗമിക്കുന്നു'));

      expect(enLoc.repairStatus('completed'), equals('Completed'));
      expect(mlLoc.repairStatus('completed'), equals('പൂർത്തിയായി'));

      expect(enLoc.repairStatus('received'), equals('Received'));
      expect(mlLoc.repairStatus('received'), equals('ലഭിച്ചു'));

      expect(
        enLoc.repairStatus('inspection_pending'),
        equals('Inspection Pending'),
      );
      expect(
        mlLoc.repairStatus('inspection_pending'),
        equals('പരിശോധന ബാക്കി'),
      );

      expect(
        enLoc.repairStatus('estimate_pending'),
        equals('Estimate Pending'),
      );
      expect(
        mlLoc.repairStatus('estimate_pending'),
        equals('എസ്റ്റിമേറ്റ് ബാക്കി'),
      );

      expect(enLoc.repairStatus('waiting_for_parts'), equals('Awaiting Parts'));
      expect(
        mlLoc.repairStatus('waiting_for_parts'),
        equals('പാർട്സുകൾക്കായി കാത്തിരിക്കുന്നു'),
      );

      expect(
        enLoc.repairStatus('ready_for_collection'),
        equals('Ready for Collection'),
      );
      expect(
        mlLoc.repairStatus('ready_for_collection'),
        equals('എടുക്കാൻ തയ്യാറാണ്'),
      );

      expect(enLoc.invoiceStatus('paid'), equals('Paid'));
      expect(mlLoc.invoiceStatus('paid'), equals('നൽകി'));

      expect(enLoc.invoiceStatus('unpaid'), equals('Unpaid'));
      expect(mlLoc.invoiceStatus('unpaid'), equals('നൽകാനുണ്ട്'));

      expect(enLoc.invoiceStatus('overdue'), equals('Overdue'));
      expect(mlLoc.invoiceStatus('overdue'), equals('കാലഹരണപ്പെട്ടു'));

      expect(enLoc.maintenanceStatus('due_soon'), equals('Due Soon'));
      expect(mlLoc.maintenanceStatus('due_soon'), equals('ഉടൻ ചെയ്യേണ്ടത്'));

      expect(enLoc.maintenanceStatus('due'), equals('Due Now'));
      expect(mlLoc.maintenanceStatus('due'), equals('ഇപ്പോൾ ചെയ്യേണ്ടത്'));
    });

    test('Universal status helper resolves repair, invoice, and maintenance states', () {
      expect(mlLoc.status('in_progress'), equals('പുരോഗമിക്കുന്നു'));
      expect(mlLoc.status('completed'), equals('പൂർത്തിയായി'));
      expect(mlLoc.status('paid'), equals('നൽകി'));
      expect(mlLoc.status('unpaid'), equals('നൽകാനുണ്ട്'));
      expect(mlLoc.status('overdue'), equals('കാലഹരണപ്പെട്ടു'));
      expect(mlLoc.status('active'), equals('ആക്ടീവ്'));
    });

    test(
      'Preserves user and business records without translating database values',
      () {
        const garageName = 'Vishnu Auto Care';
        const customerName = 'Vishnu Shaji';
        const licensePlate = 'KL 07 AB 1234';
        const customNotes =
            'Front suspension strut needs replacement due to leakage';

        expect(mlLoc.translate(garageName), equals(garageName));
        expect(mlLoc.translate(customerName), equals(customerName));
        expect(mlLoc.translate(licensePlate), equals(licensePlate));
        expect(mlLoc.translate(customNotes), equals(customNotes));
      },
    );

    test('Formats relative time in Malayalam and English', () {
      final now = DateTime.now();
      expect(enLoc.relativeTime(now), equals('Just now'));
      expect(mlLoc.relativeTime(now), equals('ഇപ്പോൾ'));

      final tenMinutesAgo = now.subtract(const Duration(minutes: 10));
      expect(enLoc.relativeTime(tenMinutesAgo), equals('10m ago'));
      expect(mlLoc.relativeTime(tenMinutesAgo), equals('10 മിനിറ്റ് മുൻപ്'));

      final twoHoursAgo = now.subtract(const Duration(hours: 2));
      expect(enLoc.relativeTime(twoHoursAgo), equals('2h ago'));
      expect(mlLoc.relativeTime(twoHoursAgo), equals('2 മണിക്കൂർ മുൻപ്'));

      final yesterday = now.subtract(const Duration(days: 1));
      expect(enLoc.relativeTime(yesterday), equals('Yesterday'));
      expect(mlLoc.relativeTime(yesterday), equals('ഇന്നലെ'));

      expect(enLoc.relativeTime(null), equals('-'));
      expect(mlLoc.relativeTime(null), equals('-'));
    });

    test('Formats plurals correctly in English and Malayalam', () {
      expect(enLoc.plural('jobs', 1), equals('1 repair job'));
      expect(enLoc.plural('jobs', 3), equals('3 repair jobs'));
      expect(mlLoc.plural('jobs', 1), equals('1 റിപ്പയർ ജോലികൾ'));
      expect(mlLoc.plural('jobs', 3), equals('3 റിപ്പയർ ജോലികൾ'));

      expect(enLoc.plural('vehicles', 1), equals('1 vehicle'));
      expect(enLoc.plural('vehicles', 2), equals('2 vehicles'));
      expect(mlLoc.plural('vehicles', 1), equals('1 വാഹനങ്ങൾ'));
      expect(mlLoc.plural('vehicles', 2), equals('2 വാഹനങ്ങൾ'));
    });
  });
}
