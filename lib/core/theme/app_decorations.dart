import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Sombras, radios y contenedores reutilizables del design system Soft-UI.
class AppDecorations {
  AppDecorations._();

  static const double cardRadius = 24;
  static const double cardRadiusLarge = 32;
  static const double buttonRadius = 16;
  static const double inputRadius = 16;

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadowLight => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration softSurface({
    Color? color,
    double radius = cardRadius,
    bool bordered = false,
  }) {
    return BoxDecoration(
      color: color ?? AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: softShadow,
      border: bordered
          ? Border.all(color: AppTheme.borderColor)
          : null,
    );
  }

  static BoxDecoration floatingForm({double radius = cardRadiusLarge}) {
    return BoxDecoration(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: softShadow,
    );
  }
}
