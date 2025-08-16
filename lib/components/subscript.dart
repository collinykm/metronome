import "package:flutter/material.dart";

import "../theme/colors.dart";

class Subscript extends StatelessWidget {
  final String text;
  final String subscript;
  final TextStyle style;
  const Subscript({
    required this.text,
    required this.subscript,
    required this.style,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: style
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "",
                style:  style.copyWith(fontSize: style.fontSize! * 0.6)
            ),
            //filler
            Text(
                subscript,
                style:  style.copyWith(fontSize: style.fontSize! * 0.6)
            )
          ],
        )
      ],
    );
  }
}
