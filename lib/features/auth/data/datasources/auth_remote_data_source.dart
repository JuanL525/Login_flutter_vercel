import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../users/data/models/profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<ProfileModel> signInWithCedula({
    required String cedula,
    required String password,
  });
  Future<void> sendPasswordResetEmail({required String email});
  Future<ProfileModel> changePassword({required String newPassword});
  Future<void> signOut();
  Future<ProfileModel?> getCurrentProfile();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  Future<ProfileModel> _fetchProfile(String userId) async {
    final row = await supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return ProfileModel.fromMap(row);
  }

  @override
  Future<ProfileModel> signInWithCedula({
    required String cedula,
    required String password,
  }) async {
    try {
      // 1. Resolver el email a partir de la cedula (RPC SECURITY DEFINER).
      final email = await supabaseClient.rpc(
        'get_email_by_cedula',
        params: {'p_cedula': cedula},
      ) as String?;

      if (email == null || email.isEmpty) {
        throw Exception(
          'No existe una cuenta registrada con esa cédula. '
          'Verifica el número o contacta a tu coordinador.',
        );
      }

      // 2. Iniciar sesion con email + password.
      try {
        final response = await supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.user == null) {
          throw Exception('Contraseña incorrecta');
        }
        return _fetchProfile(response.user!.id);
      } on AuthException catch (e) {
        throw Exception(_mapAuthError(e.message, passwordAttempt: true));
      }
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo:
            '${AppConstants.vercelBaseUrl}${AppConstants.resetPasswordPath}',
      );
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  @override
  Future<ProfileModel> changePassword({required String newPassword}) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        throw Exception('No hay sesión activa');
      }
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      // Limpiar la bandera de cambio obligatorio.
      await supabaseClient
          .from('profiles')
          .update({'must_change_password': false}).eq('id', user.id);
      return _fetchProfile(user.id);
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  @override
  Future<void> signOut() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<ProfileModel?> getCurrentProfile() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  String _mapAuthError(String message, {bool passwordAttempt = false}) {
    final lower = message.toLowerCase();
    if (passwordAttempt ||
        lower.contains('invalid login') ||
        lower.contains('invalid credentials')) {
      return 'Contraseña incorrecta. Si es tu primer ingreso, '
          'recuerda que la clave inicial es Ecuador2026.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de ingresar.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    }
    if (lower.contains('user not found')) {
      return 'No existe una cuenta registrada con esos datos.';
    }
    return message;
  }
}
