import "package:flutter/material.dart";
import "package:metronome_app/components/meter_selector_ui.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";


class MeterSelector extends StatefulWidget {
  const MeterSelector({
    super.key
  });



  @override
  State<MeterSelector> createState() => _MeterSelectorState();
}

class _MeterSelectorState extends State<MeterSelector> with SingleTickerProviderStateMixin {

  final List<int> beatsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
  final List<int> beatValueList = [2, 4, 8];
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


  void handleMeter0Changed(int value) {
    return songsProvider.updateMeter(songId: songId, sectionId: sectionId, index: 0, value: beatsList[value]);
  }
  void handleMeter1Changed(int value) {
    return songsProvider.updateMeter(songId: songId, sectionId: sectionId, index: 1, value: beatValueList[value]);
  }

  bool get isMeterPopupVisible {
    return songsProvider.isMeterPopupVisible;
  }


  void toggleVisibility() {
    return songsProvider.toggleMeterPopup();
  }

  @override
  Widget build(BuildContext context) {
    if (songId.isEmpty || sectionId.isEmpty) {
      return const SizedBox.shrink();
    }
    
    List<int> currentMeter = songsProvider.getMeter(songId, sectionId)!;
    int selectedBeatIndex = beatsList.indexOf(currentMeter[0]);
    int selectedBeatValueIndex = beatValueList.indexOf(currentMeter[1]);
    print("$selectedBeatIndex, $selectedBeatValueIndex");

    return MeterSelectorUi(
        selectedBeatIndex: selectedBeatIndex,
        selectedBeatValueIndex: selectedBeatValueIndex,
        handleMeter0Changed: handleMeter0Changed,
        handleMeter1Changed: handleMeter1Changed,
        toggleVisibility: toggleVisibility,
        isMeterPopupVisible: isMeterPopupVisible
    );



  }


}

