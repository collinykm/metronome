import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";
import "package:metronome_app/theme/typography.dart";

class MeterSelectorUi extends StatelessWidget {
  final List<int> beatsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
  final List<int> beatValueList = [2, 4, 8];

  final int selectedBeatIndex;
  final int selectedBeatValueIndex;
  final ValueChanged<int> handleMeter0Changed;
  final ValueChanged<int> handleMeter1Changed;
  final VoidCallback toggleVisibility;
  final bool isMeterPopupVisible;

  MeterSelectorUi({
    required this.selectedBeatIndex,
    required this.selectedBeatValueIndex,
    required this.handleMeter0Changed,
    required this.handleMeter1Changed,
    required this.toggleVisibility,
    required this.isMeterPopupVisible,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        right: isMeterPopupVisible ? 30 : -150,
        top: 200,
        child: Container(
          width: 150,
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12)
          ),
          child: Row(
            children: [
              //select number of beats
              SizedBox(
                height: 200,
                width: 50,
                child: ListWheelScrollView(
                  itemExtent: 50, // Height of each item
                  diameterRatio: 1.5, // Adjust the size of the wheel
                  physics: FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(initialItem: selectedBeatIndex),
                  onSelectedItemChanged: handleMeter0Changed,

                  children:[
                    for (int i = 0; i < beatsList.length; i++)
                      Text(beatsList[i].toString(),
                        style: TextStyles.body.copyWith(
                          color: i == selectedBeatIndex ? AppColors.accent1 : AppColors.primary,
                          fontSize: 20,
                        ),
                      )
                  ],
                ),
              ),

              //select the value of a beat
              SizedBox(
                height: 200,
                width: 50,

                child: ListWheelScrollView(
                  itemExtent: 50, // Height of each item
                  diameterRatio: 1.5, // Adjust the size of the wheel
                  physics: FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(initialItem: selectedBeatValueIndex),
                  onSelectedItemChanged: handleMeter1Changed,
                  children:[
                    for (int i = 0; i < beatValueList.length; i++)
                      Text(beatValueList[i].toString(),
                        style: TextStyles.body.copyWith(
                          color: i == selectedBeatValueIndex ? AppColors.accent1 : AppColors.primary,
                          fontSize: 20,
                        ),
                      )
                  ],
                ),
              ),

              IconButton(onPressed: toggleVisibility, icon: AppIcons.close)

            ],
          ),
        )
    );
  }
}
