import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/user_message_dialog.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/loading_overlay.dart';
import '../../domain/entities/recinto_entity.dart';
import '../bloc/recintos_bloc.dart';

/// Crea (provincial) o edita (provincial o coordinador de su recinto) un recinto.
class RecintoFormPage extends StatelessWidget {
  final RecintoEntity? recinto;
  const RecintoFormPage({super.key, this.recinto});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RecintosBloc>(),
      child: _RecintoFormView(recinto: recinto),
    );
  }
}

class _RecintoFormView extends StatefulWidget {
  final RecintoEntity? recinto;
  const _RecintoFormView({this.recinto});

  @override
  State<_RecintoFormView> createState() => _RecintoFormViewState();
}

class _RecintoFormViewState extends State<_RecintoFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _provincia;
  late final TextEditingController _canton;
  late final TextEditingController _parroquia;
  late final TextEditingController _nombre;
  late final TextEditingController _cantidadMesas;

  bool get _isEdit => widget.recinto != null;

  @override
  void initState() {
    super.initState();
    _provincia =
        TextEditingController(text: widget.recinto?.provincia ?? 'Pichincha');
    _canton = TextEditingController(text: widget.recinto?.canton ?? 'Quito');
    _parroquia = TextEditingController(text: widget.recinto?.parroquia ?? '');
    _nombre = TextEditingController(text: widget.recinto?.nombre ?? '');
    _cantidadMesas = TextEditingController(text: '4');
  }

  @override
  void dispose() {
    _provincia.dispose();
    _canton.dispose();
    _parroquia.dispose();
    _nombre.dispose();
    _cantidadMesas.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final mesas = _isEdit ? 0 : (int.tryParse(_cantidadMesas.text.trim()) ?? 0);
      context.read<RecintosBloc>().add(
            SaveRecintoRequested(
              id: widget.recinto?.id,
              provincia: _provincia.text.trim(),
              canton: _canton.text.trim(),
              parroquia: _parroquia.text.trim(),
              nombre: _nombre.text.trim(),
              cantidadMesas: mesas,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar recinto' : 'Nuevo recinto'),
      ),
      body: BlocConsumer<RecintosBloc, RecintosState>(
        listener: (context, state) async {
          if (state is RecintosError) {
            await UserMessageDialog.showError(
              context,
              title: 'No se pudo guardar',
              message: state.message,
            );
          } else if (state is RecintoSaved) {
            final mesas = int.tryParse(_cantidadMesas.text.trim()) ?? 0;
            await UserMessageDialog.showSuccess(
              context,
              title: _isEdit ? 'Recinto actualizado' : 'Recinto creado',
              message: _isEdit
                  ? 'Los datos del recinto se guardaron correctamente.'
                  : 'El recinto fue registrado con $mesas mesa${mesas == 1 ? '' : 's'} (JRV).',
              buttonText: 'Listo',
            );
            if (context.mounted) Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final isLoading = state is RecintosLoading;
          return LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppDecorations.floatingForm(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _provincia,
                          label: 'Provincia',
                          hint: 'Pichincha',
                          prefixIcon: Icons.map_outlined,
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _canton,
                          label: 'Cantón',
                          hint: 'Quito',
                          prefixIcon: Icons.location_city_outlined,
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _parroquia,
                          label: 'Parroquia',
                          hint: 'Calderon',
                          prefixIcon: Icons.place_outlined,
                          validator: _required,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _nombre,
                          label: 'Nombre del recinto',
                          hint: 'Unidad Educativa...',
                          prefixIcon: Icons.school_outlined,
                          validator: _required,
                        ),
                        if (!_isEdit) ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _cantidadMesas,
                            label: 'Cantidad de mesas (JRV)',
                            hint: '4',
                            prefixIcon: Icons.table_rows_outlined,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Ingrese la cantidad de mesas';
                              }
                              final n = int.tryParse(v.trim());
                              if (n == null || n < 1 || n > 50) {
                                return 'Debe ser un número entre 1 y 50';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Se crearán mesas numeradas del 1 al valor indicado.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: _isEdit ? 'Guardar cambios' : 'Crear recinto con mesas',
                          onPressed: isLoading ? null : _submit,
                        ),
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;
}
