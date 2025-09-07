import 'package:flutter/material.dart';

import '../tokens/app_typography.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  AppText.displayLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.displayLarge;

  AppText.titleMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.titleMedium;

  AppText.bodyLarge(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.bodyLarge;

  AppText.bodyMedium(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.bodyMedium;

  AppText.bodySmall(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.bodySmall;

  AppText.labelSmall(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : style = AppTypography.labelSmall;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
