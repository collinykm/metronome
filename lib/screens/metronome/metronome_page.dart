import 'package:flutter/material.dart';
import 'package:metronome_app/screens/metronome/accent_selector.dart';
import 'package:metronome_app/screens/metronome/meter_selector.dart';
import 'package:metronome_app/screens/metronome/subdivision_selector.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:provider/provider.dart';
import 'package:metronome_app/screens/metronome/tempo_knob.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {



  @override
  void initState() {

    super.initState();
  }


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
                      child: Text("${metronome.meter[0]} / ${metronome.meter[1]}"),
                    ),

                    //subdivision button
                    ElevatedButton(
                      onPressed: metronome.toggleSubdivisionVisibility,
                      child: Image.asset(metronome.subdivision.imagePath, height: 30, width: 50,),
                    ),
                    
                    const SizedBox(height: 30,),
                    TempoKnob(),
                    Text(metronome.tempo.toString()),

                    //Play button
                    TextButton(onPressed: () {
                      Provider.of<MetronomeProvider>(context, listen: false).Play();
                    }, child: Text("PLAY")),

                    //Pause button
                    TextButton(
                      onPressed: () {
                        Provider.of<MetronomeProvider>(context, listen: false).Pause();
                      }, child: Text("PAUSE")
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

                MeterSelector(inSong: false,),
                SubdivisionSelector(inSong: false,)
              ],
            ),
          );
        },

      ),
    );
  }
}