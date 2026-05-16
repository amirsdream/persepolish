import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/design_tokens.dart';

class WordBankScreen extends StatelessWidget {
  const WordBankScreen({super.key, this.filterLevel, this.filterCategory});
  final String? filterLevel;
  final String? filterCategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(l10n.wordBankTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book, size: 64, color: AppColors.primary),
            const SizedBox(height: Spacing.lg),
            Text(
              l10n.wordBankEmpty,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
