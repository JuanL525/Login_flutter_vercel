import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/acta_entity.dart';

abstract class ActasRepository {
  Future<Either<Failure, List<ActaEntity>>> getActasByMesa(String mesaId);

  /// Guarda (registra o corrige) un acta. Funciona offline: persiste local
  /// y encola la sincronizacion.
  Future<Either<Failure, ActaEntity>> saveActa(ActaEntity acta);

  /// URL firmada para visualizar la foto remota.
  Future<String?> getPhotoUrl(String path);
}
