import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../actas/presentation/pages/mesa_actas_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../mesas/domain/entities/mesa_entity.dart';
import '../../../mesas/presentation/bloc/mesas_bloc.dart';
import '../../../sync/data/sync_service.dart';

/// Home del veedor: ve solo las mesas que tiene asignadas y registra actas.
class VeedorHomePage extends StatelessWidget {
  final String veedorId;
  const VeedorHomePage({super.key, required this.veedorId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MesasBloc>()..add(LoadMesasByVeedor(veedorId)),
      child: _VeedorView(veedorId: veedorId),
    );
  }
}

class _VeedorView extends StatelessWidget {
  final String veedorId;
  const _VeedorView({required this.veedorId});

  @override
  Widget build(BuildContext context) {
    final sync = getIt<SyncService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis mesas'),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: sync.pendingCount,
            builder: (context, pending, _) {
              if (pending == 0) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.cloud_done, color: Colors.white),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_upload, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('$pending'),
                    const SizedBox(width: 4),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sincronizar',
            onPressed: () {
              sync.processOutbox();
              context.read<MesasBloc>().add(LoadMesasByVeedor(veedorId));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
      body: BlocConsumer<MesasBloc, MesasState>(
        listener: (context, state) {
          if (state is MesasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MesasLoading || state is MesasInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MesasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<MesasBloc>()
                        .add(LoadMesasByVeedor(veedorId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final loaded = state as MesasLoaded;
          if (loaded.mesas.isEmpty) {
            return const Center(
              child: Text('No tienes mesas asignadas todavia'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<MesasBloc>().add(LoadMesasByVeedor(veedorId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: loaded.mesas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final mesa = loaded.mesas[i];
                return _MesaCard(mesa: mesa, veedorId: veedorId);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final MesaEntity mesa;
  final String veedorId;
  const _MesaCard({required this.mesa, required this.veedorId});

  @override
  Widget build(BuildContext context) {
    final color = mesa.completa
        ? Colors.green
        : (mesa.sinIniciar ? Colors.orange : Colors.blue);
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.how_to_vote, color: color),
        ),
        title: Text('Mesa ${mesa.numeroJrv}'),
        subtitle: Text(
          '${mesa.estadoLabel} (${mesa.actasRegistradas}/2 actas)',
          style: TextStyle(color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MesaActasPage(
                mesaId: mesa.id,
                numeroJrv: mesa.numeroJrv,
                readOnly: false,
              ),
            ),
          );
          if (context.mounted) {
            context.read<MesasBloc>().add(LoadMesasByVeedor(veedorId));
          }
        },
      ),
    );
  }
}
