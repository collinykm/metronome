import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:metronome_app/components/accent_selector_ui.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";

class AccentSelector extends StatefulWidget {
  final double? height;
  const AccentSelector({this.height, super.key});


  @override
  State<AccentSelector> createState() => _AccentSelectorState();
}

class _AccentSelectorState extends State<AccentSelector> {

  late MetronomeProvider metronomeProvider;

  @override
  void initState() {
    metronomeProvider = Provider.of<MetronomeProvider>(context, listen: false);
    super.initState();
  }


  List<int> get accentsList {
    return metronomeProvider.accentsList;
  }

  List<bool> get beepingIndicatorList {
    return metronomeProvider.currentBeepingMetronomeList;
  }

  void updateAccent(int index) {
    metronomeProvider.updateAccent(index);
  }



  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double accentSelectorWidth = (screenWidth - 2*30 - (accentsList.length - 1) * 20) / accentsList.length;
    // the 30 represents the margin on the sides, 20 represents the gap between each selector (so each has a margin of 10)

    return AccentSelectorUi(
      handlePress: updateAccent,
      accentsList: accentsList,
      beepingIndicatorList: beepingIndicatorList,
      height: widget.height,
    );
  }


}
