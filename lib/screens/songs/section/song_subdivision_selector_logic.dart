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


  int get beatValue {
    return songsProvider.getMeter(songId, sectionId)[1];
  }



  List<Subdivision> get subdivisionsList{
    return allSubdivisionsMap[beatValue]!;
  }
  int get selectedIndex {
    return allSubdivisionsMap[beatValue]!.indexOf(songsProvider.getSubdivision(songId, sectionId));
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
    songsProvider.updateSubdivision(songId: songId, sectionId: sectionId, sub: subdivisionsList[index]);
  }

  @override
  Widget build(BuildContext context) {

    return SubdivisionSelectorUI(selectedIndex: selectedIndex, subdivisionsList: subdivisionsList, isSubdivisionPopupVisible: isSubdivisionPopupVisible(), handleSelectedItemChanged: handleSelectedItemChanged, toggleVisibility: toggleVisibility);

  }
}
