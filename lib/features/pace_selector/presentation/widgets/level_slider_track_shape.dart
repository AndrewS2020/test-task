import 'package:flutter/material.dart';
import '../../domain/level_segment.dart';

class LevelSliderTrackShape extends SliderTrackShape {
  const LevelSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool? isEnabled,
    bool? isDiscrete,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    return Rect.fromLTWH(
      offset.dx,
      (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width - 2 * offset.dx,
      trackHeight,
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = true,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackRect = Rect.fromLTWH(
      offset.dx,
      (parentBox.size.height - trackHeight) / 2,
      parentBox.size.width - 2 * offset.dx,
      trackHeight,
    );

    if (trackRect.width <= 0 || trackRect.height <= 0) return;

    final canvas = context.canvas;
    const double min = 30;
    const double max = 300;
    const double range = max - min;

    double valueToX(double v) {
      return trackRect.left + ((v - min) / range) * trackRect.width;
    }

    const segments = <LevelSegment>[
      LevelSegment(30, 59, Color(0xFFFFD700)),
      LevelSegment(60, 89, Color(0xFF00E676)),
      LevelSegment(90, 119, Color(0xFF42A5F5)),
      LevelSegment(120, 300, Colors.grey),
    ];

    for (final seg in segments) {
      final segMin = seg.start.clamp(min, max);
      final segMax = seg.end.clamp(min, max);
      if (segMin >= segMax) continue;

      final left = valueToX(segMin);
      final right = valueToX(segMax);

      if (left < thumbCenter.dx) {
        final activeLeft = left;
        final activeRight = right < thumbCenter.dx ? right : thumbCenter.dx;
        if (activeRight > activeLeft) {
          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTRB(activeLeft, trackRect.top, activeRight, trackRect.bottom),
            const Radius.circular(4),
          );
          canvas.drawRRect(rrect, Paint()..color = seg.color);
        }
      }

      if (right > thumbCenter.dx) {
        final inactiveLeft = left > thumbCenter.dx ? left : thumbCenter.dx;
        final inactiveRight = right;
        if (inactiveRight > inactiveLeft) {
          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTRB(inactiveLeft, trackRect.top, inactiveRight, trackRect.bottom),
            const Radius.circular(4),
          );
          canvas.drawRRect(rrect, Paint()..color = seg.color.withValues(alpha: 0.2));
        }
      }
    }
  }
}
