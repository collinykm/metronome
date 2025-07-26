import "dart:core";

import "package:flutter/material.dart";

class AccentSelectorUi extends StatelessWidget {
  final void Function(int) handlePress;
  final List<int> accentsList;
  final List<bool> beepingIndicatorList;


  const AccentSelectorUi({
    required this.handlePress,
    required this.accentsList,
    required this.beepingIndicatorList,
    super.key
  });


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double accentSelectorWidth = (screenWidth - 2*30 - (accentsList.length - 1) * 20) / accentsList.length;
    // the 30 represents the margin on the sides, 20 represents the gap between each selector (so each has a margin of 10)

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < accentsList.length; i++)
          Container(
            width: accentSelectorWidth,
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: beepingIndicatorList[i] ? Colors.yellow : null,
              ),
              onPressed: () => handlePress(i),
              child: changeIcon(accentsList[i]),
            ),
          ),
      ],

    );

  }

  Widget changeIcon(int accent) {
    switch (accent) {
      case 0:
        return Icon(Icons.exposure_zero);
      case 1:
        return Icon(Icons.looks_one_rounded);
      case 2:
        return Icon(Icons.looks_two_rounded);
      case 3:
        return Icon(Icons.three_g_mobiledata);
      default:
        return Icon(Icons.error);
    }
  }
}
