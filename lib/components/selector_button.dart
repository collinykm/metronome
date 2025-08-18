import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";

class SelectorButton extends StatelessWidget {
  final VoidCallback onPress;
  final double? height;
  final Widget content;

  const SelectorButton({
    required this.onPress,
    required this.content,
    this.height,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        width: height != null ? height! * 1.25 : 80, //aspect ratio
        height: height?? 64,
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
