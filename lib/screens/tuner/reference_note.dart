import "package:flutter/material.dart";
import "package:metronome_app/components/popup_container.dart";
import "package:metronome_app/service/tuner_provider.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";
import "package:metronome_app/theme/typography.dart";
import "package:provider/provider.dart";

class ReferenceNote extends StatefulWidget {
  const ReferenceNote({super.key});

  @override
  State<ReferenceNote> createState() => _ReferenceNoteState();
}

class _ReferenceNoteState extends State<ReferenceNote> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TunerProvider>(
      builder: (context, tunerProvider, child) {
        return PopupContainer(
          visible: tunerProvider.refNoteVisible,
          width: 300,
          height: 400,
          widget: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12)
            ),
            child: Column(
              children: [
                //Note: grid of radiobuttons to select reference note
                Column(
                  children: [
                    for (int i = 0; i < 3; i ++)
                      Row(
                        children: [
                          for (int j = 0; j < 4; j ++)
                            TextButton(
                              child: BodyText(tunerProvider.noteNames[4 * i + j]),
                              style: ButtonStyle(
                                backgroundColor: 4 * i + j == tunerProvider.selectedNote[0] ? WidgetStatePropertyAll(AppColors.accent1) : WidgetStatePropertyAll(AppColors.primary)
                              ),
                              onPressed: () {tunerProvider.updateSelectedNote(4 * i + j);},//this ensures it'll loop from 0 to 11, representing the indices in NoteNames
                              
                            )
                        ],


                      )
                  ],
                ),
                //Note: selector for octave number
                BodyText("Octave"),
                Row(
                  children: [
                    //Note: go down an octave
                    IconButton(
                      onPressed: () {tunerProvider.updateSelectedNoteOctave(tunerProvider.selectedNote[1] - 1);},
                      icon: AppIcons.minus()
                    ),
                    BodyText("${tunerProvider.selectedNote[1]}"),
                    IconButton(
                        onPressed: () {tunerProvider.updateSelectedNoteOctave(tunerProvider.selectedNote[1] + 1);},
                        icon: AppIcons.plus()
                    ),

                  ],

                )
              ],
            ),
        ),
        );
      }
    );
  }
}
