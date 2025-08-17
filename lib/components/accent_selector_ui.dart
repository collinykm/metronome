import "dart:core";

import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";

class AccentSelectorUi extends StatelessWidget {
  final void Function(int) handlePress;
  final List<int> accentsList;
  final List<bool> beepingIndicatorList;
  final double? totalWidth;
  final double? height;

  const AccentSelectorUi({
    required this.handlePress,
    required this.accentsList,
    required this.beepingIndicatorList,
    this.totalWidth,
    this.height,
    super.key
  });


  @override
  Widget build(BuildContext context) {
    double screenWidth = totalWidth != null ? totalWidth! : MediaQuery.of(context).size.width;
    double accentSelectorWidth = ((screenWidth - 2*30 - (accentsList.length - 1) * 20) / accentsList.length).clamp(0, 73);
    // the 30 represents the margin on the sides, 20 represents the gap between each selector (so each has a margin of 10)

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < accentsList.length; i++)
          Container(
            width: accentSelectorWidth,
            margin: EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () => handlePress(i),
              child: CustomPaint(
                size: Size(accentSelectorWidth, height != null ? height! : 100),
                painter: AccentPainter(accent: accentsList[i], isFlashing: beepingIndicatorList[i]),
              ),
            )
          ),
      ],

    );

  }
}


class AccentPainter extends CustomPainter {

  final int accent;
  final bool isFlashing;
  
  AccentPainter({required this.accent, required this.isFlashing});

  @override
  void paint(Canvas canvas, Size size) {
    // Note: big border
    final borderStroke = Paint()
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..color = AppColors.text;
    final background = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.background;
    
    final borderRect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(12));
    //Note: shadow first
    final shadowPath = Path()..addRRect(borderRect.shift(Offset(5, 3)));
    canvas.drawShadow(shadowPath, Colors.black, 5, false);

    //drawing the actual accent selector box
    canvas.drawRRect(borderRect, borderStroke);
    canvas.drawRRect(borderRect, background);

    //Note: filling in the selector

    Color fillColor = isFlashing ? AppColors.accent1 : AppColors.primary;

    //first box
    final accentFill = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;

    final rect1 = Rect.fromLTWH(0, 2* size.height/3, size.width, size.height/3);
    final RRect1 = RRect.fromRectAndCorners(rect1, bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12));

    final rect2 = Rect.fromLTWH(0, size.height/3, size.width, size.height/3);

    final rect3 = Rect.fromLTWH(0, 0, size.width, size.height/3);
    final RRect3 = RRect.fromRectAndCorners(rect3, topLeft: Radius.circular(12), topRight: Radius.circular(12));

    if (accent >= 1) {
      canvas.drawRRect(RRect1, accentFill);
      if (accent >= 2) {
        canvas.drawRect(rect2, accentFill);
        if (accent == 3) {
          canvas.drawRRect(RRect3, accentFill);
        }
      }
    }


    //Note: dividers
    final divider = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke
      ..color = AppColors.text;

    canvas.drawLine(Offset(0, size.height/3), Offset(size.width, size.height/3), divider);
    canvas.drawLine(Offset(0, 2* size.height/3), Offset(size.width, 2* size.height/3), divider);

  }


  @override
  bool shouldRepaint(covariant AccentPainter oldDelegate) {
    if (oldDelegate.accent != accent || oldDelegate.isFlashing != isFlashing ) {
      return true;
    }
    return false;
  }

}
