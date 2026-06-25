import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import '../../../../core/db/app_database.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../actas/data/datasources/actas_remote_data_source.dart';
import '../../actas/data/models/acta_model.dart';

/// Servicio de sincronizacion offline (patron Outbox).
///
/// Flujo:
///  - El veedor registra/corrige actas estando offline: se guardan en Drift
///    (actas_local) y se encola una operacion en la tabla `outbox`.
///  - Cuando vuelve la conectividad, [processOutbox] sube las operaciones
///    pendientes en orden FIFO.
///
/// Resolucion de conflictos: *last-write-wins por updated_at*. Antes de subir,
/// se compara el acta local con la remota: si la remota es mas reciente, se
/// descarta el cambio local (lo gana el servidor) y se elimina de la cola.
///
/// Se registra manualmente en `configureDependencies` (no via injectable) para
/// evitar un problema de resolucion del generador con la cadena actas<->sync.
class SyncService {
  final AppDatabase db;
  final ActasRemoteDataSource remote;
  final ConnectivityService connectivity;

  StreamSubscription<bool>? _sub;
  bool _processing = false;

  /// Numero de operaciones pendientes (para indicador en la UI).
  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  SyncService({
    required this.db,
    required this.remote,
    required this.connectivity,
  });

  void start() {
    _sub ??= connectivity.onStatusChanged.listen((online) {
      if (online) {
        processOutbox();
      }
    });
    _refreshPending();
    // Intento inicial.
    processOutbox();
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  /// Encola un acta para sincronizar y la guarda localmente.
  Future<void> enqueueActa(ActaModel acta) async {
    await db.upsertActaLocal(acta.toCompanion());
    await db.enqueue(
      OutboxCompanion(
        entity: const Value('acta'),
        operation: const Value('upsert'),
        entityId: Value(acta.id),
        payloadJson: Value(acta.toOutboxPayload()),
      ),
    );
    await _refreshPending();
    // Intentar sincronizar de inmediato si hay red.
    unawaited(processOutbox());
  }

  Future<void> _refreshPending() async {
    final pending = await db.pendingOutbox();
    pendingCount.value = pending.length;
  }

  Future<void> processOutbox() async {
    if (_processing) return;
    if (!await connectivity.isOnline) return;
    _processing = true;
    try {
      final pending = await db.pendingOutbox();
      for (final item in pending) {
        try {
          final local = ActaModel.fromOutboxPayload(item.payloadJson);

          // --- Resolucion de conflictos (last-write-wins) ---
          final remotas = await remote.getActasByMesa(local.mesaId);
          ActaModel? remota;
          for (final r in remotas) {
            if (r.dignidad == local.dignidad) {
              remota = r;
              break;
            }
          }
          if (remota != null && remota.updatedAt.isAfter(local.updatedAt)) {
            // El servidor tiene una version mas nueva: gana el servidor.
            await db.upsertActaLocal(remota.toCompanion());
            await db.removeOutbox(item.id);
            continue;
          }

          // --- Subida ---
          final pushed = await remote.pushActa(local);
          await db.markActaSynced(pushed.id, pushed.fotoPath);
          await db.removeOutbox(item.id);
        } catch (e) {
          await db.incrementAttempt(item.id, e.toString());
          // Continuar con los demas; se reintentara en el proximo ciclo.
        }
      }
    } finally {
      _processing = false;
      await _refreshPending();
    }
  }
}
