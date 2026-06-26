import 'package:flutter/material.dart';
import '../../../mesas/presentation/pages/mesas_recinto_page.dart';

/// Home del coordinador de recinto: gestiona las mesas de su recinto.
class RecintoHomePage extends StatelessWidget {
  final String recintoId;
  const RecintoHomePage({super.key, required this.recintoId});

  @override
  Widget build(BuildContext context) {
    return MesasRecintoPage(
      recintoId: recintoId,
      canManage: true,
      isHome: true,
    );
  }
}
