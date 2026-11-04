import 'package:flutter/material.dart';

class AppFlaticonIcon extends StatelessWidget {
  const AppFlaticonIcon({
    super.key,
    required this.url,
    required this.fallbackIcon,
    this.size = 22,
    this.color,
  });

  final String url;
  final IconData fallbackIcon;
  final double size;
  final Color? color;

  static const String chatUrl =
      'https://cdn-icons-png.flaticon.com/512/2950/2950625.png';
  static const String notificationUrl =
      'https://cdn-icons-png.flaticon.com/512/3602/3602145.png';

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Icon(fallbackIcon, size: size, color: color);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Icon(fallbackIcon, size: size, color: color);
      },
    );
  }
}
