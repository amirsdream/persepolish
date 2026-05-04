import 'package:flutter/material.dart';

import '../../../core/theme/design_tokens.dart';

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({
    super.key,
    required this.levelId,
    required this.setId,
  });

  final String levelId;
  final String setId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: const BackButton(),
          title: const Text('Vocabulary'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.translate, size: 64, color: AppColors.primary),
                const SizedBox(height: Spacing.lg),
                Text(
                  'Vocabulary flashcards coming soon!\nSet: $setId',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.xl),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ),
      );
}
