import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../recintos/data/models/recinto_model.dart';
import '../../domain/entities/recinto_avance.dart';
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
}
