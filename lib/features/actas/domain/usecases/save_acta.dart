import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/acta_entity.dart';
import '../repositories/actas_repository.dart';

@injectable
class SaveActa implements UseCase<ActaEntity, ActaEntity> {
  final ActasRepository repository;
  SaveActa(this.repository);

  @override
  Future<Either<Failure, ActaEntity>> call(ActaEntity acta) async {
    final error = validateVotos(acta);
    if (error != null) {
      return Left(ValidationFailure(error));
    }
    return repository.saveActa(acta);
  }

  /// Reglas: no puede haber mas votos que sufragantes; ningun candidato puede
  /// superar el total; los contabilizados no exceden el total.
  static String? validateVotos(ActaEntity acta) {
    if (acta.totalSufragantes <= 0) {
      return 'Ingrese el total de sufragantes';
    }
    if (acta.votosBlancos < 0 || acta.votosNulos < 0) {
      return 'Los votos no pueden ser negativos';
    }
    for (final entry in acta.votos.entries) {
      if (entry.value < 0) {
        return 'Los votos no pueden ser negativos';
      }
      if (entry.value > acta.totalSufragantes) {
        return 'Una organizacion tiene mas votos que el total de sufragantes';
      }
    }
    if (acta.votosContabilizados > acta.totalSufragantes) {
      return 'La suma de votos (${acta.votosContabilizados}) supera el total '
          'de sufragantes (${acta.totalSufragantes})';
    }
    if (acta.fotoLocalPath == null && acta.fotoPath == null) {
      return 'Debe adjuntar la foto del acta';
    }
    if (acta.gpsLat == null || acta.gpsLng == null) {
      return 'No se registraron las coordenadas GPS';
    }
    return null;
  }
}
