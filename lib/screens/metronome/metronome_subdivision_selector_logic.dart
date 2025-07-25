import "package:flutter/material.dart";

import "package:metronome_app/components/subdivision_selector_ui.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:metronome_app/service/subdivision.dart";
import "package:provider/provider.dart";


class SubdivisionSelector extends StatefulWidget {
  const SubdivisionSelector({super.key});


  @override
  State<SubdivisionSelector> createState() => _SubdivisionSelectorState();
}

class _SubdivisionSelectorState extends State<SubdivisionSelector> {

  late MetronomeProvider metronomeProvider;
  int get beatValue {
    return metronomeProvider.meter[1];
  }
  List<Subdivision> get subdivisionsList{
    return allSubdivisionsMap[beatValue]!;
  }
  int get selectedIndex {
    return allSubdivisionsMap[beatValue]!.indexOf(metronomeProvider.subdivision);
  }


  @override
  void initState() {
    metronomeProvider = Provider.of<MetronomeProvider>(context, listen: false);
    super.initState();
  }

  void updateSubdivision(Subdivision selected) {
    metronomeProvider.updateSubdivision(selected);
  }

  bool isSubdivisionPopupVisible() {
    return metronomeProvider.isSubdivisionPopupVisible;
  }

  void toggleVisibility() {
    return metronomeProvider.toggleSubdivisionVisibility();
  }

  handleSelectedItemChanged(int index) {
    Subdivision selected = subdivisionsList[index];
    updateSubdivision(selected);
  }

  Widget build(BuildContext context) {

    return SubdivisionSelectorUI(selectedIndex: selectedIndex, subdivisionsList: subdivisionsList, isSubdivisionPopupVisible: isSubdivisionPopupVisible(), handleSelectedItemChanged: handleSelectedItemChanged, toggleVisibility: toggleVisibility);

  }
}
