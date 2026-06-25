import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/mesas_repository.dart';

@injectable
class AssignVeedor implements UseCase<void, AssignVeedorParams> {
  final MesasRepository repository;
  AssignVeedor(this.repository);

  @override
  Future<Either<Failure, void>> call(AssignVeedorParams params) {
    return repository.assignVeedor(
      mesaId: params.mesaId,
      veedorId: params.veedorId,
    );
  }
}

class AssignVeedorParams {
  final String mesaId;
  final String? veedorId;
  AssignVeedorParams({required this.mesaId, this.veedorId});
}
