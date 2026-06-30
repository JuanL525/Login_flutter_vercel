import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/scale_on_tap.dart';
import '../../../../core/widgets/screen_entrance.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/acta_entity.dart';
import '../bloc/actas_bloc.dart';
import 'acta_detail_page.dart';
import 'acta_form_page.dart';
import '../../../../core/constants/enums.dart';

/// Muestra las dos actas de una mesa (alcalde y prefecto).
class MesaActasPage extends StatelessWidget {
  final String mesaId;
  final int numeroJrv;
  final bool readOnly;

  const MesaActasPage({
    super.key,
    required this.mesaId,
    required this.numeroJrv,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActasBloc>()..add(LoadActas(mesaId)),
      child: _MesaActasView(
        mesaId: mesaId,
        numeroJrv: numeroJrv,
        readOnly: readOnly,
      ),
    );
  }
}

class _MesaActasView extends StatelessWidget {
  final String mesaId;
  final int numeroJrv;
  final bool readOnly;
  const _MesaActasView({
    required this.mesaId,
    required this.numeroJrv,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa $numeroJrv - Actas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: () =>
                context.read<ActasBloc>().add(LoadActas(mesaId)),
          ),
        ],
      ),
      body: BlocConsumer<ActasBloc, ActasState>(
        listener: (context, state) {
          if (state is ActasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ActasLoading || state is ActaSaving) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ActasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ActasBloc>().add(LoadActas(mesaId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final loaded = state as ActasLoaded;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ActaTile(
                dignidad: Dignidad.alcalde,
                acta: loaded.alcalde,
                mesaId: mesaId,
                readOnly: readOnly,
                index: 0,
              ),
              const SizedBox(height: 12),
              _ActaTile(
                dignidad: Dignidad.prefecto,
                acta: loaded.prefecto,
                mesaId: mesaId,
                readOnly: readOnly,
                index: 1,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActaTile extends StatelessWidget {
  final Dignidad dignidad;
  final ActaEntity? acta;
  final String mesaId;
  final bool readOnly;
  final int index;

  const _ActaTile({
    required this.dignidad,
    required this.acta,
    required this.mesaId,
    required this.readOnly,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;
    final bloc = context.read<ActasBloc>();
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  dignidad == Dignidad.alcalde
                      ? Icons.account_balance_outlined
                      : Icons.location_city_outlined,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Acta de ${dignidad.label}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (registrada)
                StatusChip(
                  label: acta!.synced ? 'Sincronizada' : 'Pendiente',
                  type: acta!.synced ? AppStatusType.success : AppStatusType.warning,
                  icon: acta!.synced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            registrada
                ? 'Total sufragantes: ${acta!.totalSufragantes}'
                : 'Aún no registrada',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (registrada)
                Expanded(
                  child: ScaleOnTap(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ActaDetailPage(acta: acta!),
                        ),
                      );
                    },
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ActaDetailPage(acta: acta!),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Ver'),
                    ),
                  ),
                ),
              if (registrada && !readOnly) const SizedBox(width: 8),
              if (!readOnly)
                Expanded(
                  child: PrimaryButton(
                    label: registrada ? 'Corregir' : 'Registrar',
                    icon: registrada ? Icons.edit_outlined : Icons.add_rounded,
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: bloc,
                            child: ActaFormPage(
                              mesaId: mesaId,
                              dignidad: dignidad,
                              existing: acta,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    ).fadeSlideUp(delay: Duration(milliseconds: index * 100));
  }
}
