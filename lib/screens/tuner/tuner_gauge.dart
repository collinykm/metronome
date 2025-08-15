import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:metronome_app/theme/colors.dart';
import 'package:provider/provider.dart';
import "package:metronome_app/service/tuner_provider.dart";

class TunerGauge extends StatelessWidget {
  const TunerGauge({super.key, this.size = 360});
  final double size;

  @override
  Widget build(BuildContext context) {
    final int cents = context.select<TunerProvider, int?>((p) => p.cents) ?? 0;



    //new idea: map from 15 degrees to 165 degrees
    final double targetAngle = -(cents-50)/100*(5/6*math.pi) + math.pi/12;
  //-50 = 1    50 = 0
    return SizedBox(
      height: size * 0.6,
      child: Transform.translate(
        offset: Offset(0,size * 0.21),   //this 0.21 is a sketchy ahh number i have no clue how it works

          //0.5*size for the radius, and 0.1*size for the tail of the needle
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: targetAngle),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            builder: (_, value, __) => CustomPaint(
              size: Size.square(size),
              painter: _GaugePainter(angle: value),
            ),
          ),

      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.angle});
  final double angle; // radians in [0‥π]

  static const double _startAngle = -math.pi/12;         // rightmost
  static const double _sweep      = -math.pi*5/6;  // CCW for top half

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    // Background arc -------------------------------------------------------
    /*
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
  */
    // Tick marks -----------------------------------------------------------
    final Paint tick = Paint()
      ..strokeCap = StrokeCap.round;

    for (int i = -50; i <= 50; i += 1) {
      final double a = ((i + 50) / 100) * 5/6*math.pi + math.pi/12; // 0..π rad
      final double cosA = math.cos(a);
      final double sinA = math.sin(a);
      final bool major = i % 10 == 0;
      final double len = major ? 14 : 8;
      if (i.abs() <= 10) {
        tick.color = AppColors.primary;
        tick.strokeWidth = 2;
      } else if (i % 10 == 0) {
        tick.color = Colors.grey.shade600;
        tick.strokeWidth = 2;
      } else {
        tick.color = Colors.grey.shade400;
        tick.strokeWidth = 1;
      }


      final Offset outer = center + Offset(cosA, -sinA) * (radius);
      final Offset inner = outer - Offset(cosA, -sinA) * len;
      canvas.drawLine(outer, inner, tick);
    }

    // Needle ---------------------------------------------------------------
    final Paint needle = Paint()
      ..color = AppColors.accent2
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final double cosN = math.cos(angle);
    final double sinN = math.sin(angle);
    final Offset tip  = center + Offset(cosN, -sinN) * (radius * 0.75);
    final Offset tail = center - Offset(cosN, -sinN) * (radius * 0.1);
    canvas.drawLine(tail, tip, needle);
    canvas.drawCircle(center, 6, Paint()..color = AppColors.accent2);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.angle != angle;
}


class GaugeClipper extends CustomClipper<Rect> {
  final double height;
  GaugeClipper(this.height);

  @override
  Rect getClip(Size size) {
    final double toCrop = (size.height - height) / 2;
    return Rect.fromLTWH(0, 0, size.width, height);
  }

  @override
  bool shouldReclip(GaugeClipper oldClipper) =>
      oldClipper.height != height;

  
}