import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/seeds/organizaciones_seed.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/votos_consolidados.dart';
import '../bloc/votos_bloc.dart';

class InformeVotosPage extends StatelessWidget {
  const InformeVotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VotosBloc>()..add(const LoadVotos()),
      child: const _InformeView(),
    );
  }
}

class _InformeView extends StatelessWidget {
  const _InformeView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informe de Votos'),
          actions: [
            BlocBuilder<VotosBloc, VotosState>(
              builder: (context, state) => IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Recargar',
                onPressed: state is VotosLoading
                    ? null
                    : () => context.read<VotosBloc>().add(const LoadVotos()),
              ),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.location_city), text: 'Alcalde'),
              Tab(icon: Icon(Icons.map_outlined), text: 'Prefecto'),
            ],
          ),
        ),
        body: BlocBuilder<VotosBloc, VotosState>(
          builder: (context, state) {
            if (state is VotosLoading || state is VotosInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is VotosError) {
              return _ErrorBody(
                message: state.message,
                onRetry: () =>
                    context.read<VotosBloc>().add(const LoadVotos()),
              );
            }

            final loaded = state as VotosLoaded;
            final alcalde = loaded.consolidados.firstWhere(
              (c) => c.dignidad == Dignidad.alcalde,
              orElse: () => const VotosConsolidados(
                dignidad: Dignidad.alcalde,
                totalPorOrg: {},
                totalBlancos: 0,
                totalNulos: 0,
                totalSufragantes: 0,
                actasContadas: 0,
                actasEsperadas: 0,
                porRecinto: [],
              ),
            );
            final prefecto = loaded.consolidados.firstWhere(
              (c) => c.dignidad == Dignidad.prefecto,
              orElse: () => const VotosConsolidados(
                dignidad: Dignidad.prefecto,
                totalPorOrg: {},
                totalBlancos: 0,
                totalNulos: 0,
                totalSufragantes: 0,
                actasContadas: 0,
                actasEsperadas: 0,
                porRecinto: [],
              ),
            );

            return TabBarView(
              children: [
                _DignidadTab(consolidado: alcalde),
                _DignidadTab(consolidado: prefecto),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab de una dignidad
// ─────────────────────────────────────────────────────────────────────────────

class _DignidadTab extends StatelessWidget {
  final VotosConsolidados consolidado;
  const _DignidadTab({required this.consolidado});

  List<OrganizacionPolitica> get _orgs =>
      organizacionesPorDignidad(consolidado.dignidad);

  @override
  Widget build(BuildContext context) {
    final orgs = _orgs;
    // Ordenar por votos descendente para ranking
    final sorted = [...orgs]..sort((a, b) =>
        consolidado.votosOrg(b.id).compareTo(consolidado.votosOrg(a.id)));

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<VotosBloc>().add(const LoadVotos()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _AvanceCard(consolidado: consolidado),
          const SizedBox(height: 16),
          const SectionLabel('Resultados globales'),
          const SizedBox(height: 4),
          if (consolidado.actasContadas == 0)
            const _EmptyCard(
              mensaje: 'Aún no hay actas registradas para esta dignidad.',
            )
          else ...[
            ...sorted.asMap().entries.map((entry) {
              final rank = entry.key;
              final org = entry.value;
              return _CandidatoCard(
                rank: rank,
                org: org,
                votos: consolidado.votosOrg(org.id),
                porcentaje: consolidado.porcentajeOrg(org.id),
                totalVotos: consolidado.totalVotos,
              );
            }),
            _OtrosVotosRow(
              blancos: consolidado.totalBlancos,
              nulos: consolidado.totalNulos,
              totalVotos: consolidado.totalVotos,
            ),
          ],
          const SizedBox(height: 20),
          const SectionLabel('Desglose por recinto'),
          const SizedBox(height: 4),
          if (consolidado.porRecinto.isEmpty)
            const _EmptyCard(mensaje: 'Sin datos por recinto todavía.')
          else
            ...consolidado.porRecinto.map(
              (r) => _RecintoExpansion(
                desglose: r,
                orgs: orgs,
                totalVotos: consolidado.totalVotos,
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de avance
// ─────────────────────────────────────────────────────────────────────────────

class _AvanceCard extends StatelessWidget {
  final VotosConsolidados consolidado;
  const _AvanceCard({required this.consolidado});

  @override
  Widget build(BuildContext context) {
    final pct = consolidado.porcentajeAvance;

    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cobertura: ${consolidado.actasContadas}/'
                  '${consolidado.actasEsperadas} actas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
              ),
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
            ),
          ),
          if (consolidado.totalSufragantes > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.how_to_vote_outlined,
                    size: 14, color: AppTheme.textSecondaryColor),
                const SizedBox(width: 6),
                Text(
                  'Sufragantes contabilizados: ${consolidado.totalSufragantes}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card por candidato
// ─────────────────────────────────────────────────────────────────────────────

const _kMedalColors = [
  Color(0xFFFFD700), // oro
  Color(0xFFC0C0C0), // plata
  Color(0xFFCD7F32), // bronce
];

class _CandidatoCard extends StatelessWidget {
  final int rank;
  final OrganizacionPolitica org;
  final int votos;
  final double porcentaje;
  final int totalVotos;

  const _CandidatoCard({
    required this.rank,
    required this.org,
    required this.votos,
    required this.porcentaje,
    required this.totalVotos,
  });

  Color _rankColor(BuildContext context) {
    if (rank < 3) return _kMedalColors[rank];
    return Theme.of(context).colorScheme.primary.withValues(alpha: 0.7);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pctStr = '${(porcentaje * 100).toStringAsFixed(1)}%';

    return SoftCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 18, 14),
      child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _rankColor(context).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${rank + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _rankColor(context),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org.candidato,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${org.nombre} · ${org.lista}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: porcentaje,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                    color: _rankColor(context),
                    backgroundColor:
                        _rankColor(context).withValues(alpha: 0.15),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$votos',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  pctStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fila de votos blancos/nulos
// ─────────────────────────────────────────────────────────────────────────────

class _OtrosVotosRow extends StatelessWidget {
  final int blancos;
  final int nulos;
  final int totalVotos;

  const _OtrosVotosRow({
    required this.blancos,
    required this.nulos,
    required this.totalVotos,
  });

  String _pct(int v) => totalVotos == 0
      ? '0%'
      : '${(v / totalVotos * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: _SmallChip(
              label: 'Blancos',
              value: '$blancos (${_pct(blancos)})',
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SmallChip(
              label: 'Nulos',
              value: '$nulos (${_pct(nulos)})',
              color: Colors.red.shade300,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SmallChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expansion por recinto
// ─────────────────────────────────────────────────────────────────────────────

class _RecintoExpansion extends StatelessWidget {
  final VotosRecintoDesglose desglose;
  final List<OrganizacionPolitica> orgs;
  final int totalVotos;

  const _RecintoExpansion({
    required this.desglose,
    required this.orgs,
    required this.totalVotos,
  });

  String _pctGlobal(int v) => totalVotos == 0
      ? '0%'
      : '${(v / totalVotos * 100).toStringAsFixed(1)}%';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalRecinto = desglose.votosPorOrg.values.fold(0, (a, b) => a + b) +
        desglose.blancos +
        desglose.nulos;

    return SoftCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        leading: Icon(Icons.school_outlined, color: cs.primary),
        title: Text(
          desglose.recintoNombre,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${desglose.actasContadas}/${desglose.actasEsperadas} actas '
          '· ${desglose.sufragantes} sufragantes',
          style: TextStyle(
              fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          LinearProgressIndicator(
            value: desglose.porcentajeAvance,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 10),
          ...orgs.map((org) {
            final v = desglose.votosPorOrg[org.id] ?? 0;
            final pct = totalRecinto == 0 ? 0.0 : v / totalRecinto;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      org.candidato,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      backgroundColor:
                          cs.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: Text(
                      '$v (${_pctGlobal(v)})',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),
          Row(
            children: [
              Text(
                'Blancos: ${desglose.blancos}  '
                'Nulos: ${desglose.nulos}',
                style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.55)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  final String mensaje;
  const _EmptyCard({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
