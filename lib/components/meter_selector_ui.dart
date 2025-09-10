import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/icons.dart";
import "package:metronome_app/theme/typography.dart";

class MeterSelectorUi extends StatefulWidget {
  final int selectedBeatIndex;
  final int selectedBeatValueIndex;
  final ValueChanged<int> handleMeter0Changed;
  final ValueChanged<int> handleMeter1Changed;
  final VoidCallback toggleVisibility;
  final bool isMeterPopupVisible;

  const MeterSelectorUi({
    required this.selectedBeatIndex,
    required this.selectedBeatValueIndex,
    required this.handleMeter0Changed,
    required this.handleMeter1Changed,
    required this.toggleVisibility,
    required this.isMeterPopupVisible,
    super.key
  });

  @override
  State<MeterSelectorUi> createState() => _MeterSelectorUiState();
}

class _MeterSelectorUiState extends State<MeterSelectorUi> {
  final List<int> beatsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];

  final List<int> beatValueList = [2, 4, 8];

  late FixedExtentScrollController _beatsScrollController;
  late FixedExtentScrollController _beatValueScrollController;

  @override
  void initState() {
    super.initState();
    _beatsScrollController = FixedExtentScrollController(initialItem: widget.selectedBeatIndex);
    _beatValueScrollController = FixedExtentScrollController(initialItem: widget.selectedBeatValueIndex);
  }

  bool isScrollingBeat = false;
  bool isScrollingBeatValue = false;

  @override
  void didUpdateWidget(covariant MeterSelectorUi oldWidget) {
    if (widget.selectedBeatIndex != oldWidget.selectedBeatIndex && !isScrollingBeat) {
      _beatsScrollController.jumpToItem(widget.selectedBeatIndex,);
    }
    if (widget.selectedBeatValueIndex != oldWidget.selectedBeatValueIndex && !isScrollingBeatValue) {
      _beatValueScrollController.jumpToItem(widget.selectedBeatValueIndex);
    }
    super.didUpdateWidget(oldWidget);
  }




  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 200),
        right: widget.isMeterPopupVisible ? 30 : -150,
        top: 200,
        child: Container(
          width: 150,
          height: 270,
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
                child: NotificationListener<UserScrollNotification>(
                  onNotification: (n) {
                    isScrollingBeat = n.direction != ScrollDirection.idle;
                    return false;
                  },

                  child: ListWheelScrollView(
                    itemExtent: 50, // Height of each item
                    diameterRatio: 1.5, // Adjust the size of the wheel
                    physics: FixedExtentScrollPhysics(),
                    controller: _beatsScrollController,
                    onSelectedItemChanged: (index) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        widget.handleMeter0Changed(index);
                      });
                    },

                    children:[
                      for (int i = 0; i < beatsList.length; i++)
                        Text(beatsList[i].toString(),
                          style: TextStyles.body.copyWith(
                            color: i == widget.selectedBeatIndex ? AppColors.accent2 : AppColors.primary,
                            fontSize: 20,
                          ),
                        )
                    ],
                  ),
                ),
              ),

              //select the value of a beat
              SizedBox(
                height: 200,
                width: 50,

                child: NotificationListener<UserScrollNotification>(
                  onNotification: (n) {
                    isScrollingBeatValue = n.direction != ScrollDirection.idle;
                    return false;
                  },

                  child: ListWheelScrollView(
                    itemExtent: 50, // Height of each item
                    diameterRatio: 1.5, // Adjust the size of the wheel
                    physics: FixedExtentScrollPhysics(),
                    controller: _beatValueScrollController,
                    onSelectedItemChanged: (index) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.handleMeter1Changed(index);
                    });
                    },
                    children:[
                      for (int i = 0; i < beatValueList.length; i++)
                        Text(beatValueList[i].toString(),
                          style: TextStyles.body.copyWith(
                            color: i == widget.selectedBeatValueIndex ? AppColors.accent2 : AppColors.primary,
                            fontSize: 20,
                          ),
                        )
                    ],
                  ),
                ),
              ),

              IconButton(onPressed: widget.toggleVisibility, icon: AppIcons.close())

            ],
          ),
        )
    );
  }
}
