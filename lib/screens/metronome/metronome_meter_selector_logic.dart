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
  int get selectedBeatIndex {
    return beatsList.indexOf(metronomeProvider.meter[0]);
  }
  int get selectedBeatValueIndex {
    return beatValueList.indexOf(metronomeProvider.meter[1]);
  }

  late MetronomeProvider metronomeProvider;

  @override
  void initState() {
    metronomeProvider = Provider.of<MetronomeProvider>(context, listen: false);
    super.initState();
  }



  void handleMeter0Changed(int value) {
    print("current selectedBeatIndex: $selectedBeatIndex, value i got was $value");
    metronomeProvider.updateMeter(0, beatsList[value]);
    print("after updating, selectedBeatIndex: $selectedBeatIndex");

  }
  void handleMeter1Changed(int value) {
    metronomeProvider.updateMeter(1, beatValueList[value]);
  }

  bool get isMeterPopupVisible {
    return metronomeProvider.isMeterPopupVisible;
  }


  void toggleVisibility() {
    return metronomeProvider.toggleMeterVisibility();

  }

  Widget build(BuildContext context) {

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
