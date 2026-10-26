import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';
import 'package:garage_card/features/shared/profile_prompt/profile_completion_prompt_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileCompletionPromptService Tests', () {
    const service = ProfileCompletionPromptService();

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('shouldShowPrompt returns true for incomplete profile on first prompt of the day', () async {
      const user = UserProfileModel(
        uid: 'user_test_1',
        email: 'test@example.com',
        fullName: '',
        phoneNumber: '',
        whatsappNumber: '',
      );

      expect(user.isProfileComplete, isFalse);
      expect(user.completionPercentage, closeTo(1 / 4.0, 0.01));

      final shouldShow = await service.shouldShowPrompt(user);
      expect(shouldShow, isTrue);
    });

    test(
      'shouldShowPrompt returns false when already prompted today',
      () async {
        const user = UserProfileModel(
          uid: 'user_test_1',
          email: 'test@example.com',
          fullName: 'Test User',
          phoneNumber: '',
          whatsappNumber: '',
        );

        final shouldShowFirst = await service.shouldShowPrompt(user);
        expect(shouldShowFirst, isTrue);

        await service.markPromptShownToday(user.uid);

        final shouldShowSecond = await service.shouldShowPrompt(user);
        expect(shouldShowSecond, isFalse);
      },
    );

    test('shouldShowPrompt returns false and marks completed when profile is 100% complete', () async {
      const completeUser = UserProfileModel(
        uid: 'user_test_2',
        email: 'john@example.com',
        fullName: 'John Doe',
        phoneNumber: '+91 98765 43210',
        whatsappNumber: '+91 98765 43210',
      );

      expect(completeUser.isProfileComplete, isTrue);
      expect(completeUser.completionPercentage, 1.0);

      final shouldShow = await service.shouldShowPrompt(completeUser);
      expect(shouldShow, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool('profile_permanently_completed_user_test_2'),
        isTrue,
      );
    });

    test(
      'markProfileCompleted permanently stops prompt from showing',
      () async {
        const user = UserProfileModel(
          uid: 'user_test_3',
          email: 'test@example.com',
          fullName: '',
          phoneNumber: '',
          whatsappNumber: '',
        );

        await service.markProfileCompleted(user.uid);

        final shouldShow = await service.shouldShowPrompt(user);
        expect(shouldShow, isFalse);
      },
    );
  });
}
