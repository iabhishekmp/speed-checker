import 'package:flutter/material.dart';

import '../../../../core/design/components/app_text.dart';
import '../../../../core/design/tokens/app_colors.dart';
import '../../../../core/design/tokens/app_spacing.dart';

class SpeedTestHeader extends StatelessWidget {
  const SpeedTestHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.wifi, size: AppSpacing.iconLG, color: AppColors.accent),
        const SizedBox(height: AppSpacing.md),
        AppText.displayLarge(
          'Internet Speed Test',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
