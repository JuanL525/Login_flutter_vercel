import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_remote_data_source.dart';

@LazySingleton(as: UsersRepository)
class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UsersRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> createUser({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
    required UserRole role,
    String? recintoId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      await remoteDataSource.createUser(
        cedula: cedula,
        nombres: nombres,
        apellidos: apellidos,
        telefono: telefono,
        email: email,
        role: role,
        recintoId: recintoId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> getVeedoresByRecinto(
    String recintoId,
  ) async {
    try {
      final list = await remoteDataSource.getVeedoresByRecinto(recintoId);
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, List<ProfileEntity>>> getCoordinadoresSinRecinto() async {
    try {
      final list = await remoteDataSource.getCoordinadoresSinRecinto();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, void>> assignCoordinadorToRecinto({
    required String coordinadorId,
    required String recintoId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      await remoteDataSource.assignCoordinadorToRecinto(
        coordinadorId: coordinadorId,
        recintoId: recintoId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  String _clean(Object e) => humanizeError(e);
}
