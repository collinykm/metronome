import "package:flutter/material.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:metronome_app/service/songs_provider.dart";
import "package:metronome_app/service/subdivision.dart";
import "package:provider/provider.dart";


class SubdivisionSelector extends StatefulWidget {
  const SubdivisionSelector({required this.inSong, super.key});
  final bool inSong;

  @override
  State<SubdivisionSelector> createState() => _SubdivisionSelectorState();
}

class _SubdivisionSelectorState extends State<SubdivisionSelector> {


  late SongsProvider songsProvider;
  late MetronomeProvider metronomeProvider;
  int beatValue = 4;
  late List<Subdivision> subdivisionsList;
  int selectedIndex = 1;
  late String songId;
  late String sectionId;


  @override
  void initState() {
    songsProvider = Provider.of<SongsProvider>(context, listen: false);
    metronomeProvider = Provider.of<MetronomeProvider>(context, listen: false);
    songId = songsProvider.selectedSongId;
    sectionId = songsProvider.selectedSectionId;


    if (widget.inSong && sectionId != ""){
      beatValue = songsProvider.getMeter(songId, sectionId)[1];
      selectedIndex = allSubdivisionsMap[beatValue]!.indexOf(songsProvider.getSubdivision(songId, sectionId));

    }
    else {
      beatValue = metronomeProvider.meter[1];
      selectedIndex = allSubdivisionsMap[beatValue]!.indexOf(metronomeProvider.subdivision);


    }
    subdivisionsList = allSubdivisionsMap[beatValue]!;
    songsProvider.addListener(getUpdatedMeter);
    metronomeProvider.addListener(getUpdatedMeter);
    super.initState();
  }

  @override
  void dispose() {
    songsProvider.removeListener(getUpdatedMeter);
    metronomeProvider.removeListener(getUpdatedMeter);
    super.dispose();
  }

  void getUpdatedMeter() {


    if (widget.inSong && sectionId != "" && songsProvider.getMeter(songId, sectionId)[1] != beatValue){
      beatValue = songsProvider.getMeter(songId, sectionId)[1];
      selectedIndex = allSubdivisionsMap[beatValue]!.indexOf(songsProvider.getSubdivision(songId, sectionId));
      songsProvider.updateSubdivision(songId: songId, sectionId: sectionId, sub: allSubdivisionsMap[beatValue]![selectedIndex]);
    }

    else if (metronomeProvider.meter[1] != beatValue){
      selectedIndex = allSubdivisionsMap[beatValue]!.indexOf(metronomeProvider.subdivision);
       beatValue = metronomeProvider.meter[1];

       metronomeProvider.updateSubdivision(allSubdivisionsMap[beatValue]![selectedIndex]);
    }
    subdivisionsList = allSubdivisionsMap[beatValue]!;
  }




  void updateSubdivision(Subdivision selected) {
    if (widget.inSong) {
      songsProvider.updateSubdivision(songId: songId, sectionId: sectionId, sub: selected);
    } else {
      metronomeProvider.updateSubdivision(selected);
    }
  }

  bool isSubdivisionPopupVisible() {
    if (widget.inSong) {
      return songsProvider.isSubdivisionPopupVisible;
    } else {
      return metronomeProvider.isSubdivisionPopupVisible;
    }
  }


  void toggleVisibility() {
    if (widget.inSong) {
      return songsProvider.toggleSubdivisionPopup();
    } else {
      return metronomeProvider.toggleSubdivisionVisibility();
    }
  }

  Widget build(BuildContext context) {

    return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        left: isSubdivisionPopupVisible() ? 0 : -150,
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
                  controller: FixedExtentScrollController(initialItem: selectedIndex),
                  onSelectedItemChanged: (index) {
                    Subdivision selected = subdivisionsList[index];
                    updateSubdivision(selected);
                    setState(() {
                      selectedIndex = index;
                    });
                  },

                  children:[
                    for (Subdivision sub in subdivisionsList)
                      SizedBox(
                        height: 30,
                        width: 50,
                        child: Image.asset(sub.imagePath),
                      )
                  ],
                ),
              ),


              IconButton(onPressed: toggleVisibility, icon: Icon(Icons.close))

            ],
          ),
        )
    );



  }
}
