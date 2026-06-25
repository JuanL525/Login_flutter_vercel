import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../mesas/presentation/pages/mesas_recinto_page.dart';
import '../../../recintos/presentation/pages/recinto_form_page.dart';
import '../../../users/presentation/pages/create_user_page.dart';
import '../../domain/entities/recinto_avance.dart';
import '../bloc/dashboard_bloc.dart';

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

class _ProvincialView extends StatelessWidget {
  const _ProvincialView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinacion Provincial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            context.read<DashboardBloc>().add(const LoadProvincialAvance());
          }
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Nuevo recinto'),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
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
                        .read<DashboardBloc>()
                        .add(const LoadProvincialAvance()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final loaded = state as DashboardLoaded;
          if (loaded.avances.isEmpty) {
            return const Center(child: Text('No hay recintos registrados'));
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<DashboardBloc>()
                .add(const LoadProvincialAvance()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: loaded.avances.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _RecintoCard(avance: loaded.avances[i]),
            ),
          );
        },
      ),
    );
  }
}

class _RecintoCard extends StatelessWidget {
  final RecintoAvance avance;
  const _RecintoCard({required this.avance});

  void _refresh(BuildContext context) =>
      context.read<DashboardBloc>().add(const LoadProvincialAvance());

  @override
  Widget build(BuildContext context) {
    final recinto = avance.recinto;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recinto.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final ok = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => RecintoFormPage(recinto: recinto),
                        ),
                      );
                      if (ok == true && context.mounted) _refresh(context);
                    } else if (value == 'coordinador') {
                      final ok = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => CreateUserPage(
                            role: UserRole.recinto,
                            title: 'Crear coordinador',
                            recintoId: recinto.id,
                          ),
                        ),
                      );
                      if (ok == true && context.mounted) _refresh(context);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar recinto'),
                    ),
                    const PopupMenuItem(
                      value: 'coordinador',
                      child: Text('Crear y asignar coordinador'),
                    ),
                  ],
                ),
              ],
            ),
            Text('${recinto.parroquia}, ${recinto.canton}'),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: avance.porcentaje,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Actas: ${avance.actasRegistradas}/${avance.actasEsperadas} '
              '(${(avance.porcentaje * 100).toStringAsFixed(0)}%) - '
              '${avance.totalMesas} mesas',
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }
}
