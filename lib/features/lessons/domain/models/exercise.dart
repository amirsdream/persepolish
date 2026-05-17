sealed class Exercise {
  const Exercise({
    required this.id,
    required this.prompt,
    required this.explanation,
    this.promptFa,
    this.explanationFa,
  });

  final String id;
  final String prompt;
  final String explanation;
  final String? promptFa;
  final String? explanationFa;

  String localizedPrompt(String lang) =>
      lang == 'fa' && promptFa != null ? promptFa! : prompt;

  String localizedExplanation(String lang) =>
      lang == 'fa' && explanationFa != null ? explanationFa! : explanation;

  static Exercise fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'multiple_choice' => MultipleChoiceExercise.fromJson(json),
      'fill_blank' => FillBlankExercise.fromJson(json),
      'dictation_mc' => DictationMcExercise.fromJson(json),
      'sentence_builder' => SentenceBuilderExercise.fromJson(json),
      // legacy aliases kept for backwards compat
      'fill_in_blank' => FillBlankExercise.fromJsonLegacy(json),
      'sentence_order' => SentenceBuilderExercise.fromJsonLegacy(json),
      _ => throw ArgumentError('Unknown exercise type: $type'),
    };
  }
}

// ── Multiple Choice ───────────────────────────────────────────────────────────

final class MultipleChoiceExercise extends Exercise {
  const MultipleChoiceExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.options,
    required this.correctIndex,
    super.promptFa,
    super.explanationFa,
    this.optionsFa,
  });

  final List<String> options;
  final int correctIndex;
  final List<String>? optionsFa;

  List<String> localizedOptions(String lang) =>
      lang == 'fa' && optionsFa != null && optionsFa!.length == options.length
          ? optionsFa!
          : options;

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  factory MultipleChoiceExercise.fromJson(Map<String, dynamic> json) =>
      MultipleChoiceExercise(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        explanation: json['explanation'] as String? ?? '',
        options: (json['options'] as List<dynamic>).cast<String>(),
        // support both camelCase (new) and snake_case (legacy)
        correctIndex: (json['correctIndex'] ?? json['correct_index']) as int,
        promptFa: json['prompt_fa'] as String?,
        explanationFa: json['explanation_fa'] as String?,
        optionsFa: (json['options_fa'] as List<dynamic>?)?.cast<String>(),
      );
}

// ── Fill in the Blank ─────────────────────────────────────────────────────────

final class FillBlankExercise extends Exercise {
  const FillBlankExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.answer,
    required this.acceptableAnswers,
    super.promptFa,
    super.explanationFa,
    this.hint,
  });

  /// Canonical correct answer (also in acceptableAnswers).
  final String answer;

  /// All accepted forms, compared case-insensitively.
  final List<String> acceptableAnswers;

  /// Optional grammatical hint shown before submission.
  final String? hint;

  bool isCorrect(String input) => acceptableAnswers
      .any((a) => a.toLowerCase() == input.toLowerCase().trim());

  factory FillBlankExercise.fromJson(Map<String, dynamic> json) =>
      FillBlankExercise(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        explanation: json['explanation'] as String? ?? '',
        answer: json['answer'] as String,
        acceptableAnswers:
            (json['acceptableAnswers'] as List<dynamic>).cast<String>(),
        hint: json['hint'] as String?,
        promptFa: json['prompt_fa'] as String?,
        explanationFa: json['explanation_fa'] as String?,
      );

  /// Legacy schema: sentence_template / accepted_answers fields.
  factory FillBlankExercise.fromJsonLegacy(Map<String, dynamic> json) {
    final template = json['sentence_template'] as String? ?? json['prompt'] as String;
    final answers = (json['accepted_answers'] as List<dynamic>?)?.cast<String>()
        ?? [json['answer'] as String];
    return FillBlankExercise(
      id: json['id'] as String,
      prompt: template,
      explanation: json['explanation'] as String? ?? '',
      answer: answers.first,
      acceptableAnswers: answers,
      promptFa: json['prompt_fa'] as String?,
      explanationFa: json['explanation_fa'] as String?,
    );
  }
}

// ── Dictation Multiple Choice ─────────────────────────────────────────────────

final class DictationMcExercise extends Exercise {
  const DictationMcExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.options,
    required this.correctIndex,
    this.audioAsset,
    super.promptFa,
    super.explanationFa,
  });

  /// Path to the audio file; null = audio not yet recorded (graceful skip).
  final String? audioAsset;
  final List<String> options;
  final int correctIndex;

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;

  factory DictationMcExercise.fromJson(Map<String, dynamic> json) =>
      DictationMcExercise(
        id: json['id'] as String,
        // dictation_mc may not have a text prompt; use a default
        prompt: json['prompt'] as String? ?? 'Listen and select the correct sentence.',
        explanation: json['explanation'] as String? ?? '',
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctIndex: (json['correctIndex'] ?? json['correct_index']) as int,
        audioAsset: json['audioAsset'] as String?,
        promptFa: json['prompt_fa'] as String?,
        explanationFa: json['explanation_fa'] as String?,
      );
}

// ── Sentence Builder ──────────────────────────────────────────────────────────

final class SentenceBuilderExercise extends Exercise {
  const SentenceBuilderExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.wordBank,
    required this.correctSequences,
    super.promptFa,
    super.explanationFa,
  });

  /// All word tiles shown to the student (correct words + distractors).
  final List<String> wordBank;

  /// One or more accepted orderings (list of word strings in correct order).
  final List<List<String>> correctSequences;

  /// Returns true if the student's chosen word list matches any accepted sequence.
  bool isCorrect(List<String> chosen) {
    return correctSequences.any((seq) =>
        seq.length == chosen.length &&
        List.generate(seq.length, (i) => seq[i] == chosen[i]).every((b) => b));
  }

  String get canonicalAnswer => correctSequences.first.join(' ');

  factory SentenceBuilderExercise.fromJson(Map<String, dynamic> json) =>
      SentenceBuilderExercise(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        explanation: json['explanation'] as String? ?? '',
        wordBank: (json['wordBank'] as List<dynamic>).cast<String>(),
        correctSequences: (json['correctSequences'] as List<dynamic>)
            .map((s) => (s as List<dynamic>).cast<String>())
            .toList(),
        promptFa: json['prompt_fa'] as String?,
        explanationFa: json['explanation_fa'] as String?,
      );

  /// Legacy schema: words (strings) + correct_order (int indices).
  factory SentenceBuilderExercise.fromJsonLegacy(Map<String, dynamic> json) {
    final words = (json['words'] as List<dynamic>).cast<String>();
    final order = (json['correct_order'] as List<dynamic>).cast<int>();
    final correctSeq = order.map((i) => words[i]).toList();
    return SentenceBuilderExercise(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      explanation: json['explanation'] as String? ?? '',
      wordBank: words,
      correctSequences: [correctSeq],
      promptFa: json['prompt_fa'] as String?,
      explanationFa: json['explanation_fa'] as String?,
    );
  }
}
