import 'package:injectable/injectable.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/seeds/organizaciones_seed.dart';
import '../../domain/repositories/organizaciones_repository.dart';

/// Implementacion en memoria: las organizaciones politicas son datos quemados.
@LazySingleton(as: OrganizacionesRepository)
class OrganizacionesRepositoryImpl implements OrganizacionesRepository {
  @override
  List<OrganizacionPolitica> getByDignidad(Dignidad dignidad) {
    return organizacionesPorDignidad(dignidad);
  }
}
