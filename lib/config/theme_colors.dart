import 'package:flutter/material.dart';

/// Theme-aware color palette. Call WealthColors.of(context) at the top of
/// every build() method and use these values instead of AppColors constants.
class WealthColors {
  final Color background;
  final Color card;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final bool isNeon;
  final bool isLight;

  const WealthColors._({
    required this.background,
    required this.card,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.isNeon,
    required this.isLight,
  });

  static WealthColors of(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final brightness = theme.brightness;
    final scaffoldBg = theme.scaffoldBackgroundColor;

    final isLight = brightness == Brightness.light;
    final isNeon = brightness == Brightness.dark &&
        scaffoldBg == const Color(0xFF08070F);

    if (isLight) {
      return WealthColors._(
        background: const Color(0xFFF5F7FA),
        card: Colors.white,
        surface: Colors.white,
        border: const Color(0xFFE5E7EB),
        textPrimary: const Color(0xFF0F1117),
        textSecondary: const Color(0xFF6B7280),
        primary: primary,
        isNeon: false,
        isLight: true,
      );
    }

    if (isNeon) {
      return WealthColors._(
        background: const Color(0xFF08070F),
        card: const Color(0xFF100F1A),
        surface: const Color(0xFF0D0C18),
        border: primary.withValues(alpha: 0.35),
        textPrimary: Colors.white,
        textSecondary: const Color(0xFF8A8F9E),
        primary: primary,
        isNeon: true,
        isLight: false,
      );
    }

    // Dark (default)
    return WealthColors._(
      background: const Color(0xFF0F1117),
      card: const Color(0xFF1E2026),
      surface: const Color(0xFF1E2028),
      border: const Color(0xFF2A2D35),
      textPrimary: Colors.white,
      textSecondary: const Color(0xFF8A8F9E),
      primary: primary,
      isNeon: false,
      isLight: false,
    );
  }

  /// Optional glow shadow for neon theme.
  List<BoxShadow>? glowShadow({double alpha = 0.15}) => isNeon
      ? [
          BoxShadow(
            color: primary.withValues(alpha: alpha),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ]
      : null;
}
