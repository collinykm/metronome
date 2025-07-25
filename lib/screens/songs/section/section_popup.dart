import "package:flutter/material.dart";
import "package:metronome_app/screens/metronome/meter_selector.dart";
import "package:metronome_app/screens/songs/section/song_subdivision_selector_logic.dart";
import "package:metronome_app/screens/songs/section/section_popup_content.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class SectionPopup extends StatefulWidget {
  const SectionPopup({super.key});

  @override
  State<SectionPopup> createState() => _SectionPopupState();
}

class _SectionPopupState extends State<SectionPopup> with SingleTickerProviderStateMixin {

  late SongsProvider songsProvider;

  @override
  void initState() {
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    super.initState();
  }

  void togglePopup(){
    songsProvider.toggleSectionPopup();
  }

  @override
  void dispose() {
    songsProvider.toggleSubdivisionPopup(setFalse: true);
    songsProvider.toggleMeterPopup(setFalse: true);
    songsProvider.toggleSectionPopup(setFalse: true);
    songsProvider.clearSectionId();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //for meter selector
        if (songsProvider.showSectionPopup)
          GestureDetector(
            onTap: () {
              songsProvider.toggleSectionPopup();

            },
            child: Container(
                color: Colors.black.withOpacity(0.5)
            ),
          ),

        //for subdivision selector
        if (songsProvider.isSubdivisionPopupVisible)
          GestureDetector(
            onTap: () {
              songsProvider.toggleSubdivisionPopup();
            },
            child: Container(
                color: Colors.black.withOpacity(0.5)
            ),
          ),

       // Semi-transparent background
        AnimatedPositioned(
          duration: Duration(milliseconds: 200),
          bottom: songsProvider.showSectionPopup ? 0 : -400,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 400, // Set the height of the popup
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SectionPopupContent(),
                ),
                ElevatedButton(
                  onPressed: togglePopup,
                  child: const Text("CLOSE"),
                ),
              ],
            ),
          ),
        ),

        MeterSelector(inSong: true,),
        SubdivisionSelector(),

      ],
    );

  }
}
