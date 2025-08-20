import "package:flutter/material.dart";
import "package:metronome_app/components/accent_selector_ui.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class AccentSelector extends StatefulWidget {
  final double? totalWidth;
  final double? height;
  final String sectionId;
  const AccentSelector(
    {
      this.totalWidth,
      this.height,
      required this.sectionId,
      super.key
    }
  );
  
  @override
  State<AccentSelector> createState() => _AccentSelectorState();
}

class _AccentSelectorState extends State<AccentSelector> {
  
  String get songId {
    return songsProvider.selectedSongId;
  }
  late SongsProvider songsProvider;

  @override
  void initState() {
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    super.initState();
  }


  List<int> get accentsList {
    return songsProvider.getAccentsList(songId, widget.sectionId)!;
  }

  List<bool> get beepingIndicatorList {
    return List.filled(20, false);
  }

  void updateAccent(int index) {
    songsProvider.updateAccent(songId: songId, sectionId: widget.sectionId, beat: index);
  }



  @override
  Widget build(BuildContext context) {
    if (songId == "" || widget.sectionId == ""){
      return const SizedBox.shrink();
    }

    return AccentSelectorUi(
      handlePress: updateAccent,
      accentsList: accentsList,
      beepingIndicatorList: beepingIndicatorList,
      totalWidth: widget.totalWidth,
      height: widget.height,
    );
  }


}
