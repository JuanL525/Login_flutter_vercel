import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animaciones de entrada fade + slide-up y cascada.
extension ScreenEntrance on Widget {
  Widget fadeSlideUp({
    Duration delay = Duration.zero,
    Duration duration = const Duration(milliseconds: 500),
    double dy = 24,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOutCubic)
        .slideY(
          begin: dy / 100,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  Widget staggered(int index, {Duration baseDelay = const Duration(milliseconds: 100)}) {
    return fadeSlideUp(delay: baseDelay * index);
  }
}
