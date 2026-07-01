import 'package:flutter/material.dart';
import '../constants/app_branding.dart';
import '../theme/app_decorations.dart';

/// Logotipo oficial de Control Electoral.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 112,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.22),
              boxShadow: AppDecorations.softShadow,
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          AppBranding.logoAsset,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.how_to_vote_rounded,
            size: size * 0.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
