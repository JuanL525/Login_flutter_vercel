import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_entrance.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../core/widgets/user_message_dialog.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ResetPasswordRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is ResetPasswordSent) {
            await UserMessageDialog.showSuccess(
              context,
              title: 'Correo enviado',
              message: 'Revisa tu bandeja de entrada (y spam) para '
                  'restablecer tu contraseña.',
              buttonText: 'Volver al login',
            );
            if (context.mounted) {
              context.read<AuthBloc>().add(const AuthErrorDismissed());
              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppTheme.primaryColor,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ).fadeSlideUp(),
                      const SizedBox(height: 8),
                      const AppLogo(size: 96).fadeSlideUp(
                        delay: const Duration(milliseconds: 80),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recuperar contraseña',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ).fadeSlideUp(delay: const Duration(milliseconds: 120)),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ).fadeSlideUp(delay: const Duration(milliseconds: 160)),
                      const SizedBox(height: 36),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: AppDecorations.floatingForm(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                label: 'Correo electrónico',
                                hint: 'tu@email.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu correo';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Por favor ingresa un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Enviar enlace de recuperación',
                                onPressed: isLoading ? null : _handleResetPassword,
                              ),
                            ],
                          ),
                        ),
                      ).fadeSlideUp(delay: const Duration(milliseconds: 200)),
                      const SizedBox(height: 20),
                      SoftCard(
                        padding: const EdgeInsets.all(16),
                        radius: 20,
                        child: Row(
                          children: [
                            Icon(
                              Icons.mark_email_read_outlined,
                              color: AppTheme.primaryColor.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Recibirás un enlace para crear una nueva contraseña',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ).fadeSlideUp(delay: const Duration(milliseconds: 260)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
