import 'package:flutter/material.dart';

class AppResponsiveLayout extends StatelessWidget {
  const AppResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = kMaxProjectWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  static const double kMaxDesktopViewportWidth = 1800;
  static const double kMaxProjectWidth = 920;
  static const double kMaxFormWidth = 760;
  static const double kMaxContentWidth = 960;
  static const double kMaxCompactWidth = 600;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 900;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
