import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, SessionEntity>> signInWithCedula({
    required String cedula,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      final profile = await remoteDataSource.signInWithCedula(
        cedula: cedula,
        password: password,
      );
      return Right(SessionEntity(profile: profile));
    } catch (e) {
      return Left(AuthFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, SessionEntity>> changePassword({
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      final profile = await remoteDataSource.changePassword(
        newPassword: newPassword,
      );
      return Right(SessionEntity(profile: profile));
    } catch (e) {
      return Left(AuthFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, SessionEntity?>> getCurrentSession() async {
    try {
      final profile = await remoteDataSource.getCurrentProfile();
      if (profile == null) return const Right(null);
      return Right(SessionEntity(profile: profile));
    } catch (e) {
      return Left(AuthFailure(_clean(e)));
    }
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '').trim();
}
