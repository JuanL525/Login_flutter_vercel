import 'package:equatable/equatable.dart';

class RecintoEntity extends Equatable {
  final String id;
  final String provincia;
  final String canton;
  final String parroquia;
  final String nombre;
  final String? coordinadorId;

  const RecintoEntity({
    required this.id,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.nombre,
    this.coordinadorId,
  });

  @override
  List<Object?> get props =>
      [id, provincia, canton, parroquia, nombre, coordinadorId];
}
