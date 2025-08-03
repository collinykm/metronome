import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'dart:math' as math;

class TempoKnob extends StatefulWidget {
  const TempoKnob({super.key, this.diameter = 240});

  final double diameter; 
  @override
  State<TempoKnob> createState() => _TempoKnobState();
}

class _TempoKnobState extends State<TempoKnob> {
  
  late ValueNotifier<int> _ctrNotifier;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrNotifier = context.read<MetronomeProvider>().tempoListenable;
      _ctrNotifier.addListener(_onCounterChanged);
    });
    super.initState();
  }

  void _onCounterChanged() {
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final metronome = Provider.of<MetronomeProvider>(context, listen: false);
    final angle = metronome.totalAngle;

    return GestureDetector(
      onPanStart: (d) {

        metronome.setPreviousOffset(d.localPosition);
      } ,
      onPanUpdate: (details) {
        metronome.handleSpin(details);
      },
      onPanEnd: (_) => metronome.setPreviousOffset(null),

      // INNER-SHADOW stays fixed
      child: InnerShadow(
        shadows: [
          Shadow(
            color: AppColors.shadowColor.withOpacity(.25),
            blurRadius: 4,
            offset: const Offset(5, 6),
          )
        ],
        //Note: big circle
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: widget.diameter,
            height: widget.diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow( // DROP SHADOW
                  color: AppColors.shadowColor.withOpacity(.25),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),

            // Everything inside rotates
            child: AnimatedRotation(
              turns: angle / (2 * math.pi),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rim ticks
                  CustomPaint(
                    size: Size.square(widget.diameter),
                    painter: _TickPainter(
                      tickCount: 60,
                      tickLength: 8,
                      color: AppColors.shadowColor,
                    ),
                  ),

                  // Note: little circle
                  Positioned(
                    top: widget.diameter * 0.06, // ~8 % inset from the top
                    child: InnerShadow(
                      shadows: [
                        Shadow(
                          color: AppColors.shadowColor,
                          blurRadius: 4,
                          offset: const Offset(2, 3),
                        )
                      ],
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          width: widget.diameter * 0.07,
                          height: widget.diameter * 0.07,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent2,
                            boxShadow: [
                              BoxShadow( // DROP SHADOW
                                color: AppColors.shadowColor,
                                offset: const Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws short radial ticks on the knob rim.
class _TickPainter extends CustomPainter {
  _TickPainter({
    required this.tickCount,
    required this.tickLength,
    required this.color,
  });

  final int tickCount;
  final double tickLength;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;

    for (int i = 0; i < tickCount; i++) {
      final theta = 2 * math.pi * i / tickCount;
      final sinT = math.sin(theta), cosT = math.cos(theta);

      final p1 = Offset(
        center.dx + (radius - tickLength) * cosT,
        center.dy + (radius - tickLength) * sinT,
      );
      final p2 = Offset(
        center.dx + radius * cosT,
        center.dy + radius * sinT,
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) =>
      tickCount != old.tickCount ||
          tickLength != old.tickLength ||
          color != old.color;
}
