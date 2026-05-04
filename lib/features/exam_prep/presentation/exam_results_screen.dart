import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class ExamResultsScreen extends StatelessWidget {
  const ExamResultsScreen({super.key, required this.levelId, required this.setId, required this.accuracy, required this.readiness});
  final String levelId;
  final String setId;
  final double accuracy;
  final int readiness;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, leading: const BackButton()),
        body: Center(child: Text('Results: ${(accuracy * 100).round()}% accuracy, $readiness% readiness')),
      );
}
