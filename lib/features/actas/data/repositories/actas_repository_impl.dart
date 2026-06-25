import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../sync/data/sync_service.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/repositories/actas_repository.dart';
import '../datasources/actas_local_data_source.dart';
import '../datasources/actas_remote_data_source.dart';
import '../models/acta_model.dart';

@LazySingleton(as: ActasRepository)
class ActasRepositoryImpl implements ActasRepository {
  final ActasRemoteDataSource remoteDataSource;
  final ActasLocalDataSource localDataSource;
  final SyncService syncService;
  final NetworkInfo networkInfo;

  ActasRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.syncService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ActaEntity>>> getActasByMesa(
    String mesaId,
  ) async {
    // Estrategia offline-first: si hay red, refresca desde el backend y
    // actualiza el cache local; si no, devuelve lo guardado localmente.
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getActasByMesa(mesaId);
        await localDataSource.cacheActas(remote);
      } catch (_) {
        // Si falla la red, se cae al cache local.
      }
    }
    try {
      final local = await localDataSource.getActasByMesa(mesaId);
      return Right(local);
    } catch (e) {
      return Left(CacheFailure(_clean(e)));
    }
  }

  @override
  Future<Either<Failure, ActaEntity>> saveActa(ActaEntity acta) async {
    try {
      final model = ActaModel.fromEntity(acta);
      // Guarda local + encola sincronizacion (y la intenta si hay red).
      await syncService.enqueueActa(model);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(_clean(e)));
    }
  }

  @override
  Future<String?> getPhotoUrl(String path) {
    return remoteDataSource.getSignedPhotoUrl(path);
  }

  String _clean(Object e) =>
      e.toString().replaceFirst('Exception: ', '').trim();
}
