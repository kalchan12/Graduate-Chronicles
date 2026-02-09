import 'package:flutter/material.dart';
import '../../theme/design_system.dart';

enum ToastType { info, success, warning, error }

class ToastHelper {
  static void show(
    BuildContext context,
    String message, {
    ToastType? type,
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // Determine type based on isError if type is not provided
    final effectiveType = type ?? (isError ? ToastType.error : ToastType.info);

    // Color and Icon mapping
    final Color backgroundColor;
    final Color borderColor;
    final IconData icon;
    final Color iconColor;

    switch (effectiveType) {
      case ToastType.success:
        backgroundColor = const Color(0xFF1E362D).withValues(alpha: 0.95);
        borderColor = const Color(0xFF00FF9D).withValues(alpha: 0.3);
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF00FF9D);
        break;
      case ToastType.error:
        backgroundColor = const Color(0xFF361E1E).withValues(alpha: 0.95);
        borderColor = const Color(0xFFFF2C2C).withValues(alpha: 0.3);
        icon = Icons.error_outline_rounded;
        iconColor = const Color(0xFFFF2C2C);
        break;
      case ToastType.warning:
        backgroundColor = const Color(0xFF362D1E).withValues(alpha: 0.95);
        borderColor = const Color(0xFFFFB300).withValues(alpha: 0.3);
        icon = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFFFB300);
        break;
      case ToastType.info:
        backgroundColor = const Color(0xFF2E1A36).withValues(alpha: 0.95);
        borderColor = DesignSystem.purpleAccent.withValues(alpha: 0.3);
        icon = Icons.info_outline_rounded;
        iconColor = DesignSystem.purpleAccent;
        break;
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 30,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
