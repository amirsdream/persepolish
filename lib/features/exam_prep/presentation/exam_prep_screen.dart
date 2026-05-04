import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class ExamPrepScreen extends StatelessWidget {
  const ExamPrepScreen({super.key, required this.levelId});
  final String levelId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, leading: const BackButton(), title: const Text('Exam Prep')),
        body: const Center(child: Text('Exam prep — coming in US4')),
      );
}
