import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
  });

  const AppCard.small({super.key, required this.child, this.backgroundColor})
    : padding = const EdgeInsets.all(AppSpacing.paddingSM),
      borderRadius = const BorderRadius.all(
        Radius.circular(AppSpacing.radiusSM),
      );

  const AppCard.medium({super.key, required this.child, this.backgroundColor})
    : padding = const EdgeInsets.all(AppSpacing.paddingMD),
      borderRadius = const BorderRadius.all(
        Radius.circular(AppSpacing.radiusMD),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.overlay,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppSpacing.radiusMD),
      ),
      child: child,
    );
  }
}
