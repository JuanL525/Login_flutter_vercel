// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:login_pro/core/db/app_database.dart' as _i162;
import 'package:login_pro/core/network/network_info.dart' as _i505;
import 'package:login_pro/core/services/blur_detector.dart' as _i591;
import 'package:login_pro/core/services/connectivity_service.dart' as _i1056;
import 'package:login_pro/core/services/gps_service.dart' as _i780;
import 'package:login_pro/core/services/photo_capture_service.dart' as _i328;
import 'package:login_pro/features/actas/data/datasources/actas_local_data_source.dart'
    as _i61;
import 'package:login_pro/features/actas/data/datasources/actas_remote_data_source.dart'
    as _i762;
import 'package:login_pro/features/actas/data/repositories/actas_repository_impl.dart'
    as _i1053;
import 'package:login_pro/features/actas/domain/repositories/actas_repository.dart'
    as _i1005;
import 'package:login_pro/features/actas/domain/usecases/get_actas_by_mesa.dart'
    as _i948;
import 'package:login_pro/features/actas/domain/usecases/get_photo_url.dart'
    as _i173;
import 'package:login_pro/features/actas/domain/usecases/save_acta.dart'
    as _i328;
import 'package:login_pro/features/actas/presentation/bloc/actas_bloc.dart'
    as _i540;
import 'package:login_pro/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i383;
import 'package:login_pro/features/auth/data/repositories/auth_repository_impl.dart'
    as _i12;
import 'package:login_pro/features/auth/domain/repositories/auth_repository.dart'
    as _i638;
import 'package:login_pro/features/auth/domain/usecases/change_password.dart'
    as _i340;
import 'package:login_pro/features/auth/domain/usecases/get_current_session.dart'
    as _i314;
import 'package:login_pro/features/auth/domain/usecases/reset_password.dart'
    as _i1002;
import 'package:login_pro/features/auth/domain/usecases/sign_in.dart' as _i1051;
import 'package:login_pro/features/auth/domain/usecases/sign_out.dart' as _i427;
import 'package:login_pro/features/auth/presentation/bloc/auth_bloc.dart'
    as _i746;
import 'package:login_pro/features/dashboard/data/repositories/dashboard_repository_impl.dart'
    as _i300;
import 'package:login_pro/features/dashboard/domain/repositories/dashboard_repository.dart'
    as _i120;
import 'package:login_pro/features/dashboard/domain/usecases/get_provincial_avance.dart'
    as _i864;
import 'package:login_pro/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i361;
import 'package:login_pro/features/mesas/data/datasources/mesas_remote_data_source.dart'
    as _i658;
import 'package:login_pro/features/mesas/data/repositories/mesas_repository_impl.dart'
    as _i1059;
import 'package:login_pro/features/mesas/domain/repositories/mesas_repository.dart'
    as _i701;
import 'package:login_pro/features/mesas/domain/usecases/assign_veedor.dart'
    as _i308;
import 'package:login_pro/features/mesas/domain/usecases/get_mesas_by_recinto.dart'
    as _i79;
import 'package:login_pro/features/mesas/domain/usecases/get_mesas_by_veedor.dart'
    as _i612;
import 'package:login_pro/features/mesas/presentation/bloc/mesas_bloc.dart'
    as _i343;
import 'package:login_pro/features/organizaciones/data/repositories/organizaciones_repository_impl.dart'
    as _i37;
import 'package:login_pro/features/organizaciones/domain/repositories/organizaciones_repository.dart'
    as _i255;
import 'package:login_pro/features/recintos/data/datasources/recintos_remote_data_source.dart'
    as _i820;
import 'package:login_pro/features/recintos/data/repositories/recintos_repository_impl.dart'
    as _i15;
import 'package:login_pro/features/recintos/domain/repositories/recintos_repository.dart'
    as _i346;
import 'package:login_pro/features/recintos/domain/usecases/get_recintos.dart'
    as _i664;
import 'package:login_pro/features/recintos/domain/usecases/save_recinto.dart'
    as _i828;
import 'package:login_pro/features/recintos/presentation/bloc/recintos_bloc.dart'
    as _i37;
import 'package:login_pro/features/sync/data/sync_service.dart' as _i375;
import 'package:login_pro/features/users/data/datasources/users_remote_data_source.dart'
    as _i550;
import 'package:login_pro/features/users/data/repositories/users_repository_impl.dart'
    as _i930;
import 'package:login_pro/features/users/domain/repositories/users_repository.dart'
    as _i629;
import 'package:login_pro/features/users/domain/usecases/create_user.dart'
    as _i140;
import 'package:login_pro/features/users/domain/usecases/get_veedores.dart'
    as _i1054;
