import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

/// Servicio de conectividad de alto nivel: expone un stream booleano
/// (online/offline) usado por el SyncService para drenar el outbox.
@lazySingleton
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService(this._connectivity);

  Stream<bool> get onStatusChanged => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));

  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }
}
