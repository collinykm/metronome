import "dart:io";

import "package:flutter/material.dart";
import "package:metronome_app/theme/typography.dart";

class Suberscript extends StatelessWidget {
  final String text;
  final String? subscript;
  final String? superscript;
  final double? fontSize;
  const Suberscript({
    required this.text,
    this.subscript,
    this.superscript,
    this.fontSize,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    double currentFontSize = (fontSize ?? TextStyles.titleMedium.fontSize)!;
    return Transform.translate(
      offset: Offset( superscript == "♭" ? (currentFontSize * (Platform.isIOS ? 0.2 : 0.05)) : 0,  0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TitleText(
              text,
              fontSize: fontSize
          ),
          Transform.translate(
            offset: Offset(superscript == "♭" ? - currentFontSize * (Platform.isIOS ? 0.2 : 0.05): 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Container(
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.black)
                  // ),
                  child: Transform.translate(
                    offset: Offset(0, Platform.isAndroid && superscript == "♭" ? (currentFontSize * (Platform.isIOS ?  0.7 : 0.9) * (superscript == "♯" ? 0.76 : 1)) / 5 : 0),
                    child: TitleText(
                      superscript != null ? superscript! : "",
                      fontSize: currentFontSize * (Platform.isIOS ?  0.7 : 0.9) * (superscript == "♯" ? 0.76 : 1)
                      //android flat signs are tiny so they need more font size, and sharp signs in general are huge so they need to be shrunk
                    )
                  ),
                ),
            
                TitleText(
                  subscript != null ? subscript! : "",
                  fontSize: currentFontSize * 0.5
              ),
            ]
            
            
            ),
          )

        ],
      ),
    );
  }
}