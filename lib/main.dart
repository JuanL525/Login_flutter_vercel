import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/enums.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/change_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/presentation/pages/provincial_home_page.dart';
import 'features/dashboard/presentation/pages/recinto_home_page.dart';
import 'features/dashboard/presentation/pages/veedor_home_page.dart';
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
        home: const _RootGate(),
      ),
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
        if (state is AuthInitial || state is AuthLoading) {
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
              return RecintoHomePage(recintoId: profile.recintoId ?? '');
            case UserRole.veedor:
              return VeedorHomePage(veedorId: profile.id);
          }
        }
        return const LoginPage();
      },
    );
  }
}
