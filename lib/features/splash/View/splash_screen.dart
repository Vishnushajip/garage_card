import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/branding/app_logo.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:garage_card/features/splash/Widgets/splash_reveal_painter.dart';
import 'package:garage_card/features/splash/Widgets/splash_tachometer_painter.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tachometerAnimation;
  late final Animation<double> _badgeScaleAnimation;
  late final Animation<double> _badgeFadeAnimation;
  late final Animation<double> _shimmerAnimation;
  late final Animation<double> _sparkRippleAnimation;
  late final Animation<double> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<double> _taglineFadeAnimation;
  late final Animation<double> _taglineTrackingAnimation;
  late final Animation<double> _revealAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _tachometerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.22, curve: Curves.easeInOutCubic),
    );

    _badgeScaleAnimation = Tween<double>(begin: 0.76, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.25, curve: Curves.easeOutBack),
      ),
    );

    _badgeFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.16, curve: Curves.easeOut),
    );

    _shimmerAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.46, curve: Curves.easeInOutSine),
    );

    _sparkRippleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.36, 0.60, curve: Curves.easeOutQuad),
    );

    _textSlideAnimation = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.16, 0.36, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.16, 0.34, curve: Curves.easeOut),
    );

    _taglineFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.26, 0.44, curve: Curves.easeOut),
    );

    _taglineTrackingAnimation = Tween<double>(begin: 1.5, end: 3.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.26, 0.50, curve: Curves.easeOutCubic),
      ),
    );

    _revealAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 1.0, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToTarget();
      }
    });

    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations && !_hasNavigated) {
      _controller.value = 1.0;
      _navigateToTarget();
    }
  }

  void _navigateToTarget() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final authState = ref.read(authViewModelProvider);
    if (!authState.isAuthenticated) {
      context.go(RoutePaths.auth);
    } else if (authState.activeExperience == 'merchant') {
      context.go(RoutePaths.merchant);
    } else {
      context.go(RoutePaths.customer);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final breathValue = math.sin(_controller.value * math.pi * 3);
              final auraOpacity = (0.04 + 0.03 * breathValue).clamp(0.0, 0.08);

              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      AppColors.primaryRed.withValues(alpha: auraOpacity),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final breathScale = _controller.value >= 0.25 &&
                        _controller.value <= 0.72
                    ? 1.0 + 0.02 * math.sin((_controller.value - 0.25) * math.pi * 4)
                    : 1.0;

                final totalScale = _badgeScaleAnimation.value * breathScale;
                final shimmerVal = _shimmerAnimation.value;
                final sparkVal = _sparkRippleAnimation.value;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 148,
                      height: 148,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(144, 144),
                            painter: SplashTachometerPainter(
                              arcProgress: _tachometerAnimation.value,
                              pulseValue: breathScale,
                              sparkRippleProgress: sparkVal,
                            ),
                          ),
                          Opacity(
                            opacity: _badgeFadeAnimation.value,
                            child: Transform.scale(
                              scale: totalScale,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(88 * 0.28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryRed.withValues(
                                              alpha: 0.28 +
                                                  0.08 * (breathScale - 1.0)),
                                          blurRadius: 28,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const AppLogo(
                                      size: 88,
                                      showBadge: true,
                                    ),
                                  ),
                                  if (shimmerVal > 0.0 && shimmerVal < 1.0)
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(88 * 0.28),
                                      child: SizedBox(
                                        width: 88,
                                        height: 88,
                                        child: Transform.translate(
                                          offset: Offset(
                                            -88 + (176 * shimmerVal),
                                            0,
                                          ),
                                          child: Container(
                                            width: 44,
                                            height: 88,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.white.withValues(
                                                      alpha: 0.38),
                                                  Colors.transparent,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Transform.translate(
                      offset: Offset(0, _textSlideAnimation.value),
                      child: Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: AppFonts.displayLarge(
                                  color: AppColors.textPrimaryLight,
                                ).copyWith(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.2,
                                ),
                                children: const [
                                  TextSpan(text: 'We'),
                                  TextSpan(
                                    text: 'Fix',
                                    style: TextStyle(
                                      color: AppColors.primaryRed,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Opacity(
                              opacity: _taglineFadeAnimation.value,
                              child: Text(
                                'VEHICLE SERVICE PLATFORM',
                                style: AppFonts.labelSmall(
                                  color: AppColors.textMutedLight,
                                ).copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing:
                                      _taglineTrackingAnimation.value,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: _revealAnimation,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: SplashRevealPainter(
                  progress: _revealAnimation.value,
                  revealColor: AppColors.primaryRed,
                  deepColor: AppColors.primaryRedDark,
                  glowColor: AppColors.primaryRedLight,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
