import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recinto_avance.dart';
import '../entities/votos_consolidados.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<RecintoAvance>>> getProvincialAvance();
  Future<Either<Failure, List<VotosConsolidados>>> getVotosConsolidados();
}
