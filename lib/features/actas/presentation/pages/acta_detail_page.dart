import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/seeds/organizaciones_seed.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ios_settings_group.dart';
import '../../../../core/widgets/scale_on_tap.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/acta_entity.dart';
import '../../domain/usecases/get_photo_url.dart';

class ActaDetailPage extends StatefulWidget {
  final ActaEntity acta;
  const ActaDetailPage({super.key, required this.acta});

  @override
  State<ActaDetailPage> createState() => _ActaDetailPageState();
}

class _ActaDetailPageState extends State<ActaDetailPage> {
  String? _signedUrl;
  bool _loadingUrl = false;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final acta = widget.acta;
    if (acta.fotoPath == null) return;
    setState(() => _loadingUrl = true);
    final url = await getIt<GetPhotoUrl>()(acta.fotoPath!);
    if (mounted) {
      setState(() {
        _signedUrl = url;
        _loadingUrl = false;
      });
    }
  }

  Future<void> _openMaps() async {
    final acta = widget.acta;
    if (acta.gpsLat == null || acta.gpsLng == null) return;
    final lat = acta.gpsLat!;
    final lng = acta.gpsLng!;

    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(Acta)');
    final webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    bool launched = false;
    try {
      if (await canLaunchUrl(geoUri)) {
        launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      }
      if (!launched) {
        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launched = false;
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir el mapa. Verifica que tienes una app de mapas instalada.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final acta = widget.acta;
    final orgs = organizacionesPorDignidad(acta.dignidad);

    return Scaffold(
      appBar: AppBar(title: Text('Acta de ${acta.dignidad.label}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
            child: _buildPhoto(acta),
          ),
          const SizedBox(height: 16),
          IosSettingsGroup(
            label: 'Resultados',
            children: [
              for (var i = 0; i < orgs.length; i++)
                IosSettingsRow(
                  title: '${orgs[i].lista} - ${orgs[i].nombre}',
                  showDivider: i < orgs.length - 1,
                  trailing: Text(
                    '${acta.votos[orgs[i].id] ?? 0}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              IosSettingsRow(
                title: 'Votos en blanco',
                trailing: _valueText(acta.votosBlancos),
              ),
              IosSettingsRow(
                title: 'Votos nulos',
                trailing: _valueText(acta.votosNulos),
              ),
              IosSettingsRow(
                title: 'Total sufragantes',
                showDivider: false,
                trailing: _valueText(acta.totalSufragantes),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: AppTheme.accentColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Coordenadas GPS',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        acta.gpsLat != null
                            ? '${acta.gpsLat!.toStringAsFixed(6)}, '
                                '${acta.gpsLng!.toStringAsFixed(6)}'
                            : 'No registradas',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (acta.gpsLat != null)
                  ScaleOnTap(
                    onTap: _openMaps,
                    child: IconButton(
                      icon: const Icon(Icons.map_outlined),
                      onPressed: _openMaps,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueText(int value) {
    return Text(
      '$value',
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 16,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildPhoto(ActaEntity acta) {
    if (_loadingUrl) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_signedUrl != null) {
      return Image.network(
        _signedUrl!,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _noPhoto(),
      );
    }
    if (acta.fotoLocalPath != null && File(acta.fotoLocalPath!).existsSync()) {
      return Image.file(
        File(acta.fotoLocalPath!),
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _noPhoto();
  }

  Widget _noPhoto() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.inputFillColor,
        borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        'Sin foto disponible',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
