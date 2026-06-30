import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Etiqueta de seccion en mayusculas (design system).
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;

  const SectionLabel(this.text, {super.key, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: AppTheme.textSecondaryColor,
        ),
      ),
    );
  }
}
