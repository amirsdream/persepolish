import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class VocabQuizScreen extends StatelessWidget {
  const VocabQuizScreen({super.key, required this.levelId, required this.setId});
  final String levelId;
  final String setId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, leading: const BackButton()),
        body: const Center(child: Text('Vocabulary quiz — coming in US3')),
      );
}
