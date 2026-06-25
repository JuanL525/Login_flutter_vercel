import 'package:injectable/injectable.dart';
import '../../../../core/db/app_database.dart';
import '../models/acta_model.dart';

abstract class ActasLocalDataSource {
  Future<List<ActaModel>> getActasByMesa(String mesaId);
  Future<void> upsertActa(ActaModel acta);
  Future<void> cacheActas(List<ActaModel> actas);
  Future<void> markSynced(String id, String? fotoPath);
}

@LazySingleton(as: ActasLocalDataSource)
class ActasLocalDataSourceImpl implements ActasLocalDataSource {
  final AppDatabase db;
  ActasLocalDataSourceImpl(this.db);

  @override
  Future<List<ActaModel>> getActasByMesa(String mesaId) async {
    final rows = await db.getActasByMesa(mesaId);
    return rows.map(ActaModel.fromDrift).toList();
  }

  @override
  Future<void> upsertActa(ActaModel acta) {
    return db.upsertActaLocal(acta.toCompanion());
  }

  @override
  Future<void> cacheActas(List<ActaModel> actas) async {
    for (final a in actas) {
      await db.upsertActaLocal(a.toCompanion());
    }
  }

  @override
  Future<void> markSynced(String id, String? fotoPath) {
    return db.markActaSynced(id, fotoPath);
  }
}
