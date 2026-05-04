import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';

class WordBankScreen extends StatelessWidget {
  const WordBankScreen({super.key, this.filterLevel, this.filterCategory});
  final String? filterLevel;
  final String? filterCategory;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Word Bank'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 64, color: AppColors.primary),
              SizedBox(height: Spacing.lg),
              Text(
                'Your mastered words will appear here.\nComplete vocabulary sets to fill your word bank!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
