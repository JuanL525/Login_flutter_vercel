// Enumeraciones compartidas del dominio (Dart puro).

enum UserRole {
  provincial,
  recinto,
  veedor;

  String get dbValue => name;

  static UserRole fromDb(String value) =>
      UserRole.values.firstWhere((e) => e.name == value);

  String get label {
    switch (this) {
      case UserRole.provincial:
        return 'Coordinador Provincial';
      case UserRole.recinto:
        return 'Coordinador de Recinto';
      case UserRole.veedor:
        return 'Veedor de Mesa';
    }
  }
}

enum Dignidad {
  alcalde,
  prefecto;

  String get dbValue => name;

  static Dignidad fromDb(String value) =>
      Dignidad.values.firstWhere((e) => e.name == value);

  String get label {
    switch (this) {
      case Dignidad.alcalde:
        return 'Alcalde';
      case Dignidad.prefecto:
        return 'Prefecto';
    }
  }
}

enum ActaStatus {
  pendiente,
  registrada,
  corregida;

  String get dbValue => name;

  static ActaStatus fromDb(String value) =>
      ActaStatus.values.firstWhere((e) => e.name == value);
}
