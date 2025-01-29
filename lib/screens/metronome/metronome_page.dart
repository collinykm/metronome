import 'package:flutter/material.dart';
import 'package:metronome_app/screens/metronome/accent_selector.dart';
import 'package:metronome_app/screens/metronome/meter_selector.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/service/play_metronome_provider.dart';
import 'package:provider/provider.dart';
import 'package:metronome_app/screens/metronome/tempo_knob.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {

  bool isMeterDockVisible = false;
  void toggleSlidingDockMeter() {
    setState(() {
      isMeterDockVisible = !isMeterDockVisible;
    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Consumer<MetronomeProvider>(
        builder: (context, metronome, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                AccentSelector(),
                MeterSelector(
                  isVisible: isMeterDockVisible,
                  toggleDock: toggleSlidingDockMeter,
                ),
                const SizedBox(height: 30,),
                TempoKnob(),
                Text(metronome.tempo.toString()),
                TextButton(onPressed: () {
                  Provider.of<MetronomeProvider>(context, listen: false).Play(
                      // tempo: metronome.tempo,
                      // subdivision: metronome.subdivision,
                      // meter: metronome.meter,
                      // accentsList: metronome.accentsList,
                  );
                }, child: Text("PLAY")),
                TextButton(onPressed: () {
                  Provider.of<MetronomeProvider>(context, listen: false).Pause();
                }, child: Text("PAUSE")),

              ],
            ),
          );
        },

      ),
    );
  }
}