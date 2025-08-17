import "dart:math";

import "package:flutter/material.dart";
import "package:metronome_app/components/app_icon_button.dart";
import "package:metronome_app/components/popup_container.dart";
import "package:metronome_app/components/suberscript.dart";
import "package:metronome_app/components/subscript.dart";
import "package:metronome_app/components/superscript.dart";
import "package:metronome_app/screens/tuner/reference_note.dart";
import "package:metronome_app/screens/tuner/tuner_gauge.dart";
import "package:metronome_app/screens/tuner/tuner_settings.dart";
import "package:metronome_app/service/tuner_provider.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";
import "package:metronome_app/theme/typography.dart";
import "package:provider/provider.dart";

class TunerPage extends StatefulWidget {
  const TunerPage({super.key});

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  
  late TunerProvider tunerProvider;
  
  @override
  void initState() {
    tunerProvider = Provider.of<TunerProvider>(context, listen: false);
    tunerProvider.initializeRecorder();
    super.initState();
  }
  
  @override
  void dispose() {
    tunerProvider.disposeRecorder();
    super.dispose();
  }

  List<dynamic> get tuningOutputArray {
    return tunerProvider.tuningOutputArray;
  }
  
  @override
  Widget build(BuildContext context) {

    final List<dynamic> tuningOutputArray = context.select<TunerProvider, List<dynamic>?>((p) => p.tuningOutputArray) ?? [];
    return Consumer<TunerProvider>(
        builder: (context, tuner, child) {
          return Container(
            decoration: BoxDecoration(
                color: AppColors.background
            ),
            child: Center(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80,),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //this row is for A4 = 440hz
                            Row(
                              spacing: 1,
                              children: [
                                Subscript(text: "A", subscript: "4", style: TextStyles.body.copyWith(fontSize: 14)),
                                AppIcons.equal(size: 12, color: AppColors.text),
                                Text("${tuner.A4_FREQ}Hz", style: TextStyles.body.copyWith(fontSize: 12),)
                              ],
                            ),
                            AppIconButton(
                                onPressed: tuner.toggleSettingsVisibility,
                                icon: AppIcons.sliders()
                            ),
                          ],
                        ),
                      ),
                      TunerGauge(),

                      //Note: Note Name, settings

                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 2),
                            bottom: BorderSide(color: Colors.black, width: 2)
                          )
                        ),
                        height: 180,
                        child: Row(

                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [


                            Superscript(
                              text: "${tuningOutputArray[0][0]}",
                              superscript: tuningOutputArray[0].length > 1 ? "${tuningOutputArray[0][1]}" : "",
                              style: TextStyles.title.copyWith(
                                fontSize: 70
                            )),


                          ],
                        ),
                      ),

                      //Note: Reference Note
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TitleText("Reference Note"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AppIconButton(
                                    onPressed: tuner.toggleRefNoteVisibility,
                                    icon: AppIcons.tuningFork(size: 60, color: AppColors.text)
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //TitleText("${tuner.noteNames[tuner.selectedNote[0]]}${tuner.selectedNote[1]}"),
                                    Suberscript(
                                      text: tuner.noteNames[tuner.selectedNote[0]][0],
                                      superscript: tuner.noteNames[tuner.selectedNote[0]].length == 2 ? tuner.noteNames[tuner.selectedNote[0]][1] : "",
                                      subscript: "${tuner.selectedNote[1]}",
                                      style: TextStyles.title.copyWith(fontSize: 40)
                                    ),

                                    IconButton(
                                        onPressed: () {
                                          tuner.isPlaying? tuner.pausePlayer() : tuner.playReferenceFreq();
                                        },
                                        icon: tuner.isPlaying ? AppIcons.pause() : AppIcons.play()
                                    ),
                                  ],
                                )
                              ],
                                                    ),
                          ],
                        ))


                    ],
                  ),


                  if (tuner.settingsVisible)
                    GestureDetector(
                      onTap: () {
                        tuner.toggleSettingsVisibility();
                      },
                      child: Container(
                        color: AppColors.shadowColor, // Semi-transparent background
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                  if (tuner.refNoteVisible)
                    GestureDetector(
                      onTap: () {
                        tuner.toggleRefNoteVisibility();
                      },
                      child: Container(
                        color: AppColors.shadowColor, // Semi-transparent background
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),

                  TunerSettings(),
                  ReferenceNote()
                ]
              ),
            ),
          );
        }
      );

  }
}
