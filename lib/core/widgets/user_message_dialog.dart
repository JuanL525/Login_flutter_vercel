import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final (icon, color) = switch (type) {
      UserMessageType.error => (
          Icons.error_outline,
          theme.colorScheme.error,
        ),
      UserMessageType.success => (
          Icons.check_circle_outline,
          Colors.green.shade700,
        ),
      UserMessageType.warning => (
          Icons.warning_amber_outlined,
          Colors.orange.shade800,
        ),
      UserMessageType.info => (
          Icons.info_outline,
          theme.colorScheme.primary,
        ),
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: type != UserMessageType.error,
      builder: (ctx) => AlertDialog(
        icon: Icon(icon, color: color, size: 48),
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(buttonText),
          ),
        ],
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
  if (lower.contains('cedula') && lower.contains('no existe')) {
    return 'Cedula no registrada';
  }
  if (lower.contains('contrasena incorrecta') ||
      lower.contains('credenciales')) {
    return 'Contrasena incorrecta';
  }
  if (lower.contains('conexion') || lower.contains('internet')) {
    return 'Sin conexion';
  }
  if (lower.contains('correo') && lower.contains('confirm')) {
    return 'Correo sin confirmar';
  }
  return 'No se pudo completar';
}
