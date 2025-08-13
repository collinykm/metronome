import "package:flutter/material.dart";
import 'package:metronome_app/theme/colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppIcons {
  static final metronome = Icon(
      PhosphorIconsRegular.metronome,
      size: 20,
      color: AppColors.primary,
  );
  static final tuner = Icon(
    PhosphorIconsRegular.gauge,
    size: 20,
    color: AppColors.primary,
  );
  static final song = Icon(
    PhosphorIconsRegular.musicNotes,
    size: 20,
    color: AppColors.primary,
  );
  static final settings = Icon(
    PhosphorIconsRegular.gear,
    size: 20,
    color: AppColors.primary,
  );
  static final play = Icon(
    PhosphorIconsFill.play,
    color: AppColors.accent1
  );
  static final pause = Icon(
      PhosphorIconsFill.pause,
      color: AppColors.accent1
  );
}