import 'package:login_pro/features/users/presentation/bloc/users_bloc.dart'
    as _i12;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i162.AppDatabase>(() => _i162.AppDatabase());
    gh.lazySingleton<_i591.BlurDetector>(() => _i591.BlurDetector());
    gh.lazySingleton<_i780.GpsService>(() => _i780.GpsService());
    gh.lazySingleton<_i762.ActasRemoteDataSource>(
        () => _i762.ActasRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i550.UsersRemoteDataSource>(
        () => _i550.UsersRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i505.NetworkInfo>(
        () => _i505.NetworkInfoImpl(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i820.RecintosRemoteDataSource>(
        () => _i820.RecintosRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i658.MesasRemoteDataSource>(
        () => _i658.MesasRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i255.OrganizacionesRepository>(
        () => _i37.OrganizacionesRepositoryImpl());
    gh.lazySingleton<_i383.AuthRemoteDataSource>(
        () => _i383.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i328.PhotoCaptureService>(
        () => _i328.PhotoCaptureService(gh<_i591.BlurDetector>()));
    gh.lazySingleton<_i638.AuthRepository>(() => _i12.AuthRepositoryImpl(
          remoteDataSource: gh<_i383.AuthRemoteDataSource>(),
          networkInfo: gh<_i505.NetworkInfo>(),
        ));
    gh.lazySingleton<_i120.DashboardRepository>(
        () => _i300.DashboardRepositoryImpl(gh<_i454.SupabaseClient>()));
    gh.lazySingleton<_i346.RecintosRepository>(
        () => _i15.RecintosRepositoryImpl(
              remoteDataSource: gh<_i820.RecintosRemoteDataSource>(),
              networkInfo: gh<_i505.NetworkInfo>(),
            ));
    gh.lazySingleton<_i701.MesasRepository>(() => _i1059.MesasRepositoryImpl(
          remoteDataSource: gh<_i658.MesasRemoteDataSource>(),
          networkInfo: gh<_i505.NetworkInfo>(),
        ));
    gh.factory<_i864.GetProvincialAvance>(
        () => _i864.GetProvincialAvance(gh<_i120.DashboardRepository>()));
    gh.lazySingleton<_i61.ActasLocalDataSource>(
        () => _i61.ActasLocalDataSourceImpl(gh<_i162.AppDatabase>()));
    gh.lazySingleton<_i1056.ConnectivityService>(
        () => _i1056.ConnectivityService(gh<_i895.Connectivity>()));
    gh.lazySingleton<_i629.UsersRepository>(() => _i930.UsersRepositoryImpl(
          remoteDataSource: gh<_i550.UsersRemoteDataSource>(),
          networkInfo: gh<_i505.NetworkInfo>(),
        ));
    gh.lazySingleton<_i1005.ActasRepository>(() => _i1053.ActasRepositoryImpl(
          remoteDataSource: gh<_i762.ActasRemoteDataSource>(),
          localDataSource: gh<_i61.ActasLocalDataSource>(),
          syncService: gh<_i375.SyncService>(),
          networkInfo: gh<_i505.NetworkInfo>(),
        ));
    gh.factory<_i664.GetRecintos>(
        () => _i664.GetRecintos(gh<_i346.RecintosRepository>()));
    gh.factory<_i828.SaveRecinto>(
        () => _i828.SaveRecinto(gh<_i346.RecintosRepository>()));
    gh.factory<_i340.ChangePassword>(
        () => _i340.ChangePassword(gh<_i638.AuthRepository>()));
    gh.factory<_i314.GetCurrentSession>(
        () => _i314.GetCurrentSession(gh<_i638.AuthRepository>()));
    gh.factory<_i1002.ResetPassword>(
        () => _i1002.ResetPassword(gh<_i638.AuthRepository>()));
    gh.factory<_i1051.SignIn>(() => _i1051.SignIn(gh<_i638.AuthRepository>()));
    gh.factory<_i427.SignOut>(() => _i427.SignOut(gh<_i638.AuthRepository>()));
    gh.factory<_i308.AssignVeedor>(
        () => _i308.AssignVeedor(gh<_i701.MesasRepository>()));
    gh.factory<_i79.GetMesasByRecinto>(
        () => _i79.GetMesasByRecinto(gh<_i701.MesasRepository>()));
    gh.factory<_i612.GetMesasByVeedor>(
        () => _i612.GetMesasByVeedor(gh<_i701.MesasRepository>()));
    gh.factory<_i361.DashboardBloc>(() => _i361.DashboardBloc(
        getProvincialAvance: gh<_i864.GetProvincialAvance>()));
    gh.factory<_i948.GetActasByMesa>(
        () => _i948.GetActasByMesa(gh<_i1005.ActasRepository>()));
    gh.factory<_i173.GetPhotoUrl>(
        () => _i173.GetPhotoUrl(gh<_i1005.ActasRepository>()));
    gh.factory<_i328.SaveActa>(
        () => _i328.SaveActa(gh<_i1005.ActasRepository>()));
    gh.factory<_i140.CreateUser>(
        () => _i140.CreateUser(gh<_i629.UsersRepository>()));
    gh.factory<_i1054.GetVeedores>(
        () => _i1054.GetVeedores(gh<_i629.UsersRepository>()));
    gh.factory<_i540.ActasBloc>(() => _i540.ActasBloc(
          getActasByMesa: gh<_i948.GetActasByMesa>(),
          saveActa: gh<_i328.SaveActa>(),
          organizacionesRepository: gh<_i255.OrganizacionesRepository>(),
        ));
    gh.factory<_i746.AuthBloc>(() => _i746.AuthBloc(
          signIn: gh<_i1051.SignIn>(),
          signOut: gh<_i427.SignOut>(),
          resetPassword: gh<_i1002.ResetPassword>(),
          changePassword: gh<_i340.ChangePassword>(),
          getCurrentSession: gh<_i314.GetCurrentSession>(),
        ));
    gh.factory<_i343.MesasBloc>(() => _i343.MesasBloc(
          getMesasByRecinto: gh<_i79.GetMesasByRecinto>(),
          getMesasByVeedor: gh<_i612.GetMesasByVeedor>(),
          assignVeedor: gh<_i308.AssignVeedor>(),
          getVeedores: gh<_i1054.GetVeedores>(),
        ));
    gh.factory<_i37.RecintosBloc>(() => _i37.RecintosBloc(
          getRecintos: gh<_i664.GetRecintos>(),
          saveRecinto: gh<_i828.SaveRecinto>(),
        ));
    gh.factory<_i12.UsersBloc>(
        () => _i12.UsersBloc(createUser: gh<_i140.CreateUser>()));
    return this;
  }
}
