import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/recinto_entity.dart';
import '../repositories/recintos_repository.dart';

/// Crea o actualiza un recinto segun si [id] es null.
@injectable
class SaveRecinto implements UseCase<RecintoEntity, SaveRecintoParams> {
  final RecintosRepository repository;
  SaveRecinto(this.repository);

  @override
  Future<Either<Failure, RecintoEntity>> call(SaveRecintoParams params) {
    if (params.id == null) {
      return repository.createRecinto(
        provincia: params.provincia,
        canton: params.canton,
        parroquia: params.parroquia,
        nombre: params.nombre,
      );
    }
    return repository.updateRecinto(
      id: params.id!,
      provincia: params.provincia,
      canton: params.canton,
      parroquia: params.parroquia,
      nombre: params.nombre,
    );
  }
}

class SaveRecintoParams {
  final String? id;
  final String provincia;
  final String canton;
  final String parroquia;
  final String nombre;

  SaveRecintoParams({
    this.id,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.nombre,
  });
}
