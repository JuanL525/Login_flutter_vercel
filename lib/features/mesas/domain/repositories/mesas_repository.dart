import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/mesa_entity.dart';

abstract class MesasRepository {
  Future<Either<Failure, List<MesaEntity>>> getMesasByRecinto(String recintoId);

  Future<Either<Failure, List<MesaEntity>>> getMesasByVeedor(String veedorId);

  /// Asigna o reasigna el veedor de una mesa (pasar null para liberar).
  Future<Either<Failure, void>> assignVeedor({
    required String mesaId,
    required String? veedorId,
  });
}
