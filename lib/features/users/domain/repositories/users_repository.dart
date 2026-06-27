import 'package:dartz/dartz.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract class UsersRepository {
  /// Crea una cuenta (coordinador de recinto o veedor) via Edge Function.
  Future<Either<Failure, void>> createUser({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole role,
    String? recintoId,
  });

  /// Lista los veedores de un recinto (para asignacion de mesas).
  Future<Either<Failure, List<ProfileEntity>>> getVeedoresByRecinto(
    String recintoId,
  );

  /// Lista los coordinadores de recinto sin recinto asignado.
  Future<Either<Failure, List<ProfileEntity>>> getCoordinadoresSinRecinto();

  /// Asigna un coordinador libre a un recinto que aun no tiene coordinador.
  Future<Either<Failure, void>> assignCoordinadorToRecinto({
    required String coordinadorId,
    required String recintoId,
  });
}
