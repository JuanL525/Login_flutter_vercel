import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/seeds/organizaciones_seed.dart';
import '../../../../core/services/gps_service.dart';
import '../../../../core/services/photo_capture_service.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/usecases/save_acta.dart';
import '../bloc/actas_bloc.dart';

class ActaFormPage extends StatefulWidget {
  final String mesaId;
  final Dignidad dignidad;
  final ActaEntity? existing;

  const ActaFormPage({
    super.key,
    required this.mesaId,
    required this.dignidad,
    this.existing,
  });

  @override
  State<ActaFormPage> createState() => _ActaFormPageState();
}

class _ActaFormPageState extends State<ActaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _votosCtrls = <String, TextEditingController>{};
  final _blancosCtrl = TextEditingController(text: '0');
  final _nulosCtrl = TextEditingController(text: '0');
  final _totalCtrl = TextEditingController(text: '0');

  String? _fotoLocalPath;
  String? _fotoPath;
  double? _lat;
  double? _lng;
  double? _sharpness;
  bool _capturing = false;

  late final List<OrganizacionPolitica> _orgs;

  @override
  void initState() {
    super.initState();
    _orgs = context.read<ActasBloc>().organizaciones(widget.dignidad);
    final existing = widget.existing;
    for (final o in _orgs) {
      _votosCtrls[o.id] = TextEditingController(
        text: (existing?.votos[o.id] ?? 0).toString(),
      );
    }
    if (existing != null) {
      _blancosCtrl.text = existing.votosBlancos.toString();
      _nulosCtrl.text = existing.votosNulos.toString();
      _totalCtrl.text = existing.totalSufragantes.toString();
      _fotoLocalPath = existing.fotoLocalPath;
      _fotoPath = existing.fotoPath;
      _lat = existing.gpsLat;
      _lng = existing.gpsLng;
    }
  }

  @override
  void dispose() {
    for (final c in _votosCtrls.values) {
      c.dispose();
    }
    _blancosCtrl.dispose();
    _nulosCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  int _toInt(String s) => int.tryParse(s.trim()) ?? 0;

  int get _suma {
    var s = _toInt(_blancosCtrl.text) + _toInt(_nulosCtrl.text);
    for (final c in _votosCtrls.values) {
      s += _toInt(c.text);
    }
    return s;
  }

  Future<void> _capturarFotoYGps() async {
    setState(() => _capturing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 1. Foto con validacion de nitidez.
      final photoService = getIt<PhotoCaptureService>();
      final photo = await photoService.capture();
      if (photo == null) {
        setState(() => _capturing = false);
        return;
      }
      // 2. GPS (obligatorio).
      final gpsService = getIt<GpsService>();
      final pos = await gpsService.getCurrentPosition();

      setState(() {
        _fotoLocalPath = photo.localPath;
        _fotoPath = null; // foto nueva: se subira al sincronizar
        _sharpness = photo.sharpnessVariance;
        _lat = pos.latitude;
        _lng = pos.longitude;
        _capturing = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Foto nitida (${photo.sharpnessVariance.toStringAsFixed(0)}) '
            'y GPS capturados',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } on BlurryPhotoException catch (e) {
      setState(() => _capturing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.orange,
        ),
      );
    } on LocationPermissionException catch (e) {
      setState(() => _capturing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (e) {
      setState(() => _capturing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al capturar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    String userId = '';
    if (authState is AuthAuthenticated) {
      userId = authState.session.profile.id;
    } else if (authState is AuthMustChangePassword) {
      userId = authState.session.profile.id;
    }

    final votos = <String, int>{};
    for (final o in _orgs) {
      votos[o.id] = _toInt(_votosCtrls[o.id]!.text);
    }

    final acta = ActaEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      mesaId: widget.mesaId,
      dignidad: widget.dignidad,
      votos: votos,
      votosBlancos: _toInt(_blancosCtrl.text),
      votosNulos: _toInt(_nulosCtrl.text),
      totalSufragantes: _toInt(_totalCtrl.text),
      fotoLocalPath: _fotoLocalPath,
      fotoPath: _fotoPath,
      gpsLat: _lat,
      gpsLng: _lng,
      status: widget.existing == null
          ? ActaStatus.registrada
          : ActaStatus.corregida,
      registradoPor:
          widget.existing?.registradoPor.isNotEmpty == true
              ? widget.existing!.registradoPor
              : userId,
      updatedAt: DateTime.now(),
      synced: false,
    );

    // Validacion de negocio antes de enviar (feedback inmediato).
    final error = SaveActa.validateVotos(acta);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<ActasBloc>().add(SaveActaRequested(acta));
  }

  @override
  Widget build(BuildContext context) {
    final total = _toInt(_totalCtrl.text);
    final suma = _suma;
    final exceso = suma > total && total > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Acta de ${widget.dignidad.label}'),
      ),
      body: BlocListener<ActasBloc, ActasState>(
        listener: (context, state) {
          if (state is ActaSaveSuccess) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Acta guardada'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is ActasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Votos por organizacion politica',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._orgs.map(_buildOrgField),
                  const Divider(height: 32),
                  _buildNumberField('Votos en blanco', _blancosCtrl),
                  const SizedBox(height: 12),
                  _buildNumberField('Votos nulos', _nulosCtrl),
                  const SizedBox(height: 12),
                  _buildNumberField('Total de sufragantes', _totalCtrl),
                  const SizedBox(height: 16),
                  Card(
                    color: exceso
                        ? Theme.of(context)
                            .colorScheme
                            .error
                            .withValues(alpha: 0.1)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            exceso ? Icons.warning_amber : Icons.calculate,
                            color: exceso
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              exceso
                                  ? 'La suma ($suma) supera el total ($total)'
                                  : 'Suma contabilizada: $suma / $total',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 32),
                  _buildPhotoSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _capturing ? null : _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar acta'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrgField(OrganizacionPolitica o) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _votosCtrls[o.id],
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: '${o.lista} - ${o.nombre}',
          helperText: 'Candidato: ${o.candidato}',
          prefixIcon: const Icon(Icons.how_to_vote),
        ),
        validator: (v) {
          final n = int.tryParse(v ?? '');
          if (n == null || n < 0) return 'Valor invalido';
          return null;
        },
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.numbers),
      ),
      validator: (v) {
        final n = int.tryParse(v ?? '');
        if (n == null || n < 0) return 'Valor invalido';
        return null;
      },
    );
  }

  Widget _buildPhotoSection() {
    final hasPhoto = _fotoLocalPath != null || _fotoPath != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Foto del acta + GPS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_fotoLocalPath != null && File(_fotoLocalPath!).existsSync())
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_fotoLocalPath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else if (_fotoPath != null)
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Foto ya registrada en el servidor'),
          ),
        const SizedBox(height: 8),
        if (_sharpness != null)
          Text('Nitidez: ${_sharpness!.toStringAsFixed(0)}'),
        if (_lat != null && _lng != null)
          Text(
            'GPS: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _capturing ? null : _capturarFotoYGps,
          icon: _capturing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.camera_alt),
          label: Text(hasPhoto ? 'Volver a tomar foto' : 'Tomar foto del acta'),
        ),
      ],
    );
  }
}
