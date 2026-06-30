import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Banner flotante curvo para sincronizacion pendiente.
class SyncBanner extends StatelessWidget {
  final int pendingCount;

  const SyncBanner({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    if (pendingCount <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.15),
            AppTheme.accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_upload_outlined, color: AppTheme.accentColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$pendingCount acta${pendingCount == 1 ? '' : 's'} pendiente${pendingCount == 1 ? '' : 's'} de sincronizar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentColor.withValues(alpha: 0.95),
              ),
            ),
          ),
          Icon(Icons.sync, size: 18, color: AppTheme.accentColor.withValues(alpha: 0.8)),
        ],
      ),
    );
  }
}
