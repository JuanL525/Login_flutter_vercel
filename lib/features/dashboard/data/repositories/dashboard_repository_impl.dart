import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/error/failures.dart';
import '../../../recintos/data/models/recinto_model.dart';
import '../../domain/entities/recinto_avance.dart';
import '../../domain/entities/votos_consolidados.dart';
import '../../domain/repositories/dashboard_repository.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient supabaseClient;
  DashboardRepositoryImpl(this.supabaseClient);

  @override
  Future<Either<Failure, List<RecintoAvance>>> getProvincialAvance() async {
    try {
      final recintosRows =
          await supabaseClient.from('recintos').select().order('parroquia');
      final mesasRows = await supabaseClient
          .from('mesas')
          .select('id, recinto_id, actas(count)');

      // Agregacion por recinto.
      final mesasPorRecinto = <String, int>{};
      final actasPorRecinto = <String, int>{};
      for (final m in (mesasRows as List)) {
        final map = m as Map<String, dynamic>;
        final recintoId = map['recinto_id'] as String;
        mesasPorRecinto[recintoId] = (mesasPorRecinto[recintoId] ?? 0) + 1;

        var actas = 0;
        final actasField = map['actas'];
        if (actasField is List && actasField.isNotEmpty) {
          final first = actasField.first;
          if (first is Map && first['count'] != null) {
            actas = (first['count'] as num).toInt();
          } else {
            actas = actasField.length;
          }
        }
        actasPorRecinto[recintoId] = (actasPorRecinto[recintoId] ?? 0) + actas;
      }

      final avances = (recintosRows as List).map((r) {
        final recinto = RecintoModel.fromMap(r as Map<String, dynamic>);
        return RecintoAvance(
          recinto: recinto,
          totalMesas: mesasPorRecinto[recinto.id] ?? 0,
          actasRegistradas: actasPorRecinto[recinto.id] ?? 0,
        );
      }).toList();

      return Right(avances);
    } catch (e) {
      return Left(
        ServerFailure(e.toString().replaceFirst('Exception: ', '').trim()),
      );
    }
  }

  @override
  Future<Either<Failure, List<VotosConsolidados>>> getVotosConsolidados() async {
    try {
      // Actas con votos + recinto anidado.
      final actasRows = await supabaseClient.from('actas').select(
            'dignidad, votos, votos_blancos, votos_nulos, total_sufragantes, '
            'mesas!inner(recinto_id, recintos!inner(nombre))',
          );

      // Total de mesas por recinto para calcular actas esperadas.
      final mesasRows = await supabaseClient
          .from('mesas')
          .select('recinto_id');
      final mesasPorRecinto = <String, int>{};
      for (final m in (mesasRows as List)) {
        final rid = m['recinto_id'] as String;
        mesasPorRecinto[rid] = (mesasPorRecinto[rid] ?? 0) + 1;
      }
      final totalMesas =
          mesasPorRecinto.values.fold(0, (a, b) => a + b);

      // Acumular votos por dignidad + recinto.
      final byDignidad = <String, Map<String, _RecintoAcum>>{};

      for (final row in (actasRows as List)) {
        final map = row as Map<String, dynamic>;
        final dignidad = map['dignidad'] as String;
        final votosRaw = map['votos'] as Map<String, dynamic>;
        final votos = votosRaw.map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        );
        final blancos = (map['votos_blancos'] as num? ?? 0).toInt();
        final nulos = (map['votos_nulos'] as num? ?? 0).toInt();
        final sufragantes = (map['total_sufragantes'] as num? ?? 0).toInt();

        final mesa = map['mesas'] as Map<String, dynamic>;
        final recintoId = mesa['recinto_id'] as String;
        final recinto = mesa['recintos'] as Map<String, dynamic>;
        final recintoNombre = recinto['nombre'] as String;

        byDignidad.putIfAbsent(dignidad, () => {});
        final rMap = byDignidad[dignidad]!;
        rMap.putIfAbsent(
          recintoId,
          () => _RecintoAcum(id: recintoId, nombre: recintoNombre),
        );
        rMap[recintoId]!.add(votos, blancos, nulos, sufragantes);
      }

      final result = <VotosConsolidados>[];
      for (final dignidad in Dignidad.values) {
        final key = dignidad.dbValue;
        final recintoMap = byDignidad[key] ?? {};

        final Map<String, int> totalPorOrg = {};
        var totalBlancos = 0;
        var totalNulos = 0;
        var totalSufragantes = 0;
        var actasContadas = 0;

        final porRecinto = <VotosRecintoDesglose>[];
        for (final rv in recintoMap.values) {
          for (final e in rv.votos.entries) {
            totalPorOrg[e.key] = (totalPorOrg[e.key] ?? 0) + e.value;
          }
          totalBlancos += rv.blancos;
          totalNulos += rv.nulos;
          totalSufragantes += rv.sufragantes;
          actasContadas += rv.actasContadas;

          final esperadasRecinto = mesasPorRecinto[rv.id] ?? 0;
          porRecinto.add(VotosRecintoDesglose(
            recintoId: rv.id,
            recintoNombre: rv.nombre,
            votosPorOrg: Map.from(rv.votos),
            blancos: rv.blancos,
            nulos: rv.nulos,
            sufragantes: rv.sufragantes,
            actasContadas: rv.actasContadas,
            actasEsperadas: esperadasRecinto,
          ));
        }

        porRecinto.sort((a, b) => a.recintoNombre.compareTo(b.recintoNombre));

        result.add(VotosConsolidados(
          dignidad: dignidad,
          totalPorOrg: totalPorOrg,
          totalBlancos: totalBlancos,
          totalNulos: totalNulos,
          totalSufragantes: totalSufragantes,
          actasContadas: actasContadas,
          actasEsperadas: totalMesas,
          porRecinto: porRecinto,
        ));
      }

      return Right(result);
    } catch (e) {
      return Left(
        ServerFailure(e.toString().replaceFirst('Exception: ', '').trim()),
      );
    }
  }
}

class _RecintoAcum {
  final String id;
  final String nombre;
  final Map<String, int> votos = {};
  int blancos = 0;
  int nulos = 0;
  int sufragantes = 0;
  int actasContadas = 0;

  _RecintoAcum({required this.id, required this.nombre});

  void add(Map<String, int> v, int b, int n, int s) {
    for (final e in v.entries) {
      votos[e.key] = (votos[e.key] ?? 0) + e.value;
    }
    blancos += b;
    nulos += n;
    sufragantes += s;
    actasContadas++;
  }
}
