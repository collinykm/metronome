import "package:flutter/material.dart";
import "package:metronome_app/components/filtered_image.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";

import "../service/subdivision.dart";

class SubdivisionSelectorUI extends StatefulWidget {
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
  State<SubdivisionSelectorUI> createState() => _SubdivisionSelectorUIState();
}

class _SubdivisionSelectorUIState extends State<SubdivisionSelectorUI> {


  late FixedExtentScrollController _controller;

  @override
  void initState() {
    _controller = FixedExtentScrollController(initialItem: widget.selectedIndex);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SubdivisionSelectorUI oldWidget) {
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _controller.jumpToItem(widget.selectedIndex);
    }
    super.didUpdateWidget(oldWidget);
  }




  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        left: widget.isSubdivisionPopupVisible ? 30 : -150,
        top: 200,
        child: Container(
          width: 150,
          height: 270,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12)
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              //select number of beats
              SizedBox(
                height: 200,
                width: 50,

                child: ListWheelScrollView(
                  itemExtent: 50, // Height of each item
                  diameterRatio: 1.5, // Adjust the size of the wheel
                  physics: FixedExtentScrollPhysics(),
                  controller: _controller,
                  onSelectedItemChanged: (index) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.handleSelectedItemChanged(index);
                    });

                  },

                  children:[
                    for (int i = 0; i < widget.subdivisionsList.length; i++)
                      FilteredImage(assetPath: widget.subdivisionsList[i].imagePath, width: 50, height: 30, color: i == widget.selectedIndex ? AppColors.accent2 : AppColors.primary)
                  ],
                ),
              ),


              IconButton(onPressed: widget.toggleVisibility, icon: AppIcons.close())

            ],
          ),
        )
    );;
  }
}


