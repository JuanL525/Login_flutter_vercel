/// Validador de cedula ecuatoriana (algoritmo modulo 10).
///
/// Dart puro: no depende de Flutter ni librerias externas (regla de Domain).
///
/// Pasos:
///  1. Longitud exacta de 10 digitos y provincia (2 primeros) entre 01 y 24.
///  2. Posiciones impares (1,3,5,7,9) x2; si el producto > 9 se le resta 9.
///  3. Posiciones pares (2,4,6,8) se suman tal cual.
///  4. Suma total = paso 2 + paso 3.
///  5. Decena superior inmediata de la suma total.
///  6. Digito verificador = decena superior - suma total (si da 10 -> 0),
///     debe coincidir con el decimo digito.
class CedulaValidator {
  const CedulaValidator._();

  static bool isValid(String cedula) {
    if (cedula.length != 10) return false;
    if (int.tryParse(cedula) == null) return false;

    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;

    var sumaImpares = 0;
    for (var i = 0; i < 9; i += 2) {
      var producto = int.parse(cedula[i]) * 2;
      if (producto > 9) producto -= 9;
      sumaImpares += producto;
    }

    var sumaPares = 0;
    for (var i = 1; i < 9; i += 2) {
      sumaPares += int.parse(cedula[i]);
    }

    final total = sumaImpares + sumaPares;
    final decenaSuperior = ((total + 9) ~/ 10) * 10;
    final verificador = (decenaSuperior - total) % 10;

    return verificador == int.parse(cedula[9]);
  }

  /// Devuelve un mensaje de error legible o `null` si la cedula es valida.
  /// Util para usar como validator de un TextFormField.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese la cedula';
    }
    if (value.length != 10 || int.tryParse(value) == null) {
      return 'La cedula debe tener 10 digitos';
    }
    final provincia = int.parse(value.substring(0, 2));
    if (provincia < 1 || provincia > 24) {
      return 'Provincia invalida (01-24)';
    }
    if (!isValid(value)) {
      return 'La cedula no es valida';
    }
    return null;
  }
}
