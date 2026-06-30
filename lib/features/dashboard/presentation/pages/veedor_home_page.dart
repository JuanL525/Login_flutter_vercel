import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/screen_entrance.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/sync_banner.dart';
import '../../../../injection_container.dart';
import '../../../actas/presentation/pages/mesa_actas_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../mesas/domain/entities/mesa_entity.dart';
import '../../../mesas/presentation/bloc/mesas_bloc.dart';
import '../../../sync/data/sync_service.dart';
import '../../../users/domain/entities/profile_entity.dart';
import '../widgets/identity_banner_host.dart';

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

class _VeedorView extends StatefulWidget {
  final String veedorId;
  const _VeedorView({required this.veedorId});

  @override
  State<_VeedorView> createState() => _VeedorViewState();
}

class _VeedorViewState extends State<_VeedorView> {
  int _identityRefresh = 0;

  ProfileEntity? _profile(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.session.profile;
    return null;
  }

  Future<void> _refreshAll() async {
    getIt<SyncService>().processOutbox();
    context.read<MesasBloc>().add(LoadMesasByVeedor(widget.veedorId));
    setState(() => _identityRefresh++);
  }

  Widget _buildBanner() {
    final profile = _profile(context);
    if (profile == null) return const SizedBox.shrink();

    return BlocBuilder<MesasBloc, MesasState>(
      builder: (context, mesasState) {
        var recintoId = profile.recintoId;
        if (recintoId == null &&
            mesasState is MesasLoaded &&
            mesasState.mesas.isNotEmpty) {
          recintoId = mesasState.mesas.first.recintoId;
        }

        return IdentityBannerHost(
          profile: profile,
          recintoId: recintoId,
          refreshGeneration: _identityRefresh,
        );
      },
    );
  }

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
                  child: Icon(Icons.cloud_done_rounded, color: Colors.white70),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined, color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sincronizar',
            onPressed: _refreshAll,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBanner(),
          ValueListenableBuilder<int>(
            valueListenable: sync.pendingCount,
            builder: (context, pending, _) => SyncBanner(pendingCount: pending),
          ),
          Expanded(
            child: BlocConsumer<MesasBloc, MesasState>(
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
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshAll,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                final loaded = state as MesasLoaded;
                if (loaded.mesas.isEmpty) {
                  return Center(
                    child: Text(
                      'No tienes mesas asignadas todavía',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: loaded.mesas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final mesa = loaded.mesas[i];
                      return _MesaCard(
                        mesa: mesa,
                        veedorId: widget.veedorId,
                        index: i,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final MesaEntity mesa;
  final String veedorId;
  final int index;

  const _MesaCard({
    required this.mesa,
    required this.veedorId,
    required this.index,
  });

  AppStatusType get _statusType =>
      StatusChip.forMesa(completa: mesa.completa, sinIniciar: mesa.sinIniciar);

  @override
  Widget build(BuildContext context) {
    return SoftCard(
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
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.how_to_vote_rounded,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mesa ${mesa.numeroJrv}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                StatusChip(
                  label: '${mesa.estadoLabel} · ${mesa.actasRegistradas}/2 actas',
                  type: _statusType,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSecondaryColor.withValues(alpha: 0.6),
          ),
        ],
      ),
    ).staggered(index);
  }
}
