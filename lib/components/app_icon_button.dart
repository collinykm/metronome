import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";
class AppIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  const AppIconButton({
    required this.onPressed,
    required this.icon,
    super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, icon: icon,
      style: IconButton.styleFrom(
        highlightColor: AppColors.accent1
      )
    );
  }
}

