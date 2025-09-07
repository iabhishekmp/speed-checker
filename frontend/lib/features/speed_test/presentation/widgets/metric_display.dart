import 'package:flutter/material.dart';

import '../../../../core/design/components/app_text.dart';
import '../../../../core/design/tokens/app_colors.dart';
import '../../../../core/design/tokens/app_spacing.dart';

class MetricDisplay extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? unit;

  const MetricDisplay({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: AppSpacing.iconMD),
        SizedBox(height: AppSpacing.md),
        AppText.bodySmall(label, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.xs),
        AppText.displayLarge(value, textAlign: TextAlign.center),
        if (unit != null) AppText.bodySmall(unit!, textAlign: TextAlign.center),
      ],
    );
  }
}
