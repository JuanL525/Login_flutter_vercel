import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/session_entity.dart';

abstract class AuthRepository {
  /// Inicia sesion usando la cedula como nombre de usuario.
  Future<Either<Failure, SessionEntity>> signInWithCedula({
    required String cedula,
    required String password,
  });

  /// Envia el correo de restablecimiento de contrasena.
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});

  /// Cambia la contrasena del usuario actual y limpia must_change_password.
  Future<Either<Failure, SessionEntity>> changePassword({
    required String newPassword,
  });

  Future<Either<Failure, void>> signOut();

  /// Devuelve la sesion actual (con perfil) o null si no hay sesion.
  Future<Either<Failure, SessionEntity?>> getCurrentSession();
}
