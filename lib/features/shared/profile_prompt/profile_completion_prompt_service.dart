import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/shared/models/user_profile_model.dart';

import 'profile_completion_bottom_sheet.dart';

class ProfileCompletionPromptService {
  const ProfileCompletionPromptService();

  static const String _prefPrefix = 'profile_prompt_last_date_';
  static const String _completedPrefix = 'profile_permanently_completed_';

  Future<bool> shouldShowPrompt(UserProfileModel? user) async {
    if (user == null) return false;
    if (user.isProfileComplete) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_completedPrefix${user.uid}', true);
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final isPermanentlyCompleted =
        prefs.getBool('$_completedPrefix${user.uid}') ?? false;
    if (isPermanentlyCompleted) return false;

    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastShownDate = prefs.getString('$_prefPrefix${user.uid}');

    if (lastShownDate == todayKey) {
      return false;
    }

    return true;
  }

  Future<void> markPromptShownToday(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await prefs.setString('$_prefPrefix$uid', todayKey);
  }

  Future<void> markProfileCompleted(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_completedPrefix$uid', true);
  }

  Future<void> checkAndShowPrompt(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authViewModelProvider);
    final user = authState.userProfile;
    if (user == null) return;

    final shouldShow = await shouldShowPrompt(user);
    if (!shouldShow) return;

    await markPromptShownToday(user.uid);

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProfileCompletionBottomSheet(userProfile: user),
    );
  }
}

final profileCompletionPromptServiceProvider =
    Provider<ProfileCompletionPromptService>((ref) {
      return const ProfileCompletionPromptService();
    });
