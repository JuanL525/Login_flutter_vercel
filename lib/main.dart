import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/enums.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/user_message_dialog.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/provincial_home_page.dart';
import 'features/dashboard/presentation/pages/recinto_home_page.dart';
import 'features/dashboard/presentation/pages/veedor_home_page.dart';
import 'features/users/domain/entities/profile_entity.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'Control Electoral',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const _AuthShell(),
      ),
    );
  }
}

/// Escucha errores globales de auth y enruta segun sesion.
class _AuthShell extends StatelessWidget {
  const _AuthShell();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthError,
      listener: (context, state) async {
        if (state is! AuthError) return;
        await UserMessageDialog.showError(
          context,
          title: authErrorTitle(state.message),
          message: state.message,
        );
        if (context.mounted) {
          context.read<AuthBloc>().add(const AuthErrorDismissed());
        }
      },
      child: const _RootGate(),
    );
  }
}

/// Decide la pantalla raiz segun el estado de autenticacion y el rol.
class _RootGate extends StatelessWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Solo pantalla completa de carga al arrancar la app.
        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthMustChangePassword) {
          return const ChangePasswordPage(mandatory: true);
        }
        if (state is AuthAuthenticated) {
          final profile = state.session.profile;
          switch (profile.role) {
            case UserRole.provincial:
              return const ProvincialHomePage();
            case UserRole.recinto:
              final rid = profile.recintoId;
              if (rid == null || rid.isEmpty) {
                return _SinRecintoPage(profile: profile);
              }
              return RecintoHomePage(recintoId: rid);
            case UserRole.veedor:
              return VeedorHomePage(veedorId: profile.id);
          }
        }
        // Login visible tambien durante AuthLoading / AuthError para no
        // perder los avisos al usuario.
        return const LoginPage();
      },
    );
  }
}

/// Pantalla de aviso para un coordinador de recinto cuyo recinto fue eliminado.
class _SinRecintoPage extends StatelessWidget {
  final ProfileEntity profile;
  const _SinRecintoPage({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_outlined, size: 72, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Sin recinto asignado',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Hola ${profile.nombres}, tu cuenta no tiene un recinto asignado '
                'o el recinto anterior fue eliminado.\n\n'
                'Contacta al coordinador provincial para que te asigne a un recinto.',
                style: const TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<AuthBloc>().add(const SignOutRequested()),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
