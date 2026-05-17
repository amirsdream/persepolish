import '../models/exercise.dart';

final class AnswerResult {
  const AnswerResult({
    required this.isCorrect,
    required this.explanation,
    required this.correctDisplay,
  });

  final bool isCorrect;
  final String explanation;
  final String correctDisplay;
}

/// Validates a learner's answer against the exercise definition.
/// Pure logic — no I/O. Fully unit-testable.
final class SubmitAnswerUseCase {
  const SubmitAnswerUseCase();

  AnswerResult execute({
    required Exercise exercise,
    required dynamic answer,
  }) {
    return switch (exercise) {
      MultipleChoiceExercise mc => _evaluateMC(mc, answer as int),
      FillBlankExercise fill => _evaluateFill(fill, answer as String),
      DictationMcExercise dictation => _evaluateDictation(dictation, answer as int),
      SentenceBuilderExercise builder => _evaluateBuilder(builder, answer as List<String>),
    };
  }

  AnswerResult _evaluateMC(MultipleChoiceExercise ex, int selectedIndex) =>
      AnswerResult(
        isCorrect: ex.isCorrect(selectedIndex),
        explanation: ex.explanation,
        correctDisplay: ex.options[ex.correctIndex],
      );

  AnswerResult _evaluateFill(FillBlankExercise ex, String answer) =>
      AnswerResult(
        isCorrect: ex.isCorrect(answer),
        explanation: ex.explanation,
        correctDisplay: ex.answer,
      );

  AnswerResult _evaluateDictation(DictationMcExercise ex, int selectedIndex) =>
      AnswerResult(
        isCorrect: ex.isCorrect(selectedIndex),
        explanation: ex.explanation,
        correctDisplay: ex.options[ex.correctIndex],
      );

  AnswerResult _evaluateBuilder(SentenceBuilderExercise ex, List<String> chosen) =>
      AnswerResult(
        isCorrect: ex.isCorrect(chosen),
        explanation: ex.explanation,
        correctDisplay: ex.canonicalAnswer,
      );
}

/// Computes star rating from accuracy ratio (0.0–1.0).
int starsForAccuracy(double accuracy) {
  if (accuracy >= 0.90) return 3;
  if (accuracy >= 0.70) return 2;
  return 1;
}
