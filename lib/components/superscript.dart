import "dart:io";

import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";
import "package:metronome_app/theme/typography.dart";

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
    return Transform.translate(
      offset: Offset( superscript != "" ? (style.fontSize! * (Platform.isIOS ? 0.2 : 0.05)) : 0,  0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(text, style: style),
          Transform.translate(
            offset: Offset(- style.fontSize! * (Platform.isIOS ? 0.2 : 0.05), - style.fontSize! * (Platform.isIOS ? 0.3 : 0.44)), // Superscript offset
            child: TitleText(
              superscript,
              fontSize: style.fontSize! * (Platform.isIOS ?  0.7 : 0.9) * (superscript == "♯" ? 0.76 : 1),
            )
              
          ),
        ],
      ),
    );
  }
}