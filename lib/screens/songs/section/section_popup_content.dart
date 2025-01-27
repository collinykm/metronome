import "package:flutter/material.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

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

        if (songsProvider.selectedSectionId == "") return Text("No Section selected right now");

        Section section = songsProvider.
          allSongs.firstWhere((song) => song.songId == songsProvider.selectedSongId).
          sectionsList.firstWhere((section) => section.sectionId == songsProvider.selectedSectionId);


        return Column(
          children: [

            Column(
              children: [
                Text(section.sectionName),
                Text("Tempo: ${section.tempo.toString()}"),
                Text("Bars: ${section.bars.toString()}"),
                Text("Subdivision: ${section.subdivision.toString()}"),
                Text("Meter: ${section.meter.toString()}"),
                Text("Accents: ${section.accentsList.toString()}"),

              ],
            ),
          ],
        );
      }
    );
  }
}
