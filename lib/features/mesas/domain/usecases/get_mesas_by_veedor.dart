import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/mesa_entity.dart';
import '../repositories/mesas_repository.dart';

@injectable
class GetMesasByVeedor implements UseCase<List<MesaEntity>, String> {
  final MesasRepository repository;
  GetMesasByVeedor(this.repository);

  @override
  Future<Either<Failure, List<MesaEntity>>> call(String veedorId) {
    return repository.getMesasByVeedor(veedorId);
  }
}
