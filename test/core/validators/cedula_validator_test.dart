import 'package:flutter_test/flutter_test.dart';
import 'package:login_pro/core/validators/cedula_validator.dart';

void main() {
  group('CedulaValidator', () {
    test('acepta cedulas validas', () {
      expect(CedulaValidator.isValid('1710034065'), isTrue);
      expect(CedulaValidator.isValid('1710034073'), isTrue);
      expect(CedulaValidator.isValid('1710034081'), isTrue);
    });

    test('rechaza longitud incorrecta', () {
      expect(CedulaValidator.isValid('17100340'), isFalse);
      expect(CedulaValidator.isValid('17100340655'), isFalse);
    });

    test('rechaza caracteres no numericos', () {
      expect(CedulaValidator.isValid('17100A4065'), isFalse);
    });

    test('rechaza provincia fuera de rango (01-24)', () {
      expect(CedulaValidator.isValid('0010034065'), isFalse);
      expect(CedulaValidator.isValid('2510034061'), isFalse);
    });

    test('rechaza digito verificador incorrecto', () {
      expect(CedulaValidator.isValid('1710034060'), isFalse);
      expect(CedulaValidator.isValid('1710034064'), isFalse);
    });

    test('validate devuelve mensajes adecuados', () {
      expect(CedulaValidator.validate(''), 'Ingrese la cedula');
      expect(CedulaValidator.validate('123'), 'La cedula debe tener 10 digitos');
      expect(CedulaValidator.validate('0010034065'), 'Provincia invalida (01-24)');
      expect(CedulaValidator.validate('1710034060'), 'La cedula no es valida');
      expect(CedulaValidator.validate('1710034065'), isNull);
    });
  });
}
