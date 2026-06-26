import '../../../../core/usecase/usecase.dart';
import '../../../../injection_container.dart';
import '../../../recintos/domain/entities/recinto_entity.dart';
import '../../../recintos/domain/usecases/get_recintos.dart';

/// Resuelve datos de ubicacion (recinto/provincia) para el banner de identidad.
class IdentityContext {
  IdentityContext._();

  static Future<RecintoEntity?> recintoById(String? recintoId) async {
    if (recintoId == null) return null;
    final result = await getIt<GetRecintos>()(NoParams());
    return result.fold(
      (_) => null,
      (list) {
        for (final r in list) {
          if (r.id == recintoId) return r;
        }
        return null;
      },
    );
  }

  static Future<String?> provinciaFromRecintos() async {
    final result = await getIt<GetRecintos>()(NoParams());
    return result.fold(
      (_) => null,
      (list) {
        if (list.isEmpty) return null;
        final provincias = list.map((r) => r.provincia).toSet().toList()..sort();
        return provincias.join(', ');
      },
    );
  }
}
