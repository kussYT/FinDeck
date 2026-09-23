import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Espacements partagés par le thème provisoire.
///
/// L'échelle reste volontairement courte : les écrans du socle s'en servent
/// pour rester alignés avant la charte graphique définitive.
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  static const standard = AppSpacing(
    xs: 4,
    sm: 8,
    md: 16,
    lg: 24,
    xl: 32,
  );

  @override
  AppSpacing copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }

    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
    );
  }
}

/// Thème clair provisoire, sobre, sans signal financier.
abstract final class AppTheme {
  static const Color _ink = Color(0xFF1C2430);
  static const Color _canvas = Color(0xFFF3F5F7);
  static const Color _seed = Color(0xFF1F4E5F);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    const textTheme = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: _ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: _ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _canvas,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurfaceVariant,
        displayColor: _ink,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: const MaterialStatePropertyAll(
          TextStyle(
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      extensions: const [AppSpacing.standard],
    );
  }
}
