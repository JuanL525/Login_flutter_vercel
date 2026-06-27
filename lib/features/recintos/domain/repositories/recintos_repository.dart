import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/recinto_entity.dart';

abstract class RecintosRepository {
  Future<Either<Failure, List<RecintoEntity>>> getRecintos();

  Future<Either<Failure, RecintoEntity>> createRecinto({
    required String provincia,
    required String canton,
    required String parroquia,
    required String nombre,
    int cantidadMesas = 0,
  });

  Future<Either<Failure, RecintoEntity>> updateRecinto({
    required String id,
    required String provincia,
    required String canton,
    required String parroquia,
    required String nombre,
  });
}
