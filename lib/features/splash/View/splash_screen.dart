import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:garage_card/core/platform/web_boot.dart';
import 'package:garage_card/core/routing/route_paths.dart';
import 'package:garage_card/features/authentication/Model/auth_state.dart';
import 'package:garage_card/features/authentication/ViewModel/auth_view_model.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _rippleController;
  late final Animation<double> _cornerAnim;
  late final Animation<double> _fillScaleAnim;
  late final Animation<double> _logoPopAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _subtitleAnim;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _cornerAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );

    _fillScaleAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.1, 0.55, curve: Curves.easeOutCubic),
    );

    _logoPopAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.25, 0.72, curve: Curves.easeOutBack),
    );

    _titleAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
    );

    _subtitleAnim = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.62, 1.0, curve: Curves.easeOutCubic),
    );

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToTarget();
      }
    });

    _mainController.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_hasNavigated) {
        _navigateToTarget();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations && !_hasNavigated) {
      _mainController.value = 1.0;
      _navigateToTarget();
    }
  }

  void _navigateToTarget() {
    if (_hasNavigated || !mounted) return;

    final authState = ref.read(authViewModelProvider);
    if (!authState.isInitialized) {
      return;
    }
    _hasNavigated = true;

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
    _rippleController.dispose();
    _mainController.dispose();
    super.dispose();
  }

  Widget _buildRippleRing(double offset, Color color) {
    final t = (_rippleController.value + offset) % 1.0;
    final scale = 0.75 + 1.35 * t;
    final opacity = (t < 0.15 ? (t / 0.15 * 0.55) : (0.55 * (1.0 - t) / 0.85))
        .clamp(0.0, 0.55);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: opacity), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WebBoot.appReady();
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isInitialized && _mainController.isCompleted && !_hasNavigated) {
        _navigateToTarget();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _cornerAnim,
            builder: (context, _) {
              return CustomPaint(
                painter: _SplashCornersPainter(progress: _cornerAnim.value),
                size: Size.infinite,
              );
            },
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.08),
                radius: 0.72,
                colors: [
                  Color(0xF5FFFFFF),
                  Color(0xD1FFFFFF),
                  Color(0x00FFFFFF),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 128,
                    height: 128,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _rippleController,
                          builder: (context, _) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                _buildRippleRing(0.0, const Color(0xFFDC2626)),
                                _buildRippleRing(0.33, const Color(0xFFEF4444)),
                                _buildRippleRing(0.66, const Color(0xFFB91C1C)),
                              ],
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _fillScaleAnim,
                          builder: (context, _) {
                            final scale = _fillScaleAnim.value;
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFDC2626),
                                      Color(0xFFB91C1C),
                                    ],
                                    stops: [0.0, 0.55, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x61DC2626),
                                      blurRadius: 44,
                                      offset: Offset(0, 18),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _logoPopAnim,
                          builder: (context, _) {
                            final scale = (0.4 + 0.6 * _logoPopAnim.value)
                                .clamp(0.0, 1.05);
                            final opacity = _logoPopAnim.value.clamp(0.0, 1.0);
                            return Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(26),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xF2FEE2E2),
                                        spreadRadius: 6,
                                      ),
                                      BoxShadow(
                                        color: Color(0x2EDC2626),
                                        spreadRadius: 7,
                                      ),
                                      BoxShadow(
                                        color: Color(0x52B91C1C),
                                        blurRadius: 34,
                                        offset: Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: Image.asset(
                                      'assets/branding/wefix_logo_120x120.png',
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedBuilder(
                    animation: _titleAnim,
                    builder: (context, _) {
                      final scale = (0.92 + 0.08 * _titleAnim.value).clamp(
                        0.0,
                        1.0,
                      );
                      final opacity = _titleAnim.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.9,
                                height: 1.1,
                                color: Color(0xFF0F172A),
                              ),
                              children: [
                                TextSpan(text: 'We'),
                                TextSpan(
                                  text: 'Fix',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _subtitleAnim,
                    builder: (context, _) {
                      final scale = (0.94 + 0.06 * _subtitleAnim.value).clamp(
                        0.0,
                        1.0,
                      );
                      final opacity = _subtitleAnim.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Smarter Garage Management',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashCornersPainter extends CustomPainter {
  const _SplashCornersPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final maxDim = math.max(size.width, size.height);
    final radius = maxDim * 0.70;
    final scale = progress.clamp(0.0, 1.0);
    final alpha = (0.35 * scale).clamp(0.0, 1.0);

    const stops = [0.0, 0.28, 0.52, 0.70];

    final paintTl = Paint()
      ..shader = ui.Gradient.radial(Offset.zero, radius * scale, [
        const Color(0xFFEF4444).withValues(alpha: alpha),
        const Color(0xFFEF4444).withValues(alpha: alpha * 0.55),
        const Color(0xFFFEE2E2).withValues(alpha: alpha * 0.3),
        const Color(0x00FEE2E2),
      ], stops);
    canvas.drawCircle(Offset.zero, radius * scale, paintTl);

    final trOffset = Offset(size.width, 0);
    final paintTr = Paint()
      ..shader = ui.Gradient.radial(trOffset, radius * scale, [
        const Color(0xFFDC2626).withValues(alpha: alpha),
        const Color(0xFFDC2626).withValues(alpha: alpha * 0.5),
        const Color(0xFFFEE2E2).withValues(alpha: alpha * 0.3),
        const Color(0x00FEE2E2),
      ], stops);
    canvas.drawCircle(trOffset, radius * scale, paintTr);

    final blOffset = Offset(0, size.height);
    final paintBl = Paint()
      ..shader = ui.Gradient.radial(blOffset, radius * scale, [
        const Color(0xFFB91C1C).withValues(alpha: alpha),
        const Color(0xFFB91C1C).withValues(alpha: alpha * 0.5),
        const Color(0xFFFEE2E2).withValues(alpha: alpha * 0.3),
        const Color(0x00FEE2E2),
      ], stops);
    canvas.drawCircle(blOffset, radius * scale, paintBl);

    final brOffset = Offset(size.width, size.height);
    final paintBr = Paint()
      ..shader = ui.Gradient.radial(brOffset, radius * scale, [
        const Color(0xFFEF4444).withValues(alpha: alpha),
        const Color(0xFFEF4444).withValues(alpha: alpha * 0.55),
        const Color(0xFFFEE2E2).withValues(alpha: alpha * 0.3),
        const Color(0x00FEE2E2),
      ], stops);
    canvas.drawCircle(brOffset, radius * scale, paintBr);
  }

  @override
  bool shouldRepaint(covariant _SplashCornersPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
