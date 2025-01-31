import "package:flutter/material.dart";
import "package:metronome_app/screens/metronome/meter_selector.dart";
import "package:metronome_app/screens/songs/section/section_popup_content.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class SectionPopup extends StatefulWidget {
  const SectionPopup({super.key});

  @override
  State<SectionPopup> createState() => _SectionPopupState();
}

class _SectionPopupState extends State<SectionPopup> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late bool showPopup;
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
    songsProvider.clearSectionId();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (songsProvider.showSectionPopup)
          GestureDetector(
            onTap: () {
              if (songsProvider.isMeterPopupVisible) {
                songsProvider.toggleMeterPopup();
              } else {
                songsProvider.toggleSectionPopup();
              }
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

        MeterSelector(inSong: true,)

      ],
    );

  }
}
