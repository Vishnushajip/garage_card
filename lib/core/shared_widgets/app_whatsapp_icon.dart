import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppWhatsAppIcon extends StatelessWidget {
  const AppWhatsAppIcon({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  static const String _svgData =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">'
      '<path fill="currentColor" d="M12.04 2C6.58 2 2.13 6.45 2.13 11.91C2.13 13.66 2.59 15.36 3.45 16.86L2.05 22L7.3 20.62C8.75 21.41 10.38 21.83 12.04 21.83C17.5 21.83 21.95 17.38 21.95 11.92C21.95 9.27 20.92 6.78 19.05 4.91C17.18 3.03 14.69 2 12.04 2M12.05 3.67C14.25 3.67 16.31 4.53 17.87 6.09C19.42 7.65 20.28 9.72 20.28 11.92C20.28 16.46 16.58 20.15 12.04 20.15C10.56 20.15 9.11 19.76 7.85 19L7.55 18.83L4.43 19.65L5.26 16.61L5.06 16.29C4.24 14.99 3.8 13.47 3.8 11.91C3.81 7.37 7.5 3.67 12.05 3.67M9.16 6.77C9 6.77 8.8 6.77 8.62 6.77C8.42 6.78 8.16 6.85 7.94 7.09C7.72 7.33 7.1 7.91 7.1 9.09C7.1 10.27 7.96 11.41 8.08 11.57C8.2 11.73 9.73 14.08 12.08 15.09C12.64 15.33 13.08 15.48 13.42 15.59C13.98 15.77 14.49 15.74 14.89 15.68C15.34 15.61 16.27 15.11 16.46 14.56C16.66 14.02 16.66 13.56 16.6 13.46C16.54 13.36 16.39 13.3 16.16 13.19C15.93 13.08 14.81 12.53 14.6 12.45C14.39 12.37 14.24 12.33 14.09 12.56C13.94 12.79 13.51 13.3 13.38 13.46C13.25 13.62 13.12 13.64 12.89 13.53C12.66 13.41 11.92 13.17 11.04 12.39C10.36 11.78 9.9 11.03 9.77 10.81C9.64 10.59 9.76 10.47 9.87 10.36C9.97 10.26 10.1 10.09 10.22 9.95C10.34 9.81 10.38 9.71 10.46 9.55C10.54 9.39 10.5 9.25 10.44 9.13C10.38 9.01 9.95 7.95 9.77 7.52C9.6 7.1 9.42 7.16 9.28 7.15C9.15 7.15 9 7.15 8.87 7.15"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? const Color(0xFF25D366);
    return SvgPicture.string(
      _svgData,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
