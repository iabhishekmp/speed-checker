import 'package:flutter/material.dart';

import '../../../../core/design/components/app_text.dart';
import '../../../../core/design/tokens/app_spacing.dart';

class SpeedTestTips extends StatelessWidget {
  const SpeedTestTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppText.titleMedium('Speed Test Tips'),
        const SizedBox(height: AppSpacing.sm),
        AppText.bodySmall(
          'For best results, close other applications using internet and connect via ethernet if possible.',
        ),
      ],
    );
  }
}
