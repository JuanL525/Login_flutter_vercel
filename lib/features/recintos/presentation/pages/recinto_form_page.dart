import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  bool get _isEdit => widget.recinto != null;

  @override
  void initState() {
    super.initState();
    _provincia =
        TextEditingController(text: widget.recinto?.provincia ?? 'Pichincha');
    _canton = TextEditingController(text: widget.recinto?.canton ?? 'Quito');
    _parroquia = TextEditingController(text: widget.recinto?.parroquia ?? '');
    _nombre = TextEditingController(text: widget.recinto?.nombre ?? '');
  }

  @override
  void dispose() {
    _provincia.dispose();
    _canton.dispose();
    _parroquia.dispose();
    _nombre.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<RecintosBloc>().add(
            SaveRecintoRequested(
              id: widget.recinto?.id,
              provincia: _provincia.text.trim(),
              canton: _canton.text.trim(),
              parroquia: _parroquia.text.trim(),
              nombre: _nombre.text.trim(),
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
        listener: (context, state) {
          if (state is RecintosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is RecintoSaved) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final isLoading = state is RecintosLoading;
          return LoadingOverlay(
            isLoading: isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                        label: 'Canton',
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
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          child: Text(_isEdit ? 'Guardar cambios' : 'Crear'),
                        ),
                      ),
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;
}
