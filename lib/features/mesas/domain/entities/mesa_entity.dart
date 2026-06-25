import 'package:equatable/equatable.dart';

class MesaEntity extends Equatable {
  final String id;
  final String recintoId;
  final int numeroJrv;
  final String? veedorId;
  final String? veedorNombre;

  /// Numero de actas registradas (0, 1 o 2). Deriva el estado de la mesa.
  final int actasRegistradas;

  const MesaEntity({
    required this.id,
    required this.recintoId,
    required this.numeroJrv,
    this.veedorId,
    this.veedorNombre,
    this.actasRegistradas = 0,
  });

  bool get completa => actasRegistradas >= 2;
  bool get sinIniciar => actasRegistradas == 0;

  String get estadoLabel {
    if (completa) return 'Completa';
    if (sinIniciar) return 'Pendiente';
    return 'Parcial';
  }

  @override
  List<Object?> get props =>
      [id, recintoId, numeroJrv, veedorId, veedorNombre, actasRegistradas];
}
