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
    return Container(

      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
              text,
              style: style
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Text(
                superscript != null ? superscript! : "",
                style: style.copyWith(fontSize: superscript == "♭" ? style.fontSize! * 1 : style.fontSize! * 0.7)
              ),

              Text(
                subscript != null ? subscript! : "",
                style: style.copyWith(fontSize: style.fontSize! * 0.5)
            ),
          ]


          )

        ],
      ),
    );
  }
}