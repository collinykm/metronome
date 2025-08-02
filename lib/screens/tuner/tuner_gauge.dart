// tuner_gauge.dart
// Horizontal (top‑half) gauge where
//   • −50 ¢  = RIGHT edge
//   • +50 ¢  = LEFT  edge
//   0 ¢ dead‑centre
// Typical tuner convention: flat→right, sharp→left (mirror previous version).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:metronome_app/service/tuner_provider.dart";

class TunerGauge extends StatelessWidget {
  const TunerGauge({super.key, this.size = 240});
  final double size;

  @override
  Widget build(BuildContext context) {
    final int cents = context.select<TunerProvider, int?>((p) => p.cents) ?? 0;
    final List<dynamic> tuningOutputArray = context.select<TunerProvider, List<dynamic>?>((p) => p.tuningOutputArray) ?? [];

    // Map –50 → 0 rad (right),  +50 → π rad (left)

    final double targetAngle = -(cents-50)/100*math.pi;
  //-50 = 1    50 = 0
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween<double>(end: targetAngle),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (_, value, __) => CustomPaint(
            size: Size.square(size),
            painter: _GaugePainter(angle: value),
          ),
        ),
        Text("$tuningOutputArray")
        
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.angle});
  final double angle; // radians in [0‥π]

  static const double _startAngle = 0;         // rightmost
  static const double _sweep      = -math.pi;  // CCW for top half

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    // Background arc -------------------------------------------------------
    final Paint arc = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.9),
      _startAngle,
      _sweep,
      false,
      arc,
    );

    // Tick marks -----------------------------------------------------------
    final Paint tick = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    for (int i = -50; i <= 50; i += 5) {
      final double a = ((i + 50) / 100) * math.pi; // 0..π rad
      final double cosA = math.cos(a);
      final double sinA = math.sin(a);
      final bool major = i % 10 == 0;
      final double len = major ? 14 : 8;
      tick.color = i.abs() <= 10 ? Colors.greenAccent : Colors.grey.shade600;

      final Offset outer = center + Offset(cosA, -sinA) * (radius * 0.9);
      final Offset inner = outer - Offset(cosA, -sinA) * len;
      canvas.drawLine(outer, inner, tick);
    }

    // Needle ---------------------------------------------------------------
    final Paint needle = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final double cosN = math.cos(angle);
    final double sinN = math.sin(angle);
    final Offset tip  = center + Offset(cosN, -sinN) * (radius * 0.75);
    final Offset tail = center - Offset(cosN, -sinN) * (radius * 0.1);
    canvas.drawLine(tail, tip, needle);
    canvas.drawCircle(center, 6, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.angle != angle;
}
