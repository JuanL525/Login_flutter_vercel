import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../injection_container.dart';
import '../../../actas/presentation/pages/mesa_actas_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../recintos/domain/entities/recinto_entity.dart';
import '../../../recintos/presentation/pages/recinto_form_page.dart';
import '../../../users/domain/entities/profile_entity.dart';
import '../../../users/presentation/pages/create_user_page.dart';
import '../../domain/entities/mesa_entity.dart';
import '../bloc/mesas_bloc.dart';

/// Pantalla del coordinador de recinto: ver mesas, asignar/reasignar veedores
/// y entrar al detalle (actas) de cada mesa. Tambien la usa el provincial en
/// modo solo lectura (canManage=false).
class MesasRecintoPage extends StatelessWidget {
  final String recintoId;
  final bool canManage;

  /// Cuando se usa como home del coordinador: muestra logout y edicion de su
  /// propio recinto.
  final bool isHome;
  final RecintoEntity? recintoForEdit;

  const MesasRecintoPage({
    super.key,
    required this.recintoId,
    this.canManage = true,
    this.isHome = false,
    this.recintoForEdit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MesasBloc>()..add(LoadMesasByRecinto(recintoId)),
      child: _MesasView(
        recintoId: recintoId,
        canManage: canManage,
        isHome: isHome,
        recintoForEdit: recintoForEdit,
      ),
    );
  }
}

class _MesasView extends StatelessWidget {
  final String recintoId;
  final bool canManage;
  final bool isHome;
  final RecintoEntity? recintoForEdit;
  const _MesasView({
    required this.recintoId,
    required this.canManage,
    required this.isHome,
    this.recintoForEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isHome ? 'Mi recinto' : 'Mesas del recinto'),
        actions: [
          if (isHome && recintoForEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_location_alt_outlined),
              tooltip: 'Editar recinto',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecintoFormPage(recinto: recintoForEdit),
                ),
              ),
            ),
          if (isHome)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(const SignOutRequested()),
            ),
        ],
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => CreateUserPage(
                      role: UserRole.veedor,
                      title: 'Nuevo veedor',
                      recintoId: recintoId,
                    ),
                  ),
                );
                if (created == true && context.mounted) {
                  context
                      .read<MesasBloc>()
                      .add(LoadMesasByRecinto(recintoId));
                }
              },
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Crear veedor'),
            )
          : null,
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
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<MesasBloc>().add(LoadMesasByRecinto(recintoId)),
            );
          }
          final loaded = state as MesasLoaded;
          if (loaded.mesas.isEmpty) {
            return const Center(child: Text('No hay mesas en este recinto'));
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<MesasBloc>().add(LoadMesasByRecinto(recintoId)),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: loaded.mesas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final mesa = loaded.mesas[i];
                return _MesaCard(
                  mesa: mesa,
                  canManage: canManage,
                  veedores: loaded.veedores,
                  recintoId: recintoId,
                );
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
  final bool canManage;
  final List<ProfileEntity> veedores;
  final String recintoId;

  const _MesaCard({
    required this.mesa,
    required this.canManage,
    required this.veedores,
    required this.recintoId,
  });

  Color _statusColor(BuildContext context) {
    if (mesa.completa) return Colors.green;
    if (mesa.sinIniciar) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _statusColor(context).withValues(alpha: 0.15),
          child: Text(
            'JRV',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _statusColor(context),
            ),
          ),
        ),
        title: Text('Mesa ${mesa.numeroJrv}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Veedor: ${mesa.veedorNombre ?? 'sin asignar'}'),
            Text(
              '${mesa.estadoLabel} (${mesa.actasRegistradas}/2 actas)',
              style: TextStyle(color: _statusColor(context)),
            ),
          ],
        ),
        trailing: canManage
            ? IconButton(
                icon: const Icon(Icons.manage_accounts_outlined),
                tooltip: 'Asignar veedor',
                onPressed: () => _showAssignSheet(context),
              )
            : const Icon(Icons.chevron_right),
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
      ),
    );
  }

  void _showAssignSheet(BuildContext context) {
    final bloc = context.read<MesasBloc>();
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Asignar veedor a la mesa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              if (veedores.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay veedores. Crea uno primero.'),
                ),
              ...veedores.map(
                (v) => ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(v.nombreCompleto),
                  subtitle: Text('Cedula: ${v.cedula}'),
                  trailing: mesa.veedorId == v.id
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
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
                ),
              ),
              if (mesa.veedorId != null)
                ListTile(
                  leading: const Icon(Icons.person_off, color: Colors.red),
                  title: const Text('Quitar asignacion'),
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
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
