import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          : AppBar(title: const Text('Cambiar contrasena')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is AuthAuthenticated && !widget.mandatory) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contrasena actualizada'),
                backgroundColor: Colors.green,
              ),
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
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.password_rounded,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.mandatory
                              ? 'Cambia tu contrasena'
                              : 'Nueva contrasena',
                          style: Theme.of(context).textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (widget.mandatory)
                          Text(
                            'Por seguridad debes cambiar la contrasena inicial '
                            'antes de continuar.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Nueva contrasena',
                          hint: '********',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Minimo 6 caracteres';
                            }
                            if (value == 'Ecuador2026') {
                              return 'No puede ser la contrasena inicial';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmController,
                          label: 'Confirmar contrasena',
                          hint: '********',
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Las contrasenas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleSubmit,
                            child: const Text('Guardar'),
                          ),
                        ),
                        if (widget.mandatory) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () => context
                                    .read<AuthBloc>()
                                    .add(const SignOutRequested()),
                            child: const Text('Cerrar sesion'),
                          ),
                        ],
                      ],
                    ),
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
