import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage_card/app.dart';
import 'package:garage_card/core/branding/app_branding.dart';
import 'package:garage_card/features/authentication/Model/auth_state.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/splash/View/splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'App launches with WeFix splash screen and transitions to auth screen',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith(
              () => _UnauthMockAuthViewModel(),
            ),
          ],
          child: const GarageCardApp(),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('VEHICLE SERVICE PLATFORM'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(AppBranding.appName), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
    },
  );
}

class _UnauthMockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return const AuthState(
      isLoading: false,
      isInitialized: true,
      userProfile: null,
      activeExperience: 'customer',
    );
  }
}
