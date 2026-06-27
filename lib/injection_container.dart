import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/db/app_database.dart';
import 'core/services/connectivity_service.dart';
import 'features/actas/data/datasources/actas_remote_data_source.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_votos_consolidados.dart';
import 'features/dashboard/presentation/bloc/votos_bloc.dart';
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

  // Casos de uso y BLoC de votos consolidados (registro manual para evitar
  // re-generar injection_container.config.dart).
  getIt.registerFactory<GetVotosConsolidados>(
    () => GetVotosConsolidados(getIt<DashboardRepository>()),
  );
  getIt.registerFactory<VotosBloc>(
    () => VotosBloc(getVotosConsolidados: getIt<GetVotosConsolidados>()),
  );

  // Arrancar el servicio de sincronizacion offline.
  getIt<SyncService>().start();
}
