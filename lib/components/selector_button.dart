import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";

class SelectorButton extends StatelessWidget {
  final VoidCallback onPress;
  final Widget content;

  const SelectorButton({
    required this.onPress,
    required this.content,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: 80,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: Offset(4, 4),
              spreadRadius: 0,
            )
          ]
        ),
        child: content,
      ),
    );
  }
}
