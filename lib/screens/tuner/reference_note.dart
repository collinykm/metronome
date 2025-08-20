import "package:flutter/material.dart";
import "package:metronome_app/components/app_icon_button.dart";
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
          height: (MediaQuery.of(context).size.height * 0.54).clamp(0, 420),
          width: MediaQuery.of(context).size.width * 0.8,
          widget: LayoutBuilder(
            builder: (context, constraints) {
              final double maxHeight = constraints.maxHeight;
              final double maxWidth = constraints.maxWidth;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20)
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom, // shift above keyboard
                  ),
                  child: Column(
                    children: [
                      //Note: grid of radiobuttons to select reference note
                      Column(
                        children: [
                          for (int i = 0; i < 4; i ++)
                            Padding(
                              padding: EdgeInsets.only(bottom: maxHeight * 0.015),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int j = 0; j < 3; j ++)
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor: 3 * i + j == tunerProvider.selectedNote[0] ? AppColors.accent1 : AppColors.shadowColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadiusGeometry.circular(16),
                                        ),
                                      ),
                                      onPressed: () {tunerProvider.updateSelectedNote(3 * i + j);},
                                      child: BodyText(tunerProvider.noteNames[3 * i + j]),//this ensures it'll loop from 0 to 11, representing the indices in NoteNames
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Divider(),
                      //Note: selector for octave number
                      const SizedBox(height: 10,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TitleText("Octave"),
                          //Note: go down an octave
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIconButton(
                                onPressed: () {tunerProvider.updateSelectedNoteOctave(tunerProvider.selectedNote[1] - 1);},
                                icon: AppIcons.minus()
                              ),
                              BodyText(" ${tunerProvider.selectedNote[1]} "),
                              AppIconButton(
                                onPressed: () {tunerProvider.updateSelectedNoteOctave(tunerProvider.selectedNote[1] + 1);},
                                icon: AppIcons.plus()
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
}
