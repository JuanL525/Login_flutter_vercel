import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/screen_entrance.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../injection_container.dart';
import '../../../actas/presentation/pages/mesa_actas_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../recintos/domain/entities/recinto_entity.dart';
import '../../../recintos/presentation/pages/recinto_form_page.dart';
import '../../../users/domain/entities/profile_entity.dart';
import '../../../users/presentation/pages/create_user_page.dart';
import '../../../../features/dashboard/presentation/widgets/identity_banner.dart';
import '../../../../features/dashboard/presentation/widgets/identity_context.dart';
import '../../domain/entities/mesa_entity.dart';
import '../bloc/mesas_bloc.dart';

/// Pantalla del coordinador de recinto: ver mesas, asignar/reasignar veedores
/// y entrar al detalle (actas) de cada mesa.
class MesasRecintoPage extends StatelessWidget {
  final String recintoId;
  final bool canManage;
  final bool isHome;

  const MesasRecintoPage({
    super.key,
    required this.recintoId,
    this.canManage = true,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MesasBloc>()..add(LoadMesasByRecinto(recintoId)),
      child: _MesasView(
        recintoId: recintoId,
        canManage: canManage,
        isHome: isHome,
      ),
    );
  }
}

class _MesasView extends StatefulWidget {
  final String recintoId;
  final bool canManage;
  final bool isHome;
  const _MesasView({
    required this.recintoId,
    required this.canManage,
    required this.isHome,
  });

  @override
  State<_MesasView> createState() => _MesasViewState();
}

class _MesasViewState extends State<_MesasView> {
  RecintoEntity? _recinto;

  @override
  void initState() {
    super.initState();
    if (widget.isHome) _reloadRecinto();
  }

  Future<void> _reloadRecinto() async {
    final recinto = await IdentityContext.recintoById(widget.recintoId);
    if (mounted) setState(() => _recinto = recinto);
  }

  Future<void> _refreshAll() async {
    context.read<MesasBloc>().add(LoadMesasByRecinto(widget.recintoId));
    if (widget.isHome) await _reloadRecinto();
  }

  ProfileEntity? _profile(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.session.profile;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final r = _recinto;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isHome ? (r?.nombre ?? 'Mi recinto') : 'Mesas del recinto',
        ),
        actions: [
          if (widget.isHome)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Recargar',
              onPressed: _refreshAll,
            ),
          if (widget.isHome && r != null)
            IconButton(
              icon: const Icon(Icons.edit_location_alt_outlined),
              tooltip: 'Editar recinto',
              onPressed: () async {
                final ok = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => RecintoFormPage(recinto: r),
                  ),
                );
                if (ok == true && mounted) await _refreshAll();
              },
            ),
          if (widget.isHome)
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () =>
                  context.read<AuthBloc>().add(const SignOutRequested()),
            ),
        ],
      ),
      floatingActionButton: widget.canManage
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => CreateUserPage(
                      role: UserRole.veedor,
                      title: 'Nuevo veedor',
                      recintoId: widget.recintoId,
                    ),
                  ),
                );
                if (created == true && mounted) {
                  context
                      .read<MesasBloc>()
                      .add(LoadMesasByRecinto(widget.recintoId));
                }
              },
              icon: const Icon(Icons.person_add_alt_outlined),
              label: const Text('Crear veedor'),
            )
          : null,
      body: Column(
        children: [
          if (widget.isHome) ...[
            Builder(
              builder: (context) {
                final profile = _profile(context);
                if (profile == null) return const SizedBox.shrink();
                return IdentityBanner(
                  profile: profile,
                  recintoNombre: r?.nombre,
                  recintoUbicacion:
                      r != null ? '${r.parroquia}, ${r.canton}' : null,
                );
              },
            ),
          ],
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
                  return _ErrorView(
                    message: state.message,
                    onRetry: _refreshAll,
                  );
                }
                final loaded = state as MesasLoaded;
                if (loaded.mesas.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refreshAll,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            'No hay mesas en este recinto',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
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
                        canManage: widget.canManage,
                        veedores: loaded.veedores,
                        recintoId: widget.recintoId,
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
  final bool canManage;
  final List<ProfileEntity> veedores;
  final String recintoId;
  final int index;

  const _MesaCard({
    required this.mesa,
    required this.canManage,
    required this.veedores,
    required this.recintoId,
    required this.index,
  });

  AppStatusType get _statusType =>
      StatusChip.forMesa(completa: mesa.completa, sinIniciar: mesa.sinIniciar);

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MesaActasPage(
              mesaId: mesa.id,
              numeroJrv: mesa.numeroJrv,
              readOnly: !canManage,
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              '${mesa.numeroJrv}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryColor,
              ),
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
                const SizedBox(height: 4),
                Text(
                  'Veedor: ${mesa.veedorNombre ?? 'sin asignar'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 6),
                StatusChip(
                  label: '${mesa.estadoLabel} · ${mesa.actasRegistradas}/2',
                  type: _statusType,
                ),
              ],
            ),
          ),
          if (canManage)
            IconButton(
              icon: const Icon(Icons.manage_accounts_outlined),
              tooltip: 'Asignar veedor',
              onPressed: () => _showAssignSheet(context),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondaryColor.withValues(alpha: 0.6),
            ),
        ],
      ),
    ).staggered(index);
  }

  void _showAssignSheet(BuildContext context) {
    final bloc = context.read<MesasBloc>();
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asignar veedor',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mesa ${mesa.numeroJrv}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (veedores.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No hay veedores. Crea uno primero.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...veedores.map(
                    (v) => SoftCard(
                      onTap: () {
                        bloc.add(
                          AssignVeedorRequested(
                            mesaId: mesa.id,
                            veedorId: v.id,
                            recintoId: recintoId,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      radius: 16,
                      margin: const EdgeInsets.only(bottom: 8),
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
                                Text(v.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600)),
                                Text('Cédula: ${v.cedula}', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          if (mesa.veedorId == v.id)
                            const Icon(Icons.check_circle, color: AppTheme.successColor),
                        ],
                      ),
                    ),
                  ),
                if (mesa.veedorId != null)
                  ListTile(
                    leading: Icon(Icons.person_off_outlined, color: Theme.of(context).colorScheme.error),
                    title: const Text('Quitar asignación'),
                    onTap: () {
                      bloc.add(
                        AssignVeedorRequested(
                          mesaId: mesa.id,
                          veedorId: null,
                          recintoId: recintoId,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
