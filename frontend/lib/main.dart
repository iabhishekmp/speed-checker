import 'package:flutter/material.dart';

import 'core/design/theme/app_theme.dart';
import 'features/speed_test/presentation/pages/speed_test_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Test',
      theme: AppTheme.darkTheme,
      home: const SpeedTestPage(),
    );
  }
}
