import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/mesa_entity.dart';
import '../../domain/repositories/mesas_repository.dart';
import '../datasources/mesas_remote_data_source.dart';

@LazySingleton(as: MesasRepository)
class MesasRepositoryImpl implements MesasRepository {
  final MesasRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MesasRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<MesaEntity>>> getMesasByRecinto(
    String recintoId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      return Right(await remoteDataSource.getMesasByRecinto(recintoId));
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, List<MesaEntity>>> getMesasByVeedor(
    String veedorId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexión a internet'));
    }
    try {
      return Right(await remoteDataSource.getMesasByVeedor(veedorId));
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, void>> assignVeedor({
    required String mesaId,
    required String? veedorId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      await remoteDataSource.assignVeedor(mesaId: mesaId, veedorId: veedorId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '').trim();
}
