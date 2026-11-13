import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/branding/app_branding.dart';
import 'core/colors/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/network/app_connectivity_wrapper.dart';
import 'core/notifications/app_notification_host.dart';
import 'core/routing/app_router.dart';
import 'core/shared_widgets/app_responsive_layout.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class WeFixApp extends ConsumerWidget {
  const WeFixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: AppBranding.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ml')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final mediaQuery = MediaQuery.of(context);
        final isBigScreen =
            mediaQuery.size.width >
            AppResponsiveLayout.kMaxDesktopViewportWidth;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final canvasColor = isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight;
        final borderColor = isDark
            ? AppColors.borderDark
            : AppColors.borderLight;

        final effectiveMediaQuery = isBigScreen
            ? mediaQuery.copyWith(
                size: Size(
                  AppResponsiveLayout.kMaxDesktopViewportWidth,
                  mediaQuery.size.height,
                ),
              )
            : mediaQuery;

        return ColoredBox(
          color: canvasColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppResponsiveLayout.kMaxDesktopViewportWidth,
              ),
              child: Container(
                decoration: isBigScreen
                    ? BoxDecoration(
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: borderColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.35 : 0.05,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      )
                    : null,
                child: MediaQuery(
                  data: effectiveMediaQuery,
                  child: AppConnectivityWrapper(
                    child: AppNotificationHost(child: content),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
