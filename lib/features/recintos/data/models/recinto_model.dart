import '../../domain/entities/recinto_entity.dart';

class RecintoModel extends RecintoEntity {
  const RecintoModel({
    required super.id,
    required super.provincia,
    required super.canton,
    required super.parroquia,
    required super.nombre,
    super.coordinadorId,
  });

  factory RecintoModel.fromMap(Map<String, dynamic> map) {
    return RecintoModel(
      id: map['id'] as String,
      provincia: map['provincia'] as String,
      canton: map['canton'] as String,
      parroquia: map['parroquia'] as String,
      nombre: map['nombre'] as String,
      coordinadorId: map['coordinador_id'] as String?,
    );
  }

  Map<String, dynamic> toInsert() => {
        'provincia': provincia,
        'canton': canton,
        'parroquia': parroquia,
        'nombre': nombre,
      };
}
