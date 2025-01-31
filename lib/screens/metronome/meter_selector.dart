import "package:flutter/material.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:provider/provider.dart";


class MeterSelector extends StatefulWidget {
  MeterSelector({
    required this.inSong,
    super.key
  });

  bool inSong;


  @override
  State<MeterSelector> createState() => _MeterSelectorState();
}

class _MeterSelectorState extends State<MeterSelector> with SingleTickerProviderStateMixin {

  final List<int> beatsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
  final List<int> beatValueList = [1, 2, 3, 4, 8];
  late int selectedBeatIndex;
  late int selectedBeatValueIndex;

  late SongsProvider songsProvider;

  @override
  void initState() {
    songsProvider = Provider.of<SongsProvider>(context, listen: false);

    if (widget.inSong) {
      songsProvider.addListener(changeDefaultValues);
    }
    selectedBeatIndex = 3;
    selectedBeatValueIndex = 3;

    super.initState();
  }

  @override
  void dispose() {
    songsProvider.removeListener(changeDefaultValues);
    super.dispose();
  }


  void changeDefaultValues () {
    if (songsProvider.selectedSectionId != "") {
      List<int> meter = songsProvider.getMeter(songsProvider.selectedSongId, songsProvider.selectedSectionId);
      selectedBeatIndex = beatsList.indexOf(meter[0]);
      selectedBeatValueIndex = beatsList.indexOf(meter[1]);
    }
  }




  List<int> meter() {
    if (widget.inSong) {
      return songsProvider.getMeter(songsProvider.selectedSongId, songsProvider.selectedSectionId);
    } else {
      return Provider.of<MetronomeProvider>(context, listen: false).meter;
    }
  }

  void updateMeter(int index, int value) {
    if (widget.inSong) {
      return songsProvider.updateMeter(songId: songsProvider.selectedSongId, sectionId: songsProvider.selectedSectionId, index: index, value: value);
    } else {
      return Provider.of<MetronomeProvider>(context, listen: false).updateMeter(index, value);
    }
  }

  bool isMeterPopupVisible() {
    if (widget.inSong) {
      return songsProvider.isMeterPopupVisible;
    } else {
      return Provider.of<MetronomeProvider>(context, listen: false).isMeterPopupVisible;
    }
  }



  Widget build(BuildContext context) {

    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      right: isMeterPopupVisible() ? 0 : -150,
      top: 200,
      child: Container(
        width: 150,
        height: 300,
        color: Colors.white,
        child: Row(
          children: [
          //select number of beats
          Container(
            height: 200,
            width: 50,
            child: ListWheelScrollView(
              itemExtent: 50, // Height of each item
              diameterRatio: 1.5, // Adjust the size of the wheel
              physics: FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: selectedBeatIndex),
              onSelectedItemChanged: (index) {
                updateMeter(0, beatsList[index]);
                setState(() {
                selectedBeatIndex = index;
                });
              },

              children:[
                for (int i = 0; i < beatsList.length; i++)
                  Text(beatsList[i].toString(),
                    style: TextStyle(
                      color: i == selectedBeatIndex ? Colors.yellow : Colors.black,
                      fontSize: 20,
                    ),
                  )
              ],
            ),
          ),

          //select the value of a beat
          Container(
            height: 200,
            width: 50,

            child: ListWheelScrollView(
              itemExtent: 50, // Height of each item
              diameterRatio: 1.5, // Adjust the size of the wheel
              physics: FixedExtentScrollPhysics(),
              controller: FixedExtentScrollController(initialItem: selectedBeatValueIndex),
              onSelectedItemChanged: (index) {
              updateMeter(1, beatValueList[index]);
                setState(() {
                  selectedBeatValueIndex = index;
                });
              },
              children:[
                for (int i = 0; i < beatValueList.length; i++)
                Text(beatValueList[i].toString(),
                  style: TextStyle(
                    color: i == selectedBeatValueIndex ? Colors.yellow : Colors.black,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),

          IconButton(onPressed: Provider.of<MetronomeProvider>(context, listen: false).toggleMeterVisibility, icon: Icon(Icons.close))

          ],
        ),
      )
    );



  }


}

