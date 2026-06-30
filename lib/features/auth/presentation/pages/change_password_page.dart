import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_entrance.dart';
import '../../../../core/widgets/user_message_dialog.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_overlay.dart';

/// Pantalla de cambio obligatorio de contrasena en el primer inicio de sesion.
class ChangePasswordPage extends StatefulWidget {
  final bool mandatory;
  const ChangePasswordPage({super.key, this.mandatory = true});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ChangePasswordRequested(newPassword: _passwordController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.mandatory
          ? null
          : AppBar(title: const Text('Cambiar contraseña')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthAuthenticated && !widget.mandatory) {
            await UserMessageDialog.showSuccess(
              context,
              title: 'Contraseña actualizada',
              message: 'Tu nueva contraseña quedó guardada correctamente.',
            );
            if (context.mounted) Navigator.of(context).pop();
          } else if (state is AuthAuthenticated && widget.mandatory) {
            await UserMessageDialog.showSuccess(
              context,
              title: 'Contraseña actualizada',
              message: 'Ya puedes usar la aplicación con tu nueva contraseña.',
            );
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
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: AppDecorations.softShadow,
                        ),
                        child: const Icon(
                          Icons.password_rounded,
                          color: Colors.white,
                          size: 38,
                        ),
                      ).fadeSlideUp(),
                      const SizedBox(height: 24),
                      Text(
                        widget.mandatory
                            ? 'Cambia tu contraseña'
                            : 'Nueva contraseña',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ).fadeSlideUp(delay: const Duration(milliseconds: 80)),
                      const SizedBox(height: 8),
                      if (widget.mandatory)
                        Text(
                          'Por seguridad debes cambiar la contraseña inicial '
                          'antes de continuar.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ).fadeSlideUp(delay: const Duration(milliseconds: 120)),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: AppDecorations.floatingForm(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                controller: _passwordController,
                                label: 'Nueva contraseña',
                                hint: '********',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.length < 6) {
                                    return 'Mínimo 6 caracteres';
                                  }
                                  if (value == 'Ecuador2026') {
                                    return 'No puede ser la contraseña inicial';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _confirmController,
                                label: 'Confirmar contraseña',
                                hint: '********',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                label: 'Guardar',
                                onPressed: isLoading ? null : _handleSubmit,
                              ),
                              if (widget.mandatory) ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => context
                                          .read<AuthBloc>()
                                          .add(const SignOutRequested()),
                                  child: const Text('Cerrar sesión'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ).fadeSlideUp(delay: const Duration(milliseconds: 160)),
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
