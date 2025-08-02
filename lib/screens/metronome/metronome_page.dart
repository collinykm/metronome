
import 'package:flutter/material.dart';
import 'package:metronome_app/components/filtered_image.dart';
import 'package:metronome_app/components/play_Button.dart';
import 'package:metronome_app/components/selector_button.dart';
import 'package:metronome_app/screens/metronome/metronome_accent_selector_logic.dart';
import 'package:metronome_app/screens/metronome/metronome_meter_selector_logic.dart';
import 'package:metronome_app/screens/metronome/metronome_subdivision_selector_logic.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/theme/colors.dart';
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
          return Container(
            color: AppColors.background,
            child: Center(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      AccentSelector(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 80,
                        children: [
                          //Note: subdivision button
                          SelectorButton(
                              onPress: metronome.toggleSubdivisionVisibility,
                              content: FilteredImage(assetPath: metronome.subdivision.imagePath, height: 30, width: 50,),
                          ),
                          //Note: meter selector
                          SelectorButton(
                              onPress: metronome.toggleMeterVisibility,
                              content: BodyText("${metronome.meter[0]} / ${metronome.meter[1]}")
                          ),
                        ],
                      ),




                      //Play button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 20,
                        children: [
                          //Note: Play Button
                          PlayButton(
                              onPress: () {
                                if (metronome.isPlaying){
                                  metronome.Pause();
                                } else {
                                  metronome.Play();
                                }
                              },
                              diameter: 140,
                              icon: metronome.isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow)
                          ),
                          //Note: Tap Tempo
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: GestureDetector(
                              onTap: () {}, //TODO: WRITE CODE FOR TAP TEMPO,
                              child: Container(
                                width: 113,
                                height: 60,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowColor,
                                      blurRadius: 4,
                                      offset: Offset(4, 4),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(

                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: BodyText("Tap")
                              )
                            ),
                          )
                        ],
                      ),


                      //Note: tempo selector
                      const SizedBox(height: 30,),
                      BodyText(metronome.tempo.toString()),
                      TempoKnob(),



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
            ),
          );
        },

      ),
    );
  }
}