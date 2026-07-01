import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/validators/cedula_validator.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/widgets/user_message_dialog.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_overlay.dart';
import '../bloc/users_bloc.dart';

/// Formulario reutilizable para crear coordinadores de recinto o veedores.
class CreateUserPage extends StatelessWidget {
  final UserRole role;
  final String? recintoId;
  final String title;

  const CreateUserPage({
    super.key,
    required this.role,
    required this.title,
    this.recintoId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UsersBloc>(),
      child: _CreateUserView(role: role, recintoId: recintoId, title: title),
    );
  }
}

class _CreateUserView extends StatefulWidget {
  final UserRole role;
  final String? recintoId;
  final String title;
  const _CreateUserView({
    required this.role,
    required this.title,
    this.recintoId,
  });

  @override
  State<_CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<_CreateUserView> {
  final _formKey = GlobalKey<FormState>();
  final _cedula = TextEditingController();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _cedula.dispose();
    _nombres.dispose();
    _apellidos.dispose();
    _telefono.dispose();
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<UsersBloc>().add(
            CreateUserRequested(
              cedula: _cedula.text.trim(),
              nombres: _nombres.text.trim(),
              apellidos: _apellidos.text.trim(),
              telefono: _telefono.text.trim(),
              email: _email.text.trim(),
              role: widget.role,
              recintoId: widget.recintoId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocConsumer<UsersBloc, UsersState>(
        listener: (context, state) async {
          if (state is UsersError) {
            await UserMessageDialog.showError(
              context,
              title: createUserErrorTitle(state.message),
              message: state.message,
            );
          } else if (state is UserCreatedSuccess) {
            await UserMessageDialog.showSuccess(
              context,
              title: 'Cuenta creada',
              message: 'Se envió un correo de verificación a la dirección '
                  'registrada. El usuario debe verificar su cuenta antes de '
                  'ingresar por primera vez.\n\n'
                  'Contraseña inicial: Ecuador2026',
              buttonText: 'Entendido',
            );
            if (context.mounted) Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final isLoading = state is UsersLoading;
          return LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppDecorations.floatingForm(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              controller: _cedula,
                              label: 'Cédula',
                              hint: '10 dígitos',
                              prefixIcon: Icons.badge_outlined,
                              keyboardType: TextInputType.number,
                              validator: CedulaValidator.validate,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _nombres,
                              label: 'Nombres completos',
                              hint: 'Nombres',
                              prefixIcon: Icons.person_outline,
                              validator: _required,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _apellidos,
                              label: 'Apellidos completos',
                              hint: 'Apellidos',
                              prefixIcon: Icons.person_outline,
                              validator: _required,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _telefono,
                              label: 'Teléfono de contacto',
                              hint: '09xxxxxxxx',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: _required,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _email,
                              label: 'Correo electrónico',
                              hint: 'correo@dominio.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ingrese el correo';
                                }
                                if (!v.contains('@') || !v.contains('.')) {
                                  return 'Correo inválido';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              label: 'Crear cuenta',
                              onPressed: isLoading ? null : _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SoftCard(
                      padding: const EdgeInsets.all(16),
                      radius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mark_email_unread_outlined, color: AppTheme.primaryColor.withValues(alpha: 0.8)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Se enviará un correo de verificación. '
                                  'El usuario debe confirmar su cuenta '
                                  'antes de poder ingresar.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.vpn_key_outlined, color: AppTheme.accentColor.withValues(alpha: 0.9)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Contraseña inicial: Ecuador2026. '
                                  'Deberá cambiarla en el primer ingreso.',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;
}
