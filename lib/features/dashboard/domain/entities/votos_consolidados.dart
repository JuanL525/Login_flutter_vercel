import 'package:equatable/equatable.dart';
import '../../../../core/constants/enums.dart';

/// Votos acumulados de un recinto para una dignidad concreta.
class VotosRecintoDesglose extends Equatable {
  final String recintoId;
  final String recintoNombre;

  /// Votos por organizacion: { orgId → cantidad }.
  final Map<String, int> votosPorOrg;
  final int blancos;
  final int nulos;
  final int sufragantes;
  final int actasContadas;
  final int actasEsperadas;

  const VotosRecintoDesglose({
    required this.recintoId,
    required this.recintoNombre,
    required this.votosPorOrg,
    required this.blancos,
    required this.nulos,
    required this.sufragantes,
    required this.actasContadas,
    required this.actasEsperadas,
  });

  double get porcentajeAvance =>
      actasEsperadas == 0 ? 0 : actasContadas / actasEsperadas;

  @override
  List<Object?> get props => [
        recintoId,
        votosPorOrg,
        blancos,
        nulos,
        sufragantes,
        actasContadas,
        actasEsperadas,
      ];
}

/// Consolidado global de votos para una dignidad (alcalde o prefecto).
class VotosConsolidados extends Equatable {
  final Dignidad dignidad;

  /// Votos totales por organizacion: { orgId → cantidad global }.
  final Map<String, int> totalPorOrg;
  final int totalBlancos;
  final int totalNulos;
  final int totalSufragantes;
  final int actasContadas;
  final int actasEsperadas;
  final List<VotosRecintoDesglose> porRecinto;

  const VotosConsolidados({
    required this.dignidad,
    required this.totalPorOrg,
    required this.totalBlancos,
    required this.totalNulos,
    required this.totalSufragantes,
    required this.actasContadas,
    required this.actasEsperadas,
    required this.porRecinto,
  });

  int votosOrg(String orgId) => totalPorOrg[orgId] ?? 0;

  int get totalVotosValidos =>
      totalPorOrg.values.fold(0, (a, b) => a + b);

  int get totalVotos => totalVotosValidos + totalBlancos + totalNulos;

  double porcentajeOrg(String orgId) =>
      totalVotos == 0 ? 0 : votosOrg(orgId) / totalVotos;

  double get porcentajeAvance =>
      actasEsperadas == 0 ? 0 : actasContadas / actasEsperadas;

  @override
  List<Object?> get props => [
        dignidad,
        totalPorOrg,
        totalBlancos,
        totalNulos,
        totalSufragantes,
        actasContadas,
        actasEsperadas,
        porRecinto,
      ];
}
