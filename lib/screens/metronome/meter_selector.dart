import "package:flutter/material.dart";
import "package:metronome_app/service/metronome_provider.dart";
import "package:provider/provider.dart";


class MeterSelector extends StatefulWidget {
  MeterSelector({

    required this.isVisible,
    required this.toggleDock,
    super.key
  });


  final bool isVisible;
  final Function() toggleDock;

  @override
  State<MeterSelector> createState() => _MeterSelectorState();
}

class _MeterSelectorState extends State<MeterSelector> with SingleTickerProviderStateMixin {

  final List<int> beatsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
  final List<int> beatValueList = [1, 2, 3, 4, 8];
  int selectedBeatIndex = 3;
  int selectedBeatValueIndex = 3;
  late bool isVisible;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;



  @override
  void initState() {
    super.initState();

    isVisible = widget.isVisible;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0), // Start completely off the screen (right)
      end: Offset.zero,        // Slide into position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void togglePopup() {
    if (isVisible) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      isVisible = !isVisible;
    });
    widget.toggleDock;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Consumer<MetronomeProvider>(
            builder: (context, metronome, child) {
              return ElevatedButton(
                onPressed: togglePopup,
                child: Text("${metronome.meter[0].toString()} / ${metronome.meter[1].toString()}"),
              );
            },
          ),
        ),
        if (isVisible)
          GestureDetector(
            onTap: togglePopup,
            child: Container(
              color: Colors.black.withOpacity(0.1), // Background overlay
            ),
          ),

        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              width: 300,
              height: 300, // Set the height to 300 pixels
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
              ),
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
                        Provider.of<MetronomeProvider>(context, listen: false).updateMeterBeats(beatsList[index]);
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
                        print(index);
                        Provider.of<MetronomeProvider>(context, listen: false).updateMeterValue(beatValueList[index]);
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


                  ElevatedButton(onPressed: togglePopup, child: Icon(Icons.close))
                ],
              )
            ),
          ),
        ),
      ],
    );
  }


}

