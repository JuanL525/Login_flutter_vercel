import 'package:flutter/material.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../injection_container.dart';
import '../../../mesas/presentation/pages/mesas_recinto_page.dart';
import '../../../recintos/domain/entities/recinto_entity.dart';
import '../../../recintos/domain/usecases/get_recintos.dart';

/// Home del coordinador de recinto: gestiona las mesas de su recinto.
class RecintoHomePage extends StatelessWidget {
  final String recintoId;
  const RecintoHomePage({super.key, required this.recintoId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecintoEntity?>(
      future: _loadRecinto(),
      builder: (context, snapshot) {
        return MesasRecintoPage(
          recintoId: recintoId,
          canManage: true,
          isHome: true,
          recintoForEdit: snapshot.data,
        );
      },
    );
  }

  Future<RecintoEntity?> _loadRecinto() async {
    final result = await getIt<GetRecintos>()(NoParams());
    return result.fold(
      (_) => null,
      (list) {
        for (final r in list) {
          if (r.id == recintoId) return r;
        }
        return null;
      },
    );
  }
}
