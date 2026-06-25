import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/recinto_avance.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetProvincialAvance implements UseCase<List<RecintoAvance>, NoParams> {
  final DashboardRepository repository;
  GetProvincialAvance(this.repository);

  @override
  Future<Either<Failure, List<RecintoAvance>>> call(NoParams params) {
    return repository.getProvincialAvance();
  }
}
