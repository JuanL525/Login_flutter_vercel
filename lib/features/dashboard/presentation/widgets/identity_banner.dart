import 'package:flutter/material.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../users/domain/entities/profile_entity.dart';

/// Banner de identidad que se muestra en el home de cada rol.
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.softSurface(radius: 24).copyWith(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.badge_outlined,
                  text: 'C.I.: ${profile.cedula}',
                ),
                _InfoRow(
                  icon: Icons.manage_accounts_outlined,
                  text: profile.role.label,
                ),
                if (provinciaNombre != null)
                  _InfoRow(
                    icon: Icons.map_outlined,
                    text: 'Provincia: $provinciaNombre',
                    bold: true,
                  ),
                if (recintoNombre != null) ...[
                  _InfoRow(
                    icon: Icons.location_city_outlined,
                    text: recintoNombre!,
                    bold: true,
                  ),
                  if (recintoUbicacion != null)
                    _InfoRow(
                      icon: Icons.place_outlined,
                      text: recintoUbicacion!,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white60),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: bold ? 1.0 : 0.85),
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
