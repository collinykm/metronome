import "package:flutter/material.dart";
import "package:metronome_app/components/popup_container.dart";
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
                        TunerGauge(),
                        const SizedBox(height: 40,),
                        //Note: Note Name, settings
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BodyText("A4 = ${tuner.A4_FREQ}"),
                            Text(
                              "${tuningOutputArray[0]}${tuningOutputArray[1]}",
                              style: TextStyles.title.copyWith(
                                  fontSize: 40
                              ),
                            ),

                            IconButton(
                                onPressed: tuner.toggleSettingsVisibility,
                                icon: AppIcons.sliders
                            ),
                          ],
                        ),

                        //Note: Reference Note
                        Row(
                          children: [
                            IconButton(
                              onPressed: tuner.toggleRefNoteVisibility,
                              icon: AppIcons.tuningFork
                            ),
                            Column(
                              children: [
                                TitleText("${tuner.noteNames[tuner.selectedNote[0]]}${tuner.selectedNote[1]}"),
                                IconButton(
                                  onPressed: () {
                                    tuner.isPlaying? tuner.pausePlayer() : tuner.playReferenceFreq();
                                  },
                                  icon: tuner.isPlaying ? AppIcons.pause : AppIcons.play
                                ),
                              ],
                            )
                          ],
                        ),

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
