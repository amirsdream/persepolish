sealed class Exercise {
  const Exercise({
    required this.id,
    required this.prompt,
    required this.explanation,
  });

  final String id;
  final String prompt;
  final String explanation;

  static Exercise fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String) {
      'multiple_choice' => MultipleChoiceExercise.fromJson(json),
      'fill_in_blank' => FillInBlankExercise.fromJson(json),
      'sentence_order' => SentenceOrderExercise.fromJson(json),
      final type => throw ArgumentError('Unknown exercise type: $type'),
    };
  }
}

final class MultipleChoiceExercise extends Exercise {
  const MultipleChoiceExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.options,
    required this.correctIndex,
  });

  final List<String> options;
  final int correctIndex;

  factory MultipleChoiceExercise.fromJson(Map<String, dynamic> json) =>
      MultipleChoiceExercise(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        explanation: json['explanation'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctIndex: json['correct_index'] as int,
      );

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

final class FillInBlankExercise extends Exercise {
  const FillInBlankExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.sentenceTemplate,
    required this.acceptedAnswers,
  });

  final String sentenceTemplate;
  final List<String> acceptedAnswers;

  factory FillInBlankExercise.fromJson(Map<String, dynamic> json) =>
      FillInBlankExercise(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        explanation: json['explanation'] as String,
        sentenceTemplate: json['sentence_template'] as String,
        acceptedAnswers:
            (json['accepted_answers'] as List<dynamic>).cast<String>(),
      );

  bool isCorrect(String answer) => acceptedAnswers
      .any((a) => a.toLowerCase() == answer.toLowerCase().trim());
}

final class SentenceOrderExercise extends Exercise {
  const SentenceOrderExercise({
    required super.id,
    required super.prompt,
    required super.explanation,
    required this.words,
    required this.correctOrder,
  });

  final List<String> words;
  final List<int> correctOrder;

  factory SentenceOrderExercise.fromJson(Map<String, dynamic> json) =>
      SentenceOrderExercise(
        id: json['id'] as String,
        prompt: json['prompt'] as String,
        explanation: json['explanation'] as String,
        words: (json['words'] as List<dynamic>).cast<String>(),
        correctOrder:
            (json['correct_order'] as List<dynamic>).cast<int>(),
      );

  bool isCorrect(List<int> selectedOrder) {
    if (selectedOrder.length != correctOrder.length) return false;
    for (var i = 0; i < correctOrder.length; i++) {
      if (selectedOrder[i] != correctOrder[i]) return false;
    }
    return true;
  }

  List<String> get correctSentence =>
      correctOrder.map((i) => words[i]).toList();
}
