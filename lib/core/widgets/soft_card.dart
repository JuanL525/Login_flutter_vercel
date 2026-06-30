import 'package:flutter/material.dart';
import '../theme/app_decorations.dart';
import 'scale_on_tap.dart';

/// Tarjeta blanca con sombra suave y bordes redondeados.
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double radius;
  final Color? color;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.radius = AppDecorations.cardRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: AppDecorations.softSurface(
        color: color,
        radius: radius,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return ScaleOnTap(
      onTap: onTap,
      child: content,
    );
  }
}
