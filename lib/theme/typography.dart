import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

import "colors.dart";

class TextStyles {
  // ONE base font method
  static TextStyle get _base => GoogleFonts.aldrich(
    color: AppColors.text,
  );

  // Styles that build off it
  static TextStyle get titleMedium => _base.copyWith(fontSize: 20);
  static TextStyle get body => _base.copyWith(fontSize: 14);

}

class BodyText extends StatelessWidget {
  final String text;
  const BodyText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final userScaler = MediaQuery.of(context).textScaler;
    // Clamp to avoid extreme cases (say, system set to 3x or 0.5x).
    final dampenedScaler = userScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.5);
    return Text(text, textScaler: dampenedScaler, style: TextStyles.body);
  }
}

class TitleText extends StatelessWidget {
  final String text;
  const TitleText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final userScaler = MediaQuery.of(context).textScaler;
    // Clamp to avoid extreme cases (say, system set to 3x or 0.5x).
    final dampenedScaler = userScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 2);

    return Text(text, textScaler: dampenedScaler, style: TextStyles.titleMedium,);
  }
}
