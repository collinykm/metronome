import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";

class Superscript extends StatelessWidget {
  final String text;
  final String superscript;
  final TextStyle style;
  const Superscript({
    required this.text,
    required this.superscript,
    required this.style,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
            text,
            style: style
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                superscript,
                style:  style.copyWith(fontSize: superscript == "♭" ? style.fontSize! * 0.9 : style.fontSize! * 0.65)
            ),
            //filler
            Text(
                "",
                style:  style.copyWith(fontSize: superscript == "♭" ? style.fontSize! * 0.8 : style.fontSize! * 0.6)
            )
          ],
        )

      ],
    );
  }
}