import "package:flutter/material.dart";
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
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(4, 4),
            spreadRadius: 0,
          )
        ]
      ),


      child: IconButton(
          onPressed: onPress,
          icon: icon
      ),
    );


  }
}
