import '../../../../core/constants/enums.dart';
import '../../../../core/seeds/organizaciones_seed.dart';

abstract class OrganizacionesRepository {
  List<OrganizacionPolitica> getByDignidad(Dignidad dignidad);
}
