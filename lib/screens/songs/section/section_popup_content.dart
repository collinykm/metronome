import "package:flutter/material.dart";
import "package:metronome_app/components/popup_input_dialogue.dart";
import "package:metronome_app/screens/metronome/accent_selector.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";
import 'package:string_validator/string_validator.dart';

class SectionPopupContent extends StatefulWidget {
  const SectionPopupContent({super.key});

  @override
  State<SectionPopupContent> createState() => _SectionPopupContentState();
}

class _SectionPopupContentState extends State<SectionPopupContent> {


  @override
  Widget build(BuildContext context) {
    return Consumer<SongsProvider>(

      builder: (context, songsProvider, child) {
        if (songsProvider.selectedSectionId == "")
          return Text("No Section selected right now");

        Section section = songsProvider.
        allSongs.firstWhere((song) =>
          song.songId == songsProvider.selectedSongId).sectionsList
            .firstWhere((section) => section.sectionId == songsProvider.selectedSectionId
        );
        String songId = songsProvider.selectedSongId;
        String sectionId = songsProvider.selectedSectionId;

        return Column(
          children: [
            Column(
              children: [
                //MeterSelector(songId: songsProvider.selectedSongId, sectionId: songsProvider.selectedSectionId,),
                TextButton(
                  onPressed: () {
                    TextEditingController controller = TextEditingController(text: section.sectionName);

                    showInputDialogue(context: context,
                      handleSubmit: () {
                        String text = controller.text.trim();
                        songsProvider.updateFieldInSection(songId: songId, sectionId: sectionId, toUpdate: "name", value: text);
                        Navigator.pop(context);
                      },
                      title: "Name this section",
                      hintText: "ex. Part A",
                      controller: controller,
                      confirmText: "Done",
                    );

                  },
                  child: Text(section.sectionName),
                ),
                //tempo selector
                TextButton(
                  onPressed: () {
                    TextEditingController controller = TextEditingController(text: section.tempo.toString());
                    showInputDialogue(context: context,
                      handleSubmit: () {
                        String text = controller.text;
                        if (isInt(text)) {
                          int tempo = int.parse(text);
                          tempo = tempo.clamp(20, 400);
                          songsProvider.updateFieldInSection(
                              songId: songsProvider.selectedSongId,
                              sectionId: songsProvider.selectedSectionId,
                              toUpdate: "tempo",
                              value: tempo);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                                "Input can only contain numbers"),
                            showCloseIcon: true,
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.grey,
                          ));
                        }


                        Navigator.pop(context);
                      },
                      title: "Set new tempo",
                      hintText: "ex. 120",
                      controller: controller,
                      confirmText: "Done",
                      type: TextInputType.number,
                    );
                  },
                  child: Text("Tempo: ${section.tempo.toString()}")
                ),
                //bars selector
                TextButton(
                  onPressed: () {
                    TextEditingController controller = TextEditingController(text: section.bars.toString());
                    showInputDialogue(context: context,
                      handleSubmit: () {
                        String text = controller.text;
                        if (isInt(text)) {
                          int bars = int.parse(text);
                          songsProvider.updateFieldInSection(
                              songId: songsProvider.selectedSongId,
                              sectionId: songsProvider.selectedSectionId,
                              toUpdate: "bars",
                              value: bars
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                                "Input can only contain numbers"),
                            showCloseIcon: true,
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.grey,
                          ));
                        }


                        Navigator.pop(context);
                      },
                      title: "# Bars for Section",
                      hintText: "ex. 32",
                      controller: controller,
                      confirmText: "Done",
                      type: TextInputType.number,
                    );
                  },
                  child: Text("Bars: ${section.bars.toString()}")
                ),

                //subdivision selector
                ElevatedButton(
                  onPressed: songsProvider.toggleSubdivisionPopup,
                  child: Image.asset(songsProvider.getSubdivision(songId, sectionId).imagePath, height: 30, width: 50,),
                ),
                ElevatedButton(onPressed: songsProvider.toggleMeterPopup,
                  child: Text("Meter: ${section.meter.toString()}"),),

                AccentSelector(songId: songsProvider.selectedSongId,
                  sectionId: songsProvider.selectedSectionId,),

              ],
            ),
          ],
        );
      }
    );

  }
}
