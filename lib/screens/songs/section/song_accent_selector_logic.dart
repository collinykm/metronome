import "package:flutter/material.dart";
import "package:metronome_app/components/accent_selector_ui.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class AccentSelector extends StatefulWidget {
  const AccentSelector({super.key});
  
  @override
  State<AccentSelector> createState() => _AccentSelectorState();
}

class _AccentSelectorState extends State<AccentSelector> {
  
  String get songId {
    return songsProvider.selectedSongId;
  }
  String get sectionId {
    return songsProvider.selectedSectionId;
  }
  late SongsProvider songsProvider;

  @override
  void initState() {
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    super.initState();
  }


  List<int> get accentsList {
    return songsProvider.getAccentsList(songId, sectionId);
  }

  List<bool> get beepingIndicatorList {
    return List.filled(20, false);
  }

  void updateAccent(int index) {
    songsProvider.updateAccent(songId: songId, sectionId: sectionId, beat: index);
  }



  @override
  Widget build(BuildContext context) {
    if (songId == "" || sectionId == ""){
      return const SizedBox.shrink();
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double accentSelectorWidth = (screenWidth - 2*30 - (accentsList.length - 1) * 20) / accentsList.length;
    // the 30 represents the margin on the sides, 20 represents the gap between each selector (so each has a margin of 10)

    return AccentSelectorUi(
        handlePress: updateAccent,
        accentsList: accentsList,
        beepingIndicatorList: beepingIndicatorList
    );
  }


}
