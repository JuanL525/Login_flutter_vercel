import 'package:equatable/equatable.dart';
import '../../../../core/constants/enums.dart';

class ActaEntity extends Equatable {
  final String id;
  final String mesaId;
  final Dignidad dignidad;

  /// Votos por organizacion: { organizacionId: cantidad }.
  final Map<String, int> votos;
  final int votosBlancos;
  final int votosNulos;
  final int totalSufragantes;

  /// Ruta local de la foto (antes de subir) y ruta remota en Storage.
  final String? fotoLocalPath;
  final String? fotoPath;

  final double? gpsLat;
  final double? gpsLng;

  final ActaStatus status;
  final String registradoPor;
  final DateTime updatedAt;

  /// Indica si el registro ya esta sincronizado con el backend.
  final bool synced;

  const ActaEntity({
    required this.id,
    required this.mesaId,
    required this.dignidad,
    required this.votos,
    required this.votosBlancos,
    required this.votosNulos,
    required this.totalSufragantes,
    this.fotoLocalPath,
    this.fotoPath,
    this.gpsLat,
    this.gpsLng,
    required this.status,
    required this.registradoPor,
    required this.updatedAt,
    this.synced = false,
  });

  int get votosContabilizados =>
      votos.values.fold(0, (a, b) => a + b) + votosBlancos + votosNulos;

  @override
  List<Object?> get props => [
        id,
        mesaId,
        dignidad,
        votos,
        votosBlancos,
        votosNulos,
        totalSufragantes,
        fotoLocalPath,
        fotoPath,
        gpsLat,
        gpsLng,
        status,
        registradoPor,
        updatedAt,
        synced,
      ];
}
