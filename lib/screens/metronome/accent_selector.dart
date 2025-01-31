import "package:flutter/material.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class AccentSelector extends StatefulWidget {
  const AccentSelector({this.songId, this.sectionId, super.key});

  final String? songId;
  final String? sectionId;
  

  @override
  State<AccentSelector> createState() => _AccentSelectorState();
}

class _AccentSelectorState extends State<AccentSelector> {


  List<int> accentsList() {
    if (widget.songId != null){
      return Provider.of<SongsProvider>(context, listen: false).getAccentsList(widget.songId!, widget.sectionId!);
    } else {
      return Provider.of<MetronomeProvider>(context, listen: false).accentsList;
    }
  }
  void updateAccent(int index) {
    if (widget.songId != null) {
      Provider.of<SongsProvider>(context, listen: false).updateAccent(songId: widget.songId!, sectionId: widget.sectionId!, beat: index);
    } else {
      Provider.of<MetronomeProvider>(context, listen: false).updateAccent(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width;
    double accentSelectorWidth = (screenWidth - 2*30 - (accentsList().length - 1) * 20) / accentsList().length;
    // the 30 represents the margin on the sides, 20 represents the gap between each selector (so each has a margin of 10)

    return Consumer<MetronomeProvider>(
      builder: (context, metronome, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < accentsList().length; i++)
              Container(
                width: accentSelectorWidth,
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {updateAccent(i);},
                  child: changeIcon(accentsList()[i]),
                ),
              ),
          ],

        );
      },

    );
  }

  Widget changeIcon(int accent) {
    switch (accent) {
      case 0:
        return Icon(Icons.exposure_zero); // Square icon
      case 1:
        return Icon(Icons.looks_one_rounded); // Triangle icon
      case 2:
        return Icon(Icons.looks_two_rounded); // Circle icon
      case 3:
        return Icon(Icons.three_g_mobiledata); // Star icon
      default:
        return Icon(Icons.error); // Fallback icon
    }
  }
}
