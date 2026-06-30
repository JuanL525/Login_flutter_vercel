import 'package:flutter/material.dart';

/// Texto de boton con altura de linea y multilinea para evitar recortes.
class AppButtonLabel extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final int maxLines;
  final Color? color;

  const AppButtonLabel(
    this.text, {
    super.key,
    this.textAlign = TextAlign.center,
    this.maxLines = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.visible,
      softWrap: true,
      style: TextStyle(
        height: 1.25,
        color: color,
      ),
    );
  }
}
