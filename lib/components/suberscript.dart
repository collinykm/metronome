import "dart:io";

import "package:flutter/material.dart";

class Suberscript extends StatelessWidget {
  final String text;
  final String? subscript;
  final String? superscript;
  final TextStyle style;
  const Suberscript({
    required this.text,
    this.subscript,
    this.superscript,
    required this.style,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset( superscript == "♭" ? (style.fontSize! * (Platform.isIOS ? 0.2 : 0.05)) : 0,  0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
              text,
              style: style
          ),
          Transform.translate(
            offset: Offset(superscript == "♭" ? - style.fontSize! * (Platform.isIOS ? 0.2 : 0.05): 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                Container(
                  // decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.black)
                  // ),
                  child: Transform.translate(
                    offset: Offset(0, Platform.isAndroid && superscript == "♭" ? (style.fontSize! * (Platform.isIOS ?  0.7 : 0.9) * (superscript == "♯" ? 0.76 : 1)) / 5 : 0),
                    child: Text(
                        superscript != null ? superscript! : "",
                        style: style.copyWith(fontSize: style.fontSize! * (Platform.isIOS ?  0.7 : 0.9) * (superscript == "♯" ? 0.76 : 1))
                      //android flat signs are tiny so they need more font size, and sharp signs in general are huge so they need to be shrunk
                    ),
                  ),
                ),
            
                Text(
                  subscript != null ? subscript! : "",
                  style: style.copyWith(fontSize: style.fontSize! * 0.5)
              ),
            ]
            
            
            ),
          )

        ],
      ),
    );
  }
}