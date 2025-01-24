import 'package:flutter/material.dart';

class SlidingDockScreen extends StatefulWidget {

  SlidingDockScreen({
    required this.updateMeterBeats,
    required this.updateMeterValue,
    required this.meter,
    required this.isVisible,
    required this.handleDismiss,
    super.key
  });
  final Function(int) updateMeterBeats;
  final Function(int) updateMeterValue;
  final List<int> meter;

  final bool isVisible;
  final Function() handleDismiss;

  @override
  _SlidingDockScreenState createState() => _SlidingDockScreenState();
}
class _SlidingDockScreenState extends State<SlidingDockScreen> {
  int selectedBeatIndex = 3;
  int selectedBeatValueIndex = 3;
  final List<int> beatsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
  final List<int> beatValueList = [1, 2, 3, 4, 8];

  // Initialize isVisible based on the widget's isVisible value
  late bool isVisible;

  @override
  void initState() {
    super.initState();
    isVisible = widget.isVisible;
  }

  void handleDismiss() {
    // Toggle the local state
    setState(() {
      isVisible = !isVisible;
    });

    // Call the parent's handleDismiss function
    widget.handleDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        Center(
          child: ElevatedButton(
            onPressed: handleDismiss, // Toggle the dock
            child: Text(widget.meter.toString(), style: TextStyle(color: isVisible ? Colors.yellow : Colors.black),),

          ),
        ),

        if (isVisible)
          Text("SDFSD"),
        if (!isVisible)
          Text("SDFSD33333"),

        // Click outside to dismiss
        if (isVisible)
          GestureDetector(
            onTap: handleDismiss, // Dismiss the dock when tapping outside
            behavior: HitTestBehavior.opaque, // Capture taps outside the dock
            child: Container(
              color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
            ),
          ),

        // Sliding dock
        AnimatedPositioned(
          duration: Duration(milliseconds: 300), // Animation duration
          curve: Curves.easeInOut, // Animation curve
          right: isVisible ? 0 : 200, // Slide in from the right
          top: (MediaQuery.of(context).size.height - 300) / 2, // Center vertically
          height: 300, // Fixed height for the dock
          width: 300, // Width of the dock
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[100], // Background color of the dock
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Select number of beats in a bar
                Container(
                  height: 200,
                  width: 50,
                  child: ListWheelScrollView(
                    itemExtent: 50, // Height of each item
                    diameterRatio: 1.5, // Adjust the size of the wheel
                    physics: FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(initialItem: 3),
                    children: [
                      for (int i = 0; i < beatsList.length; i++)
                        Text(
                          beatsList[i].toString(),
                          style: TextStyle(
                            color: i == 3 ? Colors.yellow : Colors.black,
                            fontSize: 20,
                          ),
                        )
                    ],
                  ),
                ),

                // Select the value of a beat
                Container(
                  height: 200,
                  width: 50,
                  child: ListWheelScrollView(
                    itemExtent: 50, // Height of each item
                    diameterRatio: 1.5, // Adjust the size of the wheel
                    physics: FixedExtentScrollPhysics(),
                    controller: FixedExtentScrollController(initialItem: 3),
                    children: [
                      for (int i = 0; i < beatValueList.length; i++)
                        Text(
                          beatValueList[i].toString(),
                          style: TextStyle(
                            color: i == 3 ? Colors.yellow : Colors.black,
                            fontSize: 20,
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}