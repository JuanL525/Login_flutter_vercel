import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/screen_entrance.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/user_message_dialog.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../mesas/presentation/pages/mesas_recinto_page.dart';
import '../../../recintos/presentation/pages/recinto_form_page.dart';
import '../../../users/domain/entities/profile_entity.dart';
import '../../../users/domain/repositories/users_repository.dart';
import '../../../users/presentation/pages/create_user_page.dart';
import '../../domain/entities/recinto_avance.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/identity_banner_host.dart';
import 'informe_votos_page.dart';

class ProvincialHomePage extends StatelessWidget {
  const ProvincialHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DashboardBloc>()..add(const LoadProvincialAvance()),
      child: const _ProvincialView(),
    );
  }
}

class _ProvincialView extends StatefulWidget {
  const _ProvincialView();

  @override
  State<_ProvincialView> createState() => _ProvincialViewState();
}

class _ProvincialViewState extends State<_ProvincialView> {
  int _identityRefresh = 0;

  ProfileEntity? _profile(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.session.profile;
    return null;
  }

  void _refreshAll() {
    context.read<DashboardBloc>().add(const LoadProvincialAvance());
    setState(() => _identityRefresh++);
  }

  Widget _buildBanner(BuildContext context) {
    final profile = _profile(context);
    if (profile == null) return const SizedBox.shrink();
    return IdentityBannerHost(
      profile: profile,
      loadProvincia: true,
      refreshGeneration: _identityRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinación Provincial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Informe de votos',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const InformeVotosPage(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recargar',
            onPressed: _refreshAll,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                context.read<AuthBloc>().add(const SignOutRequested()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const RecintoFormPage()),
          );
          if (created == true && context.mounted) {
            _refreshAll();
          }
        },
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Nuevo recinto'),
      ),
      body: Column(
        children: [
          _buildBanner(context),
          Expanded(
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is DashboardError) {
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
                final loaded = state as DashboardLoaded;
                if (loaded.avances.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay recintos registrados',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _refreshAll(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: loaded.avances.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _RecintoCard(
                      avance: loaded.avances[i],
                      onChanged: _refreshAll,
                      index: i,
                    ),
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

Future<void> _showAsignarCoordinadorSheet(
  BuildContext context, {
  required String recintoId,
  required String recintoNombre,
  required VoidCallback onAssigned,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _AsignarCoordinadorSheet(
      recintoId: recintoId,
      recintoNombre: recintoNombre,
      onAssigned: onAssigned,
    ),
  );
}

class _AsignarCoordinadorSheet extends StatefulWidget {
  final String recintoId;
  final String recintoNombre;
  final VoidCallback onAssigned;
  const _AsignarCoordinadorSheet({
    required this.recintoId,
    required this.recintoNombre,
    required this.onAssigned,
  });

  @override
  State<_AsignarCoordinadorSheet> createState() =>
      _AsignarCoordinadorSheetState();
}

class _AsignarCoordinadorSheetState extends State<_AsignarCoordinadorSheet> {
  List<ProfileEntity>? _coordinadores;
  bool _loading = true;
  bool _assigning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result =
        await getIt<UsersRepository>().getCoordinadoresSinRecinto();
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (list) => setState(() {
        _coordinadores = list;
        _loading = false;
      }),
    );
  }

  Future<void> _assign(ProfileEntity coordinador) async {
    setState(() => _assigning = true);
    final result = await getIt<UsersRepository>().assignCoordinadorToRecinto(
      coordinadorId: coordinador.id,
      recintoId: widget.recintoId,
    );
    if (!mounted) return;
    setState(() => _assigning = false);
    result.fold(
      (f) async {
        await UserMessageDialog.showError(
          context,
          title: 'No se pudo asignar',
          message: f.message,
        );
      },
      (_) async {
        await UserMessageDialog.showSuccess(
          context,
          title: 'Coordinador asignado',
          message:
              '${coordinador.nombreCompleto} fue asignado a ${widget.recintoNombre}.',
          buttonText: 'Listo',
        );
        if (mounted) {
          Navigator.of(context).pop();
          widget.onAssigned();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asignar coordinador',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              widget.recintoNombre,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Solo coordinadores sin recinto asignado.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (_loading || _assigning)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              )
            else if (_coordinadores == null || _coordinadores!.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No hay coordinadores sin recinto.\n'
                    'Crea uno con "Crear y asignar coordinador".',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _coordinadores!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final c = _coordinadores![i];
                    return SoftCard(
                      onTap: () => _assign(c),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      radius: 16,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.nombreCompleto,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'C.I.: ${c.cedula}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecintoCard extends StatelessWidget {
  final RecintoAvance avance;
  final VoidCallback onChanged;
  final int index;

  const _RecintoCard({
    required this.avance,
    required this.onChanged,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final recinto = avance.recinto;
    final sinCoordinador = recinto.coordinadorId == null;
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  recinto.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final ok = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => RecintoFormPage(recinto: recinto),
                      ),
                    );
                    if (ok == true && context.mounted) onChanged();
                  } else if (value == 'coordinador') {
                    if (!sinCoordinador) {
                      await UserMessageDialog.showError(
                        context,
                        title: 'Recinto ocupado',
                        message:
                            'Este recinto ya tiene un coordinador asignado.',
                      );
                      return;
                    }
                    final ok = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CreateUserPage(
                          role: UserRole.recinto,
                          title: 'Crear coordinador',
                          recintoId: recinto.id,
                        ),
                      ),
                    );
                    if (ok == true && context.mounted) onChanged();
                  } else if (value == 'asignar') {
                    if (!sinCoordinador) {
                      await UserMessageDialog.showError(
                        context,
                        title: 'Recinto ocupado',
                        message:
                            'Este recinto ya tiene un coordinador asignado.',
                      );
                      return;
                    }
                    await _showAsignarCoordinadorSheet(
                      context,
                      recintoId: recinto.id,
                      recintoNombre: recinto.nombre,
                      onAssigned: onChanged,
                    );
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar recinto'),
                  ),
                  if (sinCoordinador) ...[
                    const PopupMenuItem(
                      value: 'coordinador',
                      child: Text('Crear y asignar coordinador'),
                    ),
                    const PopupMenuItem(
                      value: 'asignar',
                      child: Text('Asignar coordinador existente'),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Text(
            '${recinto.parroquia}, ${recinto.canton}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          StatusChip(
            label: sinCoordinador
                ? 'Sin coordinador'
                : 'Coordinador asignado',
            type: sinCoordinador ? AppStatusType.warning : AppStatusType.success,
            icon: sinCoordinador
                ? Icons.person_off_outlined
                : Icons.person_outline,
          ),
          if (!sinCoordinador &&
              (avance.coordinadorNombre?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    avance.coordinadorNombre!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            if (avance.coordinadorCedula != null) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Text(
                  'C.I.: ${avance.coordinadorCedula}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: avance.porcentaje,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Actas: ${avance.actasRegistradas}/${avance.actasEsperadas} '
            '(${(avance.porcentaje * 100).toStringAsFixed(0)}%) · '
            '${avance.totalMesas} mesas',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MesasRecintoPage(
                      recintoId: recinto.id,
                      canManage: false,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Ver mesas y actas'),
            ),
          ),
        ],
      ),
    ).staggered(index);
  }
}
