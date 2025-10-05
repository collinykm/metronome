import "dart:io";
import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:metronome_app/components/app_icon_button.dart";
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
    initRecorder();
    super.initState();
  }

  void initRecorder() async {
    await tunerProvider.initializeRecorder();
    await tunerProvider.initTunerPrefs();

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
    return LayoutBuilder(
      builder: (context, constraints) {

        final double maxHeight = constraints.maxHeight;
        final double maxWidth = constraints.maxWidth;
        final double gap = maxHeight > 800 ? maxHeight * 0.045 : maxHeight * 0.03;

        return Consumer<TunerProvider>(
          builder: (context, tuner, child) {
            return Container(
              decoration: BoxDecoration(
                  color: AppColors.background
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: gap/2,),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: maxWidth * 0.08),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //this row is for A4 = 440hz
                              Row(
                                spacing: 1,
                                children: [
                                  GestureDetector(
                                    onTap: tuner.toggleSettingsVisibility,
                                    child: Row(
                                      children: [
                                        Suberscript(text: "A", subscript: "4",),
                                        AppIcons.equal(size: 12, color: AppColors.text),
                                        BodyText("${tuner.A4_FREQ}Hz",)
                                      ],
                                    ),
                                  )


                                ],
                              ),
                              AppIconButton(
                                  onPressed: tuner.toggleSettingsVisibility,
                                  icon: AppIcons.sliders(size: 30)
                              ),
                            ],
                          ),
                        ),

                        //Note: Note Name
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                TunerGauge(size: maxWidth > 400 ? (maxWidth * 0.88).clamp(0, 360) : (maxWidth * 0.88).clamp(0, 300),),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          top: BorderSide(color: Colors.black, width: 2),
                                          bottom: BorderSide(color: Colors.black, width: 2)
                                      )
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: maxHeight > 750 ? 20 : 0),
                                  child: Center(
                                    child: Superscript(
                                        text: "${tuningOutputArray[0][0]}",
                                        superscript: tuningOutputArray[0].length > 1 ? "${tuningOutputArray[0][1]}" : "",
                                        style: TextStyles.titleMedium.copyWith(
                                            fontSize:  (MediaQuery.of(context).textScaler.scale(80)).clamp(0, 80)
                                        )
                                    ),



                                  ),
                                ),
                                SizedBox(height: gap),
                                //Note: Reference Note
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TitleText("Reference Note"),
                                    SizedBox(height: gap/3,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        AppIconButton(
                                            onPressed: tuner.toggleRefNoteVisibility,
                                            icon: AppIcons.tuningFork(size: (maxHeight * 0.1) .clamp(0, 60), color: AppColors.text)
                                        ),
                                        Transform.translate(
                                          offset: Offset(0, Platform.isAndroid ? - (MediaQuery.of(context).textScaler.scale(40)) / 8 : 0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [

                                              GestureDetector(
                                                onTap: tuner.toggleRefNoteVisibility,
                                                child: Suberscript(
                                                    text: tuner.noteNames[tuner.selectedNote[0]][0],
                                                    superscript: tuner.noteNames[tuner.selectedNote[0]].length == 2 ? tuner.noteNames[tuner.selectedNote[0]][1] : "",
                                                    subscript: "${tuner.selectedNote[1]}",
                                                    fontSize: 50,
                                                ),
                                              ),

                                              IconButton(
                                                  onPressed: () {
                                                    tuner.isPlaying? tuner.pausePlayer() : tuner.playReferenceFreq();
                                                  },
                                                  icon: tuner.isPlaying ? AppIcons.pause() : AppIcons.play()
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )



                      ],
                    ),
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
            );
          }
        );
      },
    );

  }
}
