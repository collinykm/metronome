import "package:flutter/material.dart";


import "package:metronome_app/components/subdivision_selector_ui.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:metronome_app/service/subdivision.dart";
import "package:provider/provider.dart";


class SubdivisionSelector extends StatefulWidget {
  const SubdivisionSelector({super.key});


  @override
  State<SubdivisionSelector> createState() => _SubdivisionSelectorState();
}

class _SubdivisionSelectorState extends State<SubdivisionSelector> {


  late SongsProvider songsProvider;

  String get songId {
    return songsProvider.selectedSongId;
  }
  String get sectionId {
    return songsProvider.selectedSectionId;
  }



  @override
  void initState() {
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    super.initState();
  }

  void updateSubdivision(Subdivision selected) {

    songsProvider.updateSubdivision(songId: songId, sectionId: sectionId, sub: selected);

  }

  bool isSubdivisionPopupVisible() {
    return songsProvider.isSubdivisionPopupVisible;
  }


  void toggleVisibility() {
    return songsProvider.toggleSubdivisionPopup();
  }


  void handleSelectedItemChanged(int index) {
    if (songId.isEmpty || sectionId.isEmpty) return;
    final currentBeatValue = songsProvider.getMeter(songId, sectionId)![1];
    final subs = allSubdivisionsMap[currentBeatValue]!;
    songsProvider.updateSubdivision(songId: songId, sectionId: sectionId, sub: subs[index]);
  }

  @override
  Widget build(BuildContext context) {

    if (songId.isEmpty || sectionId.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentBeatValue = songsProvider.getMeter(songId, sectionId)?[1];
    final subs = allSubdivisionsMap[currentBeatValue!];
    final index = subs!.indexOf(songsProvider.getSubdivision(songId, sectionId)!);

    return SubdivisionSelectorUI(
      selectedIndex: index,
      subdivisionsList: subs,
      isSubdivisionPopupVisible: isSubdivisionPopupVisible(),
      handleSelectedItemChanged: handleSelectedItemChanged,
      toggleVisibility: toggleVisibility,
    );
  }
}
