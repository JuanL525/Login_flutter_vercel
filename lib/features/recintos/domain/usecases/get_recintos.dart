import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/recinto_entity.dart';
import '../repositories/recintos_repository.dart';

@injectable
class GetRecintos implements UseCase<List<RecintoEntity>, NoParams> {
  final RecintosRepository repository;
  GetRecintos(this.repository);

  @override
  Future<Either<Failure, List<RecintoEntity>>> call(NoParams params) {
    return repository.getRecintos();
  }
}
