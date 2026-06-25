import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/db/app_database.dart';
import 'core/services/connectivity_service.dart';
import 'features/actas/data/datasources/actas_remote_data_source.dart';
import 'features/sync/data/sync_service.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Inicializar Supabase.
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Dependencias externas.
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Inicializar injectable (registra el resto de dependencias).
  getIt.init();

  // SyncService se registra manualmente (ver nota en la clase).
  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      db: getIt<AppDatabase>(),
      remote: getIt<ActasRemoteDataSource>(),
      connectivity: getIt<ConnectivityService>(),
    ),
  );

  // Arrancar el servicio de sincronizacion offline.
  getIt<SyncService>().start();
}
