import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "colors.dart";

class TextStyles {
  // ONE base font method
  static TextStyle get _base => GoogleFonts.aldrich(
    color: AppColors.text,
  );

  // Styles that build off it
  static TextStyle get title => _base.copyWith(fontSize: 20);
  static TextStyle get body => _base.copyWith(fontSize: 14);

}

class BodyText extends StatelessWidget {
  final String text;
  const BodyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyles.body,);
  }
}

class TitleText extends StatelessWidget {
  final String text;
  const TitleText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyles.title,);
  }
}
