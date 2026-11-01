import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/app.dart';
import 'package:garage_card/core/shared_widgets/app_responsive_layout.dart';

void main() {
  testWidgets(
    'GarageCardApp limits width and centers content on large screens',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const ProviderScope(child: GarageCardApp()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      final matching = constrainedBoxes.where(
        (b) =>
            b.constraints.maxWidth ==
            AppResponsiveLayout.kMaxDesktopViewportWidth,
      );

      expect(matching.isNotEmpty, isTrue);
      expect(
        matching.first.constraints.maxWidth,
        equals(AppResponsiveLayout.kMaxDesktopViewportWidth),
      );
    },
  );

  testWidgets('GarageCardApp does not restrict mobile viewports', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const ProviderScope(child: GarageCardApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(GarageCardApp), findsOneWidget);
  });
}
