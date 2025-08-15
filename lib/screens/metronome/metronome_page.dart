
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metronome_app/components/filtered_image.dart';
import 'package:metronome_app/components/play_button.dart';
import 'package:metronome_app/components/selector_button.dart';
import 'package:metronome_app/screens/metronome/metronome_accent_selector_logic.dart';
import 'package:metronome_app/screens/metronome/metronome_meter_selector_logic.dart';
import 'package:metronome_app/screens/metronome/metronome_subdivision_selector_logic.dart';
import 'package:metronome_app/service/metronome_provider.dart';
import 'package:metronome_app/theme/colors.dart';
import 'package:metronome_app/theme/icons.dart';
import 'package:provider/provider.dart';
import 'package:metronome_app/screens/metronome/tempo_knob.dart';

import '../../theme/typography.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage> {
  List<DateTime> tapTimes = [];

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
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40,),
                      AccentSelector(),

                      const SizedBox(height: 40,),

                      //Note: subdivision and meter selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 80,
                        children: [
                          //Note: subdivision button
                          SelectorButton(
                              onPress: metronome.toggleSubdivisionVisibility,
                              content: FilteredImage(assetPath: metronome.subdivision.imagePath, height: 30, width: 50, color: AppColors.accent1,),
                          ),
                          //Note: meter selector
                          SelectorButton(
                              onPress: () {
                                HapticFeedback.selectionClick();
                                metronome.toggleMeterVisibility();
                                },
                              content: BodyText("${metronome.meter[0]} / ${metronome.meter[1]}")
                          ),
                        ],
                      ),


                      const SizedBox(height: 40,),

                      //Note: Play and Tap button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 60,
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
                              icon: metronome.isPlaying ? AppIcons.pause : AppIcons.play
                          ),
                          //Note: Tap Tempo
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: GestureDetector(
                              onTapDown: (details) {
                                final currentTime = DateTime.now();
                                //if there's been 3 seconds of no taps
                                if (tapTimes.isNotEmpty) {
                                  if (currentTime.difference(tapTimes.last) >
                                      Duration(seconds: 3)) {
                                    tapTimes.clear();
                                  }
                                }
                                tapTimes.add(currentTime);
                                //if there's at least 2 entries, calculate tempo
                                if (tapTimes.length >= 2) {
                                  final timeDifference = currentTime.difference(tapTimes[tapTimes.length - 2]);
                                  final tempo = (60.0 / (timeDifference.inMicroseconds / 1000000.0)).toInt();
                                  metronome.updateTempo(tempo);
                                }


                              },
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
                      const SizedBox(height: 0,),
                      BodyText(metronome.tempo.toString()),
                      BodyText("BPM"),
                      TempoKnob(),

                      const SizedBox(height: 20,),

                    ],
                  ),

                  if (metronome.isMeterPopupVisible)
                    GestureDetector(
                      onTap: () {
                        metronome.toggleMeterVisibility();
                      },
                      child: Container(
                        color: AppColors.shadowColor, // Semi-transparent background
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
                        color: AppColors.shadowColor, // Semi-transparent background
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