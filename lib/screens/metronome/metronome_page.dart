
import 'package:flutter/material.dart';
import 'package:metronome_app/screens/metronome/metronome_accent_selector_logic.dart';
import 'package:metronome_app/screens/metronome/metronome_meter_selector_logic.dart';
import 'package:metronome_app/screens/metronome/metronome_subdivision_selector_logic.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:provider/provider.dart';
import 'package:metronome_app/screens/metronome/tempo_knob.dart';

import '../../theme/typography.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Consumer<MetronomeProvider>(
        builder: (context, metronome, child) {
          return Center(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    AccentSelector(),
                    
                    //meter button
                    ElevatedButton(
                      onPressed: metronome.toggleMeterVisibility,
                      child: BodyText("${metronome.meter[0]} / ${metronome.meter[1]}"),
                    ),

                    //subdivision button
                    ElevatedButton(
                      onPressed: metronome.toggleSubdivisionVisibility,
                      child: Image.asset(metronome.subdivision.imagePath, height: 30, width: 50,),
                    ),
                    
                    const SizedBox(height: 30,),
                    TempoKnob(),
                    BodyText(metronome.tempo.toString()),

                    //Play button
                    TextButton(onPressed: () {
                      Provider.of<MetronomeProvider>(context, listen: false).Play();
                    }, child: BodyText("PLAY")),

                    //Pause button
                    TextButton(
                      onPressed: () {
                        Provider.of<MetronomeProvider>(context, listen: false).Pause();
                      }, child: BodyText("PAUSE")
                    ),



                  ],
                ),

                if (metronome.isMeterPopupVisible)
                  GestureDetector(
                    onTap: () {
                      metronome.toggleMeterVisibility();
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.3), // Semi-transparent background
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                if (metronome.isSubdivisionPopupVisible)
                  GestureDetector(
                    onTap: () {
                      metronome.toggleSubdivisionVisibility();
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.3), // Semi-transparent background
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                MeterSelector(),
                SubdivisionSelector()
              ],
            ),
          );
        },

      ),
    );
  }
}