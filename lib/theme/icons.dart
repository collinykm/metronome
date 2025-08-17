import "package:flutter/material.dart";
import 'package:metronome_app/theme/colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static Icon metronome({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.metronome,
          size: size ?? 20, color: color ?? AppColors.primary);

  static Icon tuner({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.gauge,
          size: size ?? 20, color: color ?? AppColors.primary);

  static Icon song({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.musicNotes,
          size: size ?? 20, color: color ?? AppColors.primary);

  static Icon settings({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.gear,
          size: size ?? 20, color: color ?? AppColors.primary);

  static Icon play({double? size, Color? color}) =>
      Icon(PhosphorIconsFill.play,
          size: size, color: color ?? AppColors.accent1);

  static Icon pause({double? size, Color? color}) =>
      Icon(PhosphorIconsFill.pause,
          size: size, color: color ?? AppColors.accent1);

  static Icon close({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.x,
          size: size, color: color ?? AppColors.primary);

  static Icon sliders({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.sliders,
          size: size, color: color ?? AppColors.primary);

  static Icon rightArrow({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.arrowRight,
          size: size, color: color ?? AppColors.primary);

  static Icon equal({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.equals,
          size: size, color: color ?? AppColors.primary);

  static Icon plus({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.plus,
          size: size, color: color ?? AppColors.primary);

  static Icon minus({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.minus,
          size: size, color: color ?? AppColors.primary);

  static SvgPicture tuningFork({double? size, Color? color}) =>
      SvgPicture.asset(
        "assets/icons/tuningFork.svg",
          width: size ?? 24,
          height: size ?? 24,
          colorFilter: ColorFilter.mode(color ?? AppColors.primary, BlendMode.srcIn),
      );


  static Icon arrowDownUp({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.arrowsDownUp,
          size: size, color: color ?? AppColors.primary);

  static Icon arrowLeft({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.arrowLeft,
          size: size, color: color ?? AppColors.primary);

  static Icon search({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.magnifyingGlass,
          size: size, color: color ?? AppColors.primary);

  static Icon edit({double? size, Color? color}) =>
      Icon(PhosphorIconsRegular.pencil,
          size: size, color: color ?? AppColors.primary);

  static Icon add({double? size, Color? color}) =>
      Icon(PhosphorIconsBold.plus,
          size: size, color: color ?? AppColors.primary,);

  static Icon trash({double? size, Color? color}) =>
      Icon(PhosphorIconsBold.trash,
        size: size, color: color ?? AppColors.primary,);
}
