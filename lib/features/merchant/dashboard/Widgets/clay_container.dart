import 'package:flutter/material.dart';

class ClayContainer extends StatefulWidget {
  const ClayContainer({
    super.key,
    required this.child,
    this.borderRadius = 22.0,
    this.depth = 1.0,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.color,
    this.borderColor,
    this.onTap,
    this.enableHover = true,
  });

  final Widget child;
  final double borderRadius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool enableHover;

  @override
  State<ClayContainer> createState() => _ClayContainerState();
}

class _ClayContainerState extends State<ClayContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBaseColor = isDark
        ? const Color(0xFF141923)
        : const Color(0xFFFAFBFD);
    final surfaceColor = widget.color ?? defaultBaseColor;

    final defaultBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.85);
    final effectiveBorderColor = widget.borderColor ?? defaultBorder;

    final darkDepthShadow = BoxShadow(
      color: Colors.black.withValues(alpha: _isHovered ? 0.6 : 0.45),
      offset: Offset(4 * widget.depth, 6 * widget.depth),
      blurRadius: 14 * widget.depth,
      spreadRadius: -2,
    );
    final darkHighlightShadow = BoxShadow(
      color: Colors.white.withValues(alpha: 0.04),
      offset: Offset(-2 * widget.depth, -2 * widget.depth),
      blurRadius: 6 * widget.depth,
    );

    final lightDepthShadow = BoxShadow(
      color: const Color(0xFF94A3B8)
          .withValues(alpha: _isHovered ? 0.22 : 0.16),
      offset: Offset(5 * widget.depth, 7 * widget.depth),
      blurRadius: 16 * widget.depth,
      spreadRadius: -2,
    );
    final lightHighlightShadow = BoxShadow(
      color: Colors.white.withValues(alpha: 0.95),
      offset: Offset(-3 * widget.depth, -3 * widget.depth),
      blurRadius: 10 * widget.depth,
    );

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: effectiveBorderColor, width: 1.2),
        boxShadow: isDark
            ? [darkDepthShadow, darkHighlightShadow]
            : [lightDepthShadow, lightHighlightShadow],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      content = MouseRegion(
        onEnter: widget.enableHover
            ? (_) => setState(() => _isHovered = true)
            : null,
        onExit: widget.enableHover
            ? (_) => setState(() => _isHovered = false)
            : null,
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content;
  }
}
