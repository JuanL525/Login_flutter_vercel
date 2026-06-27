import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/seeds/organizaciones_seed.dart';
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

    // Intentar abrir la app de Google Maps nativa primero (geo:).
    // Si no está instalada o falla, caer a la URL web.
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
          content: Text('No se pudo abrir el mapa. Verifica que tienes una app de mapas instalada.'),
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
          _buildPhoto(acta),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resultados',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...orgs.map(
                    (o) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${o.lista} - ${o.nombre}')),
                          Text(
                            '${acta.votos[o.id] ?? 0}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  _row('Votos en blanco', acta.votosBlancos),
                  _row('Votos nulos', acta.votosNulos),
                  _row('Total sufragantes', acta.totalSufragantes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Coordenadas GPS'),
              subtitle: Text(
                acta.gpsLat != null
                    ? '${acta.gpsLat!.toStringAsFixed(6)}, '
                        '${acta.gpsLng!.toStringAsFixed(6)}'
                    : 'No registradas',
              ),
              trailing: acta.gpsLat != null
                  ? IconButton(
                      icon: const Icon(Icons.map),
                      onPressed: _openMaps,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
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
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _signedUrl!,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _noPhoto(),
        ),
      );
    }
    if (acta.fotoLocalPath != null && File(acta.fotoLocalPath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(acta.fotoLocalPath!),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    }
    return _noPhoto();
  }

  Widget _noPhoto() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Sin foto disponible'),
    );
  }
}
