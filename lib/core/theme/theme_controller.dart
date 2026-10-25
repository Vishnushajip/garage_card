import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themePrefKey = 'selected_theme_mode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadPersistedTheme();
    return ThemeMode.light;
  }

  Future<void> _loadPersistedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themePrefKey);
    if (savedMode != null) {
      if (savedMode == 'dark') {
        state = ThemeMode.dark;
      } else if (savedMode == 'light') {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.system;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    final modeString = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themePrefKey, modeString);
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
