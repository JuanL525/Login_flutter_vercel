import 'package:flutter/material.dart';
import '../../../users/domain/entities/profile_entity.dart';

/// Banner de identidad que se muestra en el home de cada rol.
/// Muestra nombre, cédula, rol y, opcionalmente, provincia o recinto.
class IdentityBanner extends StatelessWidget {
  final ProfileEntity profile;
  final String? provinciaNombre;
  final String? recintoNombre;
  final String? recintoUbicacion;

  const IdentityBanner({
    super.key,
    required this.profile,
    this.provinciaNombre,
    this.recintoNombre,
    this.recintoUbicacion,
  });

  String get _initials {
    final n = profile.nombres.trim();
    final a = profile.apellidos.trim();
    return '${n.isNotEmpty ? n[0] : ''}${a.isNotEmpty ? a[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: cs.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: cs.primary,
              child: Text(
                _initials,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.nombreCompleto,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    text: 'C.I.: ${profile.cedula}',
                    color: cs.onPrimaryContainer,
                  ),
                  _InfoRow(
                    icon: Icons.manage_accounts_outlined,
                    text: profile.role.label,
                    color: cs.onPrimaryContainer,
                  ),
                  if (provinciaNombre != null)
                    _InfoRow(
                      icon: Icons.map_outlined,
                      text: 'Provincia: $provinciaNombre',
                      color: cs.onPrimaryContainer,
                      bold: true,
                    ),
                  if (recintoNombre != null) ...[
                    _InfoRow(
                      icon: Icons.location_city,
                      text: recintoNombre!,
                      color: cs.onPrimaryContainer,
                      bold: true,
                    ),
                    if (recintoUbicacion != null)
                      _InfoRow(
                        icon: Icons.place_outlined,
                        text: recintoUbicacion!,
                        color: cs.onPrimaryContainer,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color.withValues(alpha: bold ? 1.0 : 0.85),
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
