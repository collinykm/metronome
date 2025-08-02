import "package:flutter/material.dart";
import "package:metronome_app/theme/colors.dart";

class FilteredImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;

  const FilteredImage({
    required this.assetPath,
    required this.width,
    required this.height,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      color: AppColors.accent1,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}