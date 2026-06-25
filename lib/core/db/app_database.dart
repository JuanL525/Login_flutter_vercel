import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:injectable/injectable.dart';

part 'app_database.g.dart';

/// Espejo local de actas para el flujo offline del veedor.
class ActasLocal extends Table {
  TextColumn get id => text()();
  TextColumn get mesaId => text()();
  TextColumn get dignidad => text()();
  TextColumn get votosJson => text().withDefault(const Constant('{}'))();
  IntColumn get votosBlancos => integer().withDefault(const Constant(0))();
  IntColumn get votosNulos => integer().withDefault(const Constant(0))();
  IntColumn get totalSufragantes => integer().withDefault(const Constant(0))();
  TextColumn get fotoLocalPath => text().nullable()();
  TextColumn get fotoPath => text().nullable()();
  RealColumn get gpsLat => real().nullable()();
  RealColumn get gpsLng => real().nullable()();
  TextColumn get status => text().withDefault(const Constant('registrada'))();
  TextColumn get registradoPor => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cola de operaciones pendientes de sincronizar (patron Outbox).
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()(); // 'acta'
  TextColumn get operation => text()(); // 'upsert'
  TextColumn get entityId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

@DriftDatabase(tables: [ActasLocal, Outbox])
@lazySingleton
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _open() {
    return driftDatabase(name: 'control_electoral');
  }

  // ----- Actas locales -----
  Future<List<ActasLocalData>> getActasByMesa(String mesaId) {
    return (select(actasLocal)..where((t) => t.mesaId.equals(mesaId))).get();
  }

  Future<ActasLocalData?> getActaByMesaDignidad(
    String mesaId,
    String dignidad,
  ) {
    return (select(actasLocal)
          ..where((t) => t.mesaId.equals(mesaId) & t.dignidad.equals(dignidad)))
        .getSingleOrNull();
  }

  Future<void> upsertActaLocal(ActasLocalCompanion acta) {
    return into(actasLocal).insertOnConflictUpdate(acta);
  }

  Future<void> markActaSynced(String id, String? fotoPath) {
    return (update(actasLocal)..where((t) => t.id.equals(id))).write(
      ActasLocalCompanion(
        synced: const Value(true),
        fotoPath: Value(fotoPath),
      ),
    );
  }

  // ----- Outbox -----
  Future<int> enqueue(OutboxCompanion item) => into(outbox).insert(item);

  Future<List<OutboxData>> pendingOutbox() {
    return (select(outbox)..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> removeOutbox(int id) {
    return (delete(outbox)..where((t) => t.id.equals(id))).go();
  }

  Future<void> incrementAttempt(int id, String error) async {
    await customUpdate(
      'UPDATE outbox SET attempts = attempts + 1, last_error = ? WHERE id = ?',
      variables: [Variable.withString(error), Variable.withInt(id)],
      updates: {outbox},
    );
  }
}
