import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/repositories/recintos_repository.dart';
import '../datasources/recintos_remote_data_source.dart';
import '../models/recinto_model.dart';

@LazySingleton(as: RecintosRepository)
class RecintosRepositoryImpl implements RecintosRepository {
  final RecintosRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RecintosRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<RecintoEntity>>> getRecintos() async {
    try {
      final list = await remoteDataSource.getRecintos();
      return Right(list);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, RecintoEntity>> createRecinto({
    required String provincia,
    required String canton,
    required String parroquia,
    required String nombre,
    int cantidadMesas = 0,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      final created = await remoteDataSource.createRecinto(
        RecintoModel(
          id: '',
          provincia: provincia,
          canton: canton,
          parroquia: parroquia,
          nombre: nombre,
        ),
        cantidadMesas: cantidadMesas,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, RecintoEntity>> updateRecinto({
    required String id,
    required String provincia,
    required String canton,
    required String parroquia,
    required String nombre,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('Sin conexion a internet'));
    }
    try {
      final updated = await remoteDataSource.updateRecinto(
        RecintoModel(
          id: id,
          provincia: provincia,
          canton: canton,
          parroquia: parroquia,
          nombre: nombre,
        ),
      );
      return Right(updated);
    } catch (e) {
      return Left(ServerFailure(_clean(e)));
    }
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '').trim();
}
