import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";

class FilteredImage extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final Color color;

  const FilteredImage({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.color,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}