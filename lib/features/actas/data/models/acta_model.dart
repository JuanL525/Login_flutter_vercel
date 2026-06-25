import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import '../../../../core/constants/enums.dart';
import '../../../../core/db/app_database.dart';
import '../../domain/entities/acta_entity.dart';

class ActaModel extends ActaEntity {
  const ActaModel({
    required super.id,
    required super.mesaId,
    required super.dignidad,
    required super.votos,
    required super.votosBlancos,
    required super.votosNulos,
    required super.totalSufragantes,
    super.fotoLocalPath,
    super.fotoPath,
    super.gpsLat,
    super.gpsLng,
    required super.status,
    required super.registradoPor,
    required super.updatedAt,
    super.synced,
  });

  factory ActaModel.fromEntity(ActaEntity e) => ActaModel(
        id: e.id,
        mesaId: e.mesaId,
        dignidad: e.dignidad,
        votos: e.votos,
        votosBlancos: e.votosBlancos,
        votosNulos: e.votosNulos,
        totalSufragantes: e.totalSufragantes,
        fotoLocalPath: e.fotoLocalPath,
        fotoPath: e.fotoPath,
        gpsLat: e.gpsLat,
        gpsLng: e.gpsLng,
        status: e.status,
        registradoPor: e.registradoPor,
        updatedAt: e.updatedAt,
        synced: e.synced,
      );

  /// Desde una fila remota de Supabase.
  factory ActaModel.fromMap(Map<String, dynamic> map) {
    final votosRaw = map['votos'];
    final votos = <String, int>{};
    if (votosRaw is Map) {
      votosRaw.forEach((k, v) => votos[k.toString()] = (v as num).toInt());
    }
    return ActaModel(
      id: map['id'] as String,
      mesaId: map['mesa_id'] as String,
      dignidad: Dignidad.fromDb(map['dignidad'] as String),
      votos: votos,
      votosBlancos: (map['votos_blancos'] as num?)?.toInt() ?? 0,
      votosNulos: (map['votos_nulos'] as num?)?.toInt() ?? 0,
      totalSufragantes: (map['total_sufragantes'] as num?)?.toInt() ?? 0,
      fotoPath: map['foto_path'] as String?,
      gpsLat: (map['gps_lat'] as num?)?.toDouble(),
      gpsLng: (map['gps_lng'] as num?)?.toDouble(),
      status: ActaStatus.fromDb(map['status'] as String? ?? 'registrada'),
      registradoPor: map['registrado_por'] as String,
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
              DateTime.now(),
      synced: true,
    );
  }

  /// Hacia Supabase (upsert).
  Map<String, dynamic> toRemoteMap() => {
        'id': id,
        'mesa_id': mesaId,
        'dignidad': dignidad.dbValue,
        'votos': votos,
        'votos_blancos': votosBlancos,
        'votos_nulos': votosNulos,
        'total_sufragantes': totalSufragantes,
        'foto_path': fotoPath,
        'gps_lat': gpsLat,
        'gps_lng': gpsLng,
        'status': status.dbValue,
        'registrado_por': registradoPor,
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Hacia Drift (cache local).
  ActasLocalCompanion toCompanion() => ActasLocalCompanion(
        id: Value(id),
        mesaId: Value(mesaId),
        dignidad: Value(dignidad.dbValue),
        votosJson: Value(jsonEncode(votos)),
        votosBlancos: Value(votosBlancos),
        votosNulos: Value(votosNulos),
        totalSufragantes: Value(totalSufragantes),
        fotoLocalPath: Value(fotoLocalPath),
        fotoPath: Value(fotoPath),
        gpsLat: Value(gpsLat),
        gpsLng: Value(gpsLng),
        status: Value(status.dbValue),
        registradoPor: Value(registradoPor),
        updatedAt: Value(updatedAt),
        synced: Value(synced),
      );

  /// Desde una fila de Drift.
  factory ActaModel.fromDrift(ActasLocalData d) {
    final votos = <String, int>{};
    final decoded = jsonDecode(d.votosJson);
    if (decoded is Map) {
      decoded.forEach((k, v) => votos[k.toString()] = (v as num).toInt());
    }
    return ActaModel(
      id: d.id,
      mesaId: d.mesaId,
      dignidad: Dignidad.fromDb(d.dignidad),
      votos: votos,
      votosBlancos: d.votosBlancos,
      votosNulos: d.votosNulos,
      totalSufragantes: d.totalSufragantes,
      fotoLocalPath: d.fotoLocalPath,
      fotoPath: d.fotoPath,
      gpsLat: d.gpsLat,
      gpsLng: d.gpsLng,
      status: ActaStatus.fromDb(d.status),
      registradoPor: d.registradoPor,
      updatedAt: d.updatedAt,
      synced: d.synced,
    );
  }

  /// Serializa para el payload del outbox.
  String toOutboxPayload() => jsonEncode({
        ...toRemoteMap(),
        'foto_local_path': fotoLocalPath,
      });

  static ActaModel fromOutboxPayload(String payload) {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    final model = ActaModel.fromMap(map);
    return ActaModel(
      id: model.id,
      mesaId: model.mesaId,
      dignidad: model.dignidad,
      votos: model.votos,
      votosBlancos: model.votosBlancos,
      votosNulos: model.votosNulos,
      totalSufragantes: model.totalSufragantes,
      fotoLocalPath: map['foto_local_path'] as String?,
      fotoPath: model.fotoPath,
      gpsLat: model.gpsLat,
      gpsLng: model.gpsLng,
      status: model.status,
      registradoPor: model.registradoPor,
      updatedAt: model.updatedAt,
      synced: false,
    );
  }
}
