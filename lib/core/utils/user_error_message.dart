import 'dart:convert';

/// Convierte errores técnicos (Supabase, Edge Functions, etc.) en mensajes
/// claros para el usuario final.
String humanizeError(Object error) {
  final functionStatus = _readFunctionExceptionStatus(error);
  if (functionStatus != null) {
    final fromDetails = _extractMessage(_readFunctionExceptionDetails(error));
    if (fromDetails != null) return fromDetails;
    return _messageForHttpStatus(functionStatus) ??
        'No se pudo completar la operación. Inténtalo de nuevo.';
  }

  var text = error.toString().trim();
  text = text.replaceFirst(RegExp(r'^Exception:\s*'), '');
  if (text.startsWith('FunctionException(')) {
    final fromDetails = _extractMessageFromFunctionExceptionString(text);
    if (fromDetails != null) return fromDetails;
    return 'No se pudo completar la operación. Inténtalo de nuevo.';
  }

  if (text.isEmpty) {
    return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
  }

  return _translateKnownMessage(text) ?? text;
}

int? _readFunctionExceptionStatus(Object error) {
  if (error.runtimeType.toString() != 'FunctionException') return null;
  final dynamic e = error;
  final status = e.status;
  return status is int ? status : null;
}

dynamic _readFunctionExceptionDetails(Object error) {
  if (error.runtimeType.toString() != 'FunctionException') return null;
  final dynamic e = error;
  return e.details;
}

/// Título sugerido para errores al crear una cuenta de usuario.
String createUserErrorTitle(String message) {
  final lower = message.toLowerCase();
  if (lower.contains('correo') &&
      (lower.contains('registrado') || lower.contains('en uso'))) {
    return 'Correo en uso';
  }
  if (lower.contains('cédula') &&
      (lower.contains('registrada') || lower.contains('en uso'))) {
    return 'Cédula en uso';
  }
  if (lower.contains('coordinador asignado') ||
      lower.contains('recinto ya tiene')) {
    return 'Recinto no disponible';
  }
  if (lower.contains('correo de verificación') ||
      lower.contains('enviar el correo')) {
    return 'Correo no enviado';
  }
  if (lower.contains('conexión') || lower.contains('internet')) {
    return 'Sin conexión';
  }
  if (lower.contains('permiso') || lower.contains('autenticado')) {
    return 'Sin permiso';
  }
  return 'No se pudo crear la cuenta';
}

String? _extractMessage(dynamic details) {
  if (details == null) return null;

  if (details is Map) {
    final raw = details['error'] ?? details['message'] ?? details['msg'];
    if (raw != null) {
      return _translateKnownMessage(raw.toString()) ?? raw.toString();
    }
    return null;
  }

  if (details is String) {
    final trimmed = details.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('{')) {
      try {
        final decoded = jsonDecode(trimmed);
        return _extractMessage(decoded);
      } catch (_) {
        // Continuar con el texto tal cual.
      }
    }
    return _translateKnownMessage(trimmed) ?? trimmed;
  }

  return _translateKnownMessage(details.toString()) ?? details.toString();
}

String? _extractMessageFromFunctionExceptionString(String text) {
  final detailsMatch = RegExp(r'details:\s*(.+),\s*reasonPhrase:')
      .firstMatch(text);
  if (detailsMatch == null) return null;
  return _extractMessage(detailsMatch.group(1));
}

String? _messageForHttpStatus(int status) {
  return switch (status) {
    401 => 'Tu sesión expiró. Cierra sesión e ingresa de nuevo.',
    403 => 'No tienes permiso para realizar esta acción.',
    404 => 'No se encontró el recurso solicitado.',
    409 => 'Los datos ingresados entran en conflicto con registros existentes.',
    429 => 'Demasiados intentos. Espera un momento e inténtalo de nuevo.',
    >= 500 => 'El servidor no pudo procesar la solicitud. Inténtalo más tarde.',
    _ => null,
  };
}

String? _translateKnownMessage(String raw) {
  final msg = raw.trim();
  if (msg.isEmpty) return null;

  final lower = msg.toLowerCase();

  const exact = {
    'faltan campos obligatorios':
        'Completa todos los campos obligatorios del formulario.',
    'la cedula ingresada no es valida':
        'La cédula ingresada no es válida. Verifica los 10 dígitos.',
    'el correo ya esta registrado':
        'Este correo electrónico ya está registrado. Usa otra dirección.',
    'la cedula ya esta registrada':
        'Esta cédula ya está registrada en el sistema.',
    'este recinto ya tiene un coordinador asignado':
        'Este recinto ya tiene un coordinador asignado. '
            'No puedes crear otro para el mismo recinto.',
    'debe asignar un recinto al coordinador':
        'Debes seleccionar un recinto para el coordinador.',
    'recinto no encontrado':
        'El recinto seleccionado no existe o ya no está disponible.',
    'no autenticado':
        'Tu sesión expiró. Cierra sesión e ingresa de nuevo.',
    'perfil del solicitante no encontrado':
        'No se pudo verificar tu perfil. Cierra sesión e ingresa de nuevo.',
    'rol sin permiso para crear usuarios':
        'Tu rol no tiene permiso para crear usuarios.',
    'el coordinador provincial solo crea coordinadores de recinto':
        'Como coordinador provincial solo puedes crear coordinadores de recinto.',
    'el coordinador de recinto solo crea veedores':
        'Como coordinador de recinto solo puedes crear veedores.',
    'json invalido':
        'Los datos enviados no son válidos. Revisa el formulario e inténtalo de nuevo.',
    'no se pudo crear el usuario':
        'No se pudo crear la cuenta. Revisa los datos e inténtalo de nuevo.',
  };

  for (final entry in exact.entries) {
    if (lower == entry.key || lower.contains(entry.key)) {
      return entry.value;
    }
  }

  if (lower.contains('usuario creado pero no se pudo enviar el correo')) {
    return 'La cuenta se creó, pero no pudimos enviar el correo de verificación. '
        'Revisa que el correo sea correcto e inténtalo de nuevo.';
  }

  if (lower.contains('user already registered') ||
      lower.contains('already been registered')) {
    return 'Este correo electrónico ya está registrado. Usa otra dirección.';
  }

  if (lower.contains('rate limit') || lower.contains('too many requests')) {
    return 'Demasiados intentos seguidos. Espera unos minutos e inténtalo de nuevo.';
  }

  if (lower.contains('invalid email') || lower.contains('unable to validate email')) {
    return 'El correo electrónico no es válido. Revisa que esté escrito correctamente.';
  }

  if (lower.contains('network') ||
      lower.contains('socket') ||
      lower.contains('failed host lookup')) {
    return 'Sin conexión a internet. Revisa tu red e inténtalo de nuevo.';
  }

  return null;
}
