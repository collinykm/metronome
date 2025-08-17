import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";
class AppTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget textWidget;
  const AppTextButton({
    required this.onPressed,
    required this.textWidget,
    super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
          highlightColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(12)
          )
      ),
      child: textWidget,
    );
  }
}