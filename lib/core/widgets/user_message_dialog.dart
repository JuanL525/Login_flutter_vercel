import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'primary_button.dart';

enum UserMessageType { error, success, info, warning }

/// Dialogos de feedback visibles para el usuario (mas claros que un SnackBar).
class UserMessageDialog {
  UserMessageDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    UserMessageType type = UserMessageType.info,
    String buttonText = 'Entendido',
  }) {
    final (icon, color, bg) = switch (type) {
      UserMessageType.error => (
          Icons.error_outline_rounded,
          AppTheme.errorColor,
          const Color(0xFFFEE2E2),
        ),
      UserMessageType.success => (
          Icons.check_circle_outline_rounded,
          AppTheme.successColor,
          const Color(0xFFD1FAE5),
        ),
      UserMessageType.warning => (
          Icons.warning_amber_rounded,
          AppTheme.accentColor,
          const Color(0xFFFEF3C7),
        ),
      UserMessageType.info => (
          Icons.info_outline_rounded,
          AppTheme.primaryColor,
          const Color(0xFFEFF6FF),
        ),
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: type != UserMessageType.error,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: buttonText,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
  }) =>
      show(
        context,
        title: title,
        message: message,
        type: UserMessageType.error,
      );

  static Future<void> showSuccess(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Entendido',
  }) =>
      show(
        context,
        title: title,
        message: message,
        type: UserMessageType.success,
        buttonText: buttonText,
      );

  static Future<void> showWarning(
    BuildContext context, {
    required String title,
    required String message,
  }) =>
      show(
        context,
        title: title,
        message: message,
        type: UserMessageType.warning,
      );
}

/// Titulo sugerido segun el mensaje de error de autenticacion.
String authErrorTitle(String message) {
  final lower = message.toLowerCase();
  if ((lower.contains('cedula') || lower.contains('cédula')) &&
      lower.contains('no existe')) {
    return 'Cédula no registrada';
  }
  if (lower.contains('confirmar tu correo') ||
      lower.contains('correo electrónico antes') ||
      (lower.contains('correo') && lower.contains('confirm'))) {
    return 'Correo sin confirmar';
  }
  if (lower.contains('contrasena incorrecta') ||
      lower.contains('contraseña incorrecta') ||
      lower.contains('credenciales')) {
    return 'Contraseña incorrecta';
  }
  if (lower.contains('conexion') || lower.contains('conexión') ||
      lower.contains('internet')) {
    return 'Sin conexión';
  }
  return 'No se pudo completar';
}

/// Indica si el error de login es por correo aun no verificado.
bool authErrorIsUnconfirmedEmail(String message) {
  final lower = message.toLowerCase();
  return lower.contains('confirmar tu correo') ||
      lower.contains('correo electrónico antes') ||
      (lower.contains('correo') && lower.contains('confirm'));
}
