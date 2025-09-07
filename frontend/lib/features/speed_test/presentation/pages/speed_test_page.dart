import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design/components/demo_badge.dart';
import '../../../../core/design/tokens/app_colors.dart';
import '../../../../core/design/tokens/app_spacing.dart';
import '../../data/repositories/speed_test_repository.dart';
import '../../domain/models/speed_test_result.dart';
import '../bloc/speed_test_bloc.dart';
import '../widgets/metric_display.dart';
import '../widgets/speed_test_button.dart';
import '../widgets/speed_test_header.dart';
import '../widgets/speed_test_tips.dart';

class SpeedTestPage extends StatelessWidget {
  const SpeedTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpeedTestBloc(repository: SpeedTestRepository()),
      child: const SpeedTestView(),
    );
  }
}

class SpeedTestView extends StatelessWidget {
  const SpeedTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.xl),
                  const SpeedTestHeader(),
                  SizedBox(height: AppSpacing.xxl),
                  const SpeedTestButton(),
                  SizedBox(height: AppSpacing.xl),
                  BlocBuilder<SpeedTestBloc, SpeedTestState>(
                    builder: (context, state) {
                      final result = state is SpeedTestComplete
                          ? state.result
                          : SpeedTestResult.initial();

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          MetricDisplay(
                            icon: Icons.speed_outlined,
                            label: 'Ping',
                            value: result.ping.toStringAsFixed(0),
                            unit: 'ms',
                          ),
                          MetricDisplay(
                            icon: Icons.download_outlined,
                            label: 'Download',
                            value: result.download.toStringAsFixed(1),
                            unit: 'Mbps',
                          ),
                          MetricDisplay(
                            icon: Icons.upload_outlined,
                            label: 'Upload',
                            value: result.upload == double.infinity
                                ? 'Infinity'
                                : result.upload.toStringAsFixed(1),
                            unit: 'Mbps',
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xl),
                  const Spacer(),
                  const SpeedTestTips(),
                ],
              ),
            ),
          ),
          const Positioned(top: 0, right: 0, child: DemoBadge()),
        ],
      ),
    );
  }
}
