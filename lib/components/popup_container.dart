import "package:flutter/material.dart";

class PopupContainer extends StatelessWidget {
  final Widget widget;
  final bool visible;
  final double width;
  final double height;
  const PopupContainer({
    required this.widget,
    required this.visible,
    required this.width,
    required this.height,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final horizontalSpacing = (MediaQuery.of(context).size.width - width) / 2;
    final verticalSpacing =  (MediaQuery.of(context).size.height - height) / 2.5;  //this 2.5 a bit arbitrary, just to scoot it up a bit
    return AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      left: horizontalSpacing,
      top: visible ? verticalSpacing : MediaQuery.of(context).size.height,
      child: SizedBox(
        width: width,
        height: height,
        child: widget,
      ),
    );
  }
}
