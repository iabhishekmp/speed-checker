import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/components/app_text.dart';
import '../../../../core/design/tokens/app_colors.dart';
import '../../../../core/design/tokens/app_spacing.dart';
import '../bloc/speed_test_bloc.dart';

class SpeedTestButton extends StatelessWidget {
  const SpeedTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpeedTestBloc, SpeedTestState>(
      builder: (context, state) {
        final bool isLoading = state is SpeedTestInProgress;

        return Column(
          children: [
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => context.read<SpeedTestBloc>().add(StartSpeedTest()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: AppSpacing.iconSM,
                      height: AppSpacing.iconSM,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textPrimary,
                        ),
                      ),
                    )
                  else
                    const Icon(Icons.play_arrow, size: AppSpacing.iconMD),
                  const SizedBox(width: AppSpacing.sm),
                  AppText.titleMedium(
                    isLoading ? 'Testing...' : 'Run Speed Test',
                  ),
                ],
              ),
            ),
            if (state is SpeedTestComplete)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: AppText.labelSmall(
                  'Last tested: ${DateFormat('HH:mm:ss').format(state.result.timestamp)}',
                ),
              ),
          ],
        );
      },
    );
  }
}
