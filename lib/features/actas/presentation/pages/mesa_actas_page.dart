import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/acta_entity.dart';
import '../bloc/actas_bloc.dart';
import 'acta_detail_page.dart';
import 'acta_form_page.dart';

/// Muestra las dos actas de una mesa (alcalde y prefecto).
class MesaActasPage extends StatelessWidget {
  final String mesaId;
  final int numeroJrv;

  /// Si es true, solo se puede visualizar (caso coordinador provincial).
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
      appBar: AppBar(title: Text('Mesa $numeroJrv - Actas')),
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
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
              ),
              const SizedBox(height: 12),
              _ActaTile(
                dignidad: Dignidad.prefecto,
                acta: loaded.prefecto,
                mesaId: mesaId,
                readOnly: readOnly,
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

  const _ActaTile({
    required this.dignidad,
    required this.acta,
    required this.mesaId,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final registrada = acta != null;
    final bloc = context.read<ActasBloc>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  dignidad == Dignidad.alcalde
                      ? Icons.account_balance
                      : Icons.location_city,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acta de ${dignidad.label}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (registrada)
                  Row(
                    children: [
                      Icon(
                        acta!.synced ? Icons.cloud_done : Icons.cloud_off,
                        size: 18,
                        color: acta!.synced ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        acta!.synced ? 'Sincronizada' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 12,
                          color: acta!.synced ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              registrada
                  ? 'Total sufragantes: ${acta!.totalSufragantes}'
                  : 'Aun no registrada',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (registrada)
                  Expanded(
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
                if (registrada && !readOnly) const SizedBox(width: 8),
                if (!readOnly)
                  Expanded(
                    child: ElevatedButton.icon(
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
                      icon: Icon(registrada ? Icons.edit : Icons.add),
                      label: Text(registrada ? 'Corregir' : 'Registrar'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
