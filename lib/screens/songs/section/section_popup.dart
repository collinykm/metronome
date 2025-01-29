import "package:flutter/material.dart";
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
    print("section popup was initialized");
    songsProvider = Provider.of<SongsProvider>(context, listen: false);


    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0.0, 2.0), // Start completely off the screen (right)
      end: Offset.zero,        // Slide into position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    super.initState();
  }

  void doAnimation() {
    if (!songsProvider.showSectionPopup){
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  void togglePopup(){
    songsProvider.toggleSectionPopup();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    songsProvider.addListener(doAnimation);
  }


  @override
  void dispose() {
    songsProvider.removeListener(doAnimation);
    _controller.dispose();
    songsProvider.clearSectionId();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (songsProvider.showSectionPopup)
          GestureDetector(
            onTap: togglePopup,
            child: Container(
                color: Colors.black.withOpacity(0.5)
            ),
          ),

       // Semi-transparent background
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              width: double.infinity,
              height: 300, // Set the height of the popup
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
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
        ),

      ],
    );

  }
}
