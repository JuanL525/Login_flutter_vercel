import 'package:flutter/material.dart';
import '../../../users/domain/entities/profile_entity.dart';
import 'identity_banner.dart';
import 'identity_context.dart';

/// Banner de identidad que recarga sus datos cuando cambia [refreshGeneration].
class IdentityBannerHost extends StatefulWidget {
  final ProfileEntity profile;
  final String? recintoId;
  final bool loadProvincia;
  final int refreshGeneration;

  const IdentityBannerHost({
    super.key,
    required this.profile,
    this.recintoId,
    this.loadProvincia = false,
    this.refreshGeneration = 0,
  });

  @override
  State<IdentityBannerHost> createState() => _IdentityBannerHostState();
}

class _IdentityBannerHostState extends State<IdentityBannerHost> {
  String? _provinciaNombre;
  String? _recintoNombre;
  String? _recintoUbicacion;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant IdentityBannerHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshGeneration != widget.refreshGeneration ||
        oldWidget.recintoId != widget.recintoId ||
        oldWidget.loadProvincia != widget.loadProvincia) {
      _reload();
    }
  }

  Future<void> _reload() async {
    String? provincia;
    String? recintoNombre;
    String? recintoUbicacion;

    if (widget.loadProvincia) {
      provincia = await IdentityContext.provinciaFromRecintos();
    }

    if (widget.recintoId != null) {
      final recinto = await IdentityContext.recintoById(widget.recintoId);
      if (recinto != null) {
        recintoNombre = recinto.nombre;
        recintoUbicacion = '${recinto.parroquia}, ${recinto.canton}';
      }
    }

    if (!mounted) return;
    setState(() {
      _provinciaNombre = provincia;
      _recintoNombre = recintoNombre;
      _recintoUbicacion = recintoUbicacion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IdentityBanner(
      profile: widget.profile,
      provinciaNombre: _provinciaNombre,
      recintoNombre: _recintoNombre,
      recintoUbicacion: _recintoUbicacion,
    );
  }
}
