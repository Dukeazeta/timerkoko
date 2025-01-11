import 'package:flutter/material.dart';
import 'dart:math' as math;

class TimerPainter extends StatelessWidget {
  final double progress;
  final bool isRunning;

  const TimerPainter({
    super.key,
    required this.progress,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TimerPainterCanvas(
        progress: progress,
        isRunning: isRunning,
      ),
      size: const Size(300, 300),
    );
  }
}

class _TimerPainterCanvas extends CustomPainter {
  final double progress;
  final bool isRunning;

  _TimerPainterCanvas({
    required this.progress,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius - 20, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      -math.pi / 2,
      2 * math.pi * progress,
      true,
      progressPaint,
    );

    // Draw minute markers
    for (var i = 0; i < 60; i++) {
      final angle = i * (2 * math.pi / 60) - math.pi / 2;
      final isMainMarker = i % 5 == 0;
      final markerLength = isMainMarker ? 12.0 : 6.0;
      final markerWidth = isMainMarker ? 2.0 : 1.0;
      
      final start = Offset(
        center.dx + (radius - markerLength - 20) * math.cos(angle),
        center.dy + (radius - markerLength - 20) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 20) * math.cos(angle),
        center.dy + (radius - 20) * math.sin(angle),
      );

      final markerPaint = Paint()
        ..color = Colors.black.withOpacity(isMainMarker ? 0.5 : 0.3)
        ..strokeWidth = markerWidth;

      canvas.drawLine(start, end, markerPaint);

      if (isMainMarker) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${i == 0 ? 60 : i}',
            style: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            center.dx + (radius - 40) * math.cos(angle) - textPainter.width / 2,
            center.dy + (radius - 40) * math.sin(angle) - textPainter.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TimerPainterCanvas oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isRunning != isRunning;
  }
}
