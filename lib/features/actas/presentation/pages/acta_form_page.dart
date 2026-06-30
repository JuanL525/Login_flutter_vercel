import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/seeds/organizaciones_seed.dart';
import '../../../../core/services/blur_detector.dart';
import '../../../../core/services/gps_service.dart';
import '../../../../core/services/photo_capture_service.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ios_settings_group.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/scale_on_tap.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/soft_card.dart';
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
      final photoService = getIt<PhotoCaptureService>();
      final photo = await photoService.capture();
      if (photo == null) {
        setState(() => _capturing = false);
        return;
      }
      final gpsService = getIt<GpsService>();
      final pos = await gpsService.getCurrentPosition();

      setState(() {
        _fotoLocalPath = photo.localPath;
        _fotoPath = null;
        _sharpness = photo.sharpnessVariance;
        _lat = pos.latitude;
        _lng = pos.longitude;
        _capturing = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Foto nítida (${photo.sharpnessVariance.toStringAsFixed(0)}) '
            'y GPS capturados',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } on BlurryPhotoException catch (e) {
      setState(() => _capturing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.accentColor,
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

  Future<void> _save() async {
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

    if (_fotoLocalPath != null && File(_fotoLocalPath!).existsSync()) {
      final bytes = await File(_fotoLocalPath!).readAsBytes();
      final blur = getIt<BlurDetector>().analyze(bytes);
      if (!blur.isSharp) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La foto no cumple el mínimo de nitidez. '
              'Vuelva a tomarla antes de guardar.',
            ),
            backgroundColor: AppTheme.accentColor,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    context.read<ActasBloc>().add(SaveActaRequested(acta));
  }

  @override
  Widget build(BuildContext context) {
    final total = _toInt(_totalCtrl.text);
    final suma = _suma;
    final exceso = total > 0 && suma != total;

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
                backgroundColor: AppTheme.successColor,
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
                  IosSettingsGroup(
                    label: 'Organizaciones políticas',
                    children: [
                      for (var i = 0; i < _orgs.length; i++)
                        IosSettingsRow(
                          title: '${_orgs[i].lista} - ${_orgs[i].nombre}',
                          subtitle: _orgs[i].candidato,
                          showDivider: i < _orgs.length - 1,
                          trailing: IosNumberField(
                            controller: _votosCtrls[_orgs[i].id]!,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  IosSettingsGroup(
                    label: 'Otros votos',
                    children: [
                      IosSettingsRow(
                        title: 'Votos en blanco',
                        trailing: IosNumberField(controller: _blancosCtrl),
                      ),
                      IosSettingsRow(
                        title: 'Votos nulos',
                        trailing: IosNumberField(controller: _nulosCtrl),
                      ),
                      IosSettingsRow(
                        title: 'Total de sufragantes',
                        showDivider: false,
                        trailing: IosNumberField(controller: _totalCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    color: exceso
                        ? AppTheme.errorColor.withValues(alpha: 0.06)
                        : null,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          exceso ? Icons.warning_amber_rounded : Icons.calculate_outlined,
                          color: exceso
                              ? AppTheme.errorColor
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exceso
                                ? 'La suma ($suma) debe ser igual al total ($total)'
                                : total > 0
                                    ? 'Suma contabilizada: $suma / $total'
                                    : 'Suma contabilizada: $suma',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: exceso
                                  ? AppTheme.errorColor
                                  : AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Foto del acta + GPS'),
                  SoftCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPhotoPreview(),
                        if (_sharpness != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Nitidez: ${_sharpness!.toStringAsFixed(0)} '
                            '(min ${BlurDetector.minLaplacianVariance.toStringAsFixed(0)})',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        if (_lat != null && _lng != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'GPS: ${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 12),
                        ScaleOnTap(
                          onTap: _capturing ? null : _capturarFotoYGps,
                          child: OutlinedButton.icon(
                            onPressed: _capturing ? null : _capturarFotoYGps,
                            icon: _capturing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.camera_alt_outlined),
                            label: Text(
                              (_fotoLocalPath != null || _fotoPath != null)
                                  ? 'Volver a tomar foto'
                                  : 'Tomar foto del acta',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Guardar acta',
                    icon: Icons.save_outlined,
                    onPressed: _capturing ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    if (_fotoLocalPath != null && File(_fotoLocalPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        child: Image.file(
          File(_fotoLocalPath!),
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    if (_fotoPath != null) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Foto ya registrada en el servidor'),
      );
    }
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.6),
            size: 32,
          ),
          const SizedBox(height: 6),
          Text(
            'Sin foto capturada',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
