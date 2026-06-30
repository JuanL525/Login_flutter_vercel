import 'package:equatable/equatable.dart';
import '../../../recintos/domain/entities/recinto_entity.dart';

class RecintoAvance extends Equatable {
  final RecintoEntity recinto;
  final int totalMesas;

  /// Total de actas esperadas = totalMesas * 2 (alcalde + prefecto).
  final int actasRegistradas;
  final String? coordinadorNombre;
  final String? coordinadorCedula;

  const RecintoAvance({
    required this.recinto,
    required this.totalMesas,
    required this.actasRegistradas,
    this.coordinadorNombre,
    this.coordinadorCedula,
  });

  int get actasEsperadas => totalMesas * 2;
  double get porcentaje =>
      actasEsperadas == 0 ? 0 : actasRegistradas / actasEsperadas;

  @override
  List<Object?> get props =>
      [recinto, totalMesas, actasRegistradas, coordinadorNombre, coordinadorCedula];
}
