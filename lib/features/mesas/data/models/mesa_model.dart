import '../../domain/entities/mesa_entity.dart';

class MesaModel extends MesaEntity {
  const MesaModel({
    required super.id,
    required super.recintoId,
    required super.numeroJrv,
    super.veedorId,
    super.veedorNombre,
    super.actasRegistradas,
  });

  factory MesaModel.fromMap(Map<String, dynamic> map) {
    // actas puede venir como [{count: n}] cuando se pide el agregado.
    var actasCount = 0;
    final actas = map['actas'];
    if (actas is List && actas.isNotEmpty) {
      final first = actas.first;
      if (first is Map && first['count'] != null) {
        actasCount = (first['count'] as num).toInt();
      } else {
        actasCount = actas.length;
      }
    }

    String? veedorNombre;
    final veedor = map['veedor'];
    if (veedor is Map) {
      veedorNombre = '${veedor['nombres']} ${veedor['apellidos']}';
    }

    return MesaModel(
      id: map['id'] as String,
      recintoId: map['recinto_id'] as String,
      numeroJrv: (map['numero_jrv'] as num).toInt(),
      veedorId: map['veedor_id'] as String?,
      veedorNombre: veedorNombre,
      actasRegistradas: actasCount,
    );
  }
}
