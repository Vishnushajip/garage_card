import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/localization/app_localizations.dart';
import 'package:garage_card/features/merchant/garage_profile/Widgets/working_hours_selector.dart';
import 'package:garage_card/features/shared/models/working_hours_model.dart';

void main() {
  group('WorkingHoursSchedule Model Tests', () {
    test(
      'defaultSchedule provides 7 days with Mon-Sat open and Sun closed',
      () {
        final schedule = WorkingHoursSchedule.defaultSchedule();
        expect(schedule.length, 7);

        for (int i = 0; i < 6; i++) {
          expect(schedule[i].isOpen, isTrue);
          expect(schedule[i].openTime, '08:30 AM');
          expect(schedule[i].closeTime, '07:30 PM');
        }

        expect(schedule[6].day, 'sunday');
        expect(schedule[6].isOpen, isFalse);
      },
    );

    test('parse handles Map list accurately', () {
      final input = [
        {
          'day': 'monday',
          'isOpen': true,
          'openTime': '09:00 AM',
          'closeTime': '06:00 PM',
        },
        {
          'day': 'tuesday',
          'isOpen': true,
          'openTime': '09:00 AM',
          'closeTime': '06:00 PM',
        },
        {
          'day': 'wednesday',
          'isOpen': true,
          'openTime': '09:00 AM',
          'closeTime': '06:00 PM',
        },
        {
          'day': 'thursday',
          'isOpen': true,
          'openTime': '09:00 AM',
          'closeTime': '06:00 PM',
        },
        {
          'day': 'friday',
          'isOpen': true,
          'openTime': '09:00 AM',
          'closeTime': '06:00 PM',
        },
        {
          'day': 'saturday',
          'isOpen': false,
          'openTime': '09:00 AM',
          'closeTime': '01:00 PM',
        },
        {
          'day': 'sunday',
          'isOpen': false,
          'openTime': '09:00 AM',
          'closeTime': '01:00 PM',
        },
      ];

      final result = WorkingHoursSchedule.parse(input);
      expect(result.length, 7);
      expect(result[0].openTime, '09:00 AM');
      expect(result[5].isOpen, isFalse);
    });

    test('parse handles fallback string', () {
      final result = WorkingHoursSchedule.parse(null, '10:00 AM - 08:00 PM');
      expect(result.length, 7);
      expect(result[0].openTime, '10:00 AM');
      expect(result[0].closeTime, '08:00 PM');
      expect(result[6].isOpen, isFalse);
    });

    test(
      'toDisplaySummary handles Mon-Sat, All Days, and Closed schedules',
      () {
        final defaultSched = WorkingHoursSchedule.defaultSchedule();
        final summary = WorkingHoursSchedule.toDisplaySummary(defaultSched);
        expect(
          summary,
          contains('Mon - Sat: 08:30 AM - 07:30 PM, Sun: Closed'),
        );

        final allClosed = defaultSched
            .map((d) => d.copyWith(isOpen: false))
            .toList();
        expect(
          WorkingHoursSchedule.toDisplaySummary(allClosed),
          'Temporarily Closed',
        );

        final allDays = defaultSched
            .map(
              (d) => d.copyWith(
                isOpen: true,
                openTime: '08:30 AM',
                closeTime: '07:30 PM',
              ),
            )
            .toList();
        expect(
          WorkingHoursSchedule.toDisplaySummary(allDays),
          'Daily: 08:30 AM - 07:30 PM',
        );
      },
    );

    test('isCurrentlyOpen calculates accurately based on day and time', () {
      final schedule = WorkingHoursSchedule.defaultSchedule();

      final mondayNoon = DateTime(2026, 11, 2, 12, 0);
      expect(
        WorkingHoursSchedule.isCurrentlyOpen(schedule, mondayNoon),
        isTrue,
      );

      final mondayMidnight = DateTime(2026, 11, 2, 23, 0);
      expect(
        WorkingHoursSchedule.isCurrentlyOpen(schedule, mondayMidnight),
        isFalse,
      );

      final sundayNoon = DateTime(2026, 11, 8, 12, 0);
      expect(
        WorkingHoursSchedule.isCurrentlyOpen(schedule, sundayNoon),
        isFalse,
      );
    });
  });

  group('WorkingHoursSelector Widget Tests', () {
    testWidgets(
      'renders all 7 days with switches and responds to preset taps',
      (tester) async {
        final schedule = WorkingHoursSchedule.defaultSchedule();
        List<DayWorkingHours>? updated;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [AppLocalizations.delegate],
            home: Scaffold(
              body: SingleChildScrollView(
                child: WorkingHoursSelector(
                  schedule: schedule,
                  onChanged: (newSched) => updated = newSched,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mon'), findsOneWidget);
        expect(find.text('Tue'), findsOneWidget);
        expect(find.text('Wed'), findsOneWidget);
        expect(find.text('Thu'), findsOneWidget);
        expect(find.text('Fri'), findsOneWidget);
        expect(find.text('Sat'), findsOneWidget);
        expect(find.text('Sun'), findsOneWidget);

        expect(find.byType(Switch), findsNWidgets(7));

        await tester.tap(find.text('Mon - Fri'));
        await tester.pumpAndSettle();

        expect(updated, isNotNull);
        expect(updated!.firstWhere((d) => d.day == 'saturday').isOpen, isFalse);
        expect(updated!.firstWhere((d) => d.day == 'sunday').isOpen, isFalse);
        expect(updated!.firstWhere((d) => d.day == 'monday').isOpen, isTrue);
      },
    );

    testWidgets('toggling a day switch updates that day state', (tester) async {
      final schedule = WorkingHoursSchedule.defaultSchedule();
      List<DayWorkingHours>? updated;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          home: Scaffold(
            body: SingleChildScrollView(
              child: WorkingHoursSelector(
                schedule: schedule,
                onChanged: (newSched) => updated = newSched,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstSwitch = find.byType(Switch).first;
      await tester.tap(firstSwitch);
      await tester.pumpAndSettle();

      expect(updated, isNotNull);
      expect(updated!.first.day, 'monday');
      expect(updated!.first.isOpen, isFalse);
    });
  });
}
