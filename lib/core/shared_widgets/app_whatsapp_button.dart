import 'package:flutter/material.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

enum WhatsAppButtonVariant { primary, outline, iconOnly }

class AppWhatsAppButton extends StatelessWidget {
  const AppWhatsAppButton({
    super.key,
    required this.phoneNumber,
    this.message,
    this.label = 'WhatsApp',
    this.variant = WhatsAppButtonVariant.primary,
    this.isFullWidth = false,
    this.height = 44,
    this.customOnPressed,
  });

  final String phoneNumber;
  final String? message;
  final String label;
  final WhatsAppButtonVariant variant;
  final bool isFullWidth;
  final double height;
  final VoidCallback? customOnPressed;

  static const Color whatsappGreen = Color(0xFF25D366);

  Future<void> _handleTap(BuildContext context) async {
    if (customOnPressed != null) {
      customOnPressed!();
      return;
    }
    final text = message ?? 'Hello!';
    final ok = await WhatsAppShareService.sendWhatsAppMessage(
      phoneNumber: phoneNumber,
      message: text,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open WhatsApp. Please check if app is installed.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (variant == WhatsAppButtonVariant.iconOnly) {
      return Material(
        color: whatsappGreen,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _handleTap(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.chat_bubble_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    final isOutline = variant == WhatsAppButtonVariant.outline;
    final bg = isOutline ? Colors.transparent : whatsappGreen;
    final fg = isOutline ? whatsappGreen : Colors.white;

    final button = Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOutline
            ? const BorderSide(color: whatsappGreen, width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_rounded, color: fg, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppFonts.labelLarge(color: fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
