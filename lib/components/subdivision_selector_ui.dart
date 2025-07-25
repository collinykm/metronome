import "package:flutter/material.dart";

import "../service/subdivision.dart";

class SubdivisionSelectorUI extends StatelessWidget {
  final int selectedIndex;
  final List<Subdivision> subdivisionsList;
  final bool isSubdivisionPopupVisible;
  final ValueChanged<int> handleSelectedItemChanged;
  final VoidCallback toggleVisibility;


  const SubdivisionSelectorUI({
    required this.selectedIndex,
    required this.subdivisionsList,
    required this.isSubdivisionPopupVisible,
    required this.handleSelectedItemChanged,
    required this.toggleVisibility,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        left: isSubdivisionPopupVisible ? 0 : -150,
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
                  onSelectedItemChanged: handleSelectedItemChanged,

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
    );;
  }
}


