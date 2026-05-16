import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';

class ExamPrepScreen extends StatelessWidget {
  const ExamPrepScreen({super.key, required this.levelId});
  final String levelId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(),
        title: Text(l10n.curriculumExamPrep),
      ),
      body: const Center(child: Text('Exam prep — coming in US4')),
    );
  }
}
