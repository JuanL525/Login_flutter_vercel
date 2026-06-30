import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppStatusType { success, warning, info, error, neutral }

/// Etiqueta redondeada con colores pastel segun estado.
class StatusChip extends StatelessWidget {
  final String label;
  final AppStatusType type;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.type = AppStatusType.neutral,
    this.icon,
  });

  (Color bg, Color fg) get _colors => switch (type) {
        AppStatusType.success => (
            const Color(0xFFD1FAE5),
            const Color(0xFF065F46),
          ),
        AppStatusType.warning => (
            const Color(0xFFFEF3C7),
            const Color(0xFF92400E),
          ),
        AppStatusType.info => (
            const Color(0xFFDBEAFE),
            const Color(0xFF1E40AF),
          ),
        AppStatusType.error => (
            const Color(0xFFFEE2E2),
            const Color(0xFF991B1B),
          ),
        AppStatusType.neutral => (
            AppTheme.borderColor,
            AppTheme.textSecondaryColor,
          ),
      };

  static AppStatusType forMesa({required bool completa, required bool sinIniciar}) {
    if (completa) return AppStatusType.success;
    if (sinIniciar) return AppStatusType.warning;
    return AppStatusType.info;
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
