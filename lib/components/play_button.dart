import "package:flutter/material.dart";
import "package:flutter_inner_shadow/flutter_inner_shadow.dart";
import "package:metronome_app/theme/colors.dart";

class PlayButton extends StatelessWidget {
  final VoidCallback onPress;
  final double diameter;
  final Icon icon;

  const PlayButton({
    required this.onPress,
    required this.diameter,
    required this.icon,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return InnerShadow(
      shadows: [
        Shadow(
          color: AppColors.shadowColor,
          blurRadius: 4,
          offset: Offset(5, 6)
        )
      ],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(4, 4),
                spreadRadius: 0,
              ),
            ]
          ),


          child: IconButton(
              onPressed: onPress,
              icon: icon
          ),
        ),
      ),
    );


  }
}
