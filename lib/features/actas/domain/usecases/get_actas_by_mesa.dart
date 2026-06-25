import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/acta_entity.dart';
import '../repositories/actas_repository.dart';

@injectable
class GetActasByMesa implements UseCase<List<ActaEntity>, String> {
  final ActasRepository repository;
  GetActasByMesa(this.repository);

  @override
  Future<Either<Failure, List<ActaEntity>>> call(String mesaId) {
    return repository.getActasByMesa(mesaId);
  }
}
