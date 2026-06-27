import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/votos_consolidados.dart';
import '../repositories/dashboard_repository.dart';

class GetVotosConsolidados implements UseCase<List<VotosConsolidados>, NoParams> {
  final DashboardRepository repository;
  GetVotosConsolidados(this.repository);

  @override
  Future<Either<Failure, List<VotosConsolidados>>> call(NoParams params) {
    return repository.getVotosConsolidados();
  }
}
