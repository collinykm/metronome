import "dart:math";

import "package:flutter/material.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:provider/provider.dart";


class TempoKnob extends StatefulWidget {
  const TempoKnob({super.key});


  @override
  State<TempoKnob> createState() => _TempoKnobState();
}

class _TempoKnobState extends State<TempoKnob> {


  @override
  Widget build(BuildContext context) {
    double totalAngle = Provider.of<MetronomeProvider>(context, listen: false).initialAngle();


    return GestureDetector(
      onPanStart: (details) {
        // Store the initial touch position
        Provider.of<MetronomeProvider>(context, listen: false).setPreviousOffset(details.localPosition);
      },
      onPanUpdate: (details) {
        Provider.of<MetronomeProvider>(context, listen: false).handleSpin(details);
      },
      onPanEnd: (details) {
        Provider.of<MetronomeProvider>(context, listen: false).setPreviousOffset(null);
      },


      child: Transform.rotate(
        angle: totalAngle,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: Center(
            child: Icon(Icons.circle)
            ),
          ),
      ),
    );

  }
}



