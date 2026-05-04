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
    required dynamic answer, // int (MC), String (Fill), List<int> (Order)
  }) {
    return switch (exercise) {
      MultipleChoiceExercise mc => _evaluateMC(mc, answer as int),
      FillInBlankExercise fill => _evaluateFill(fill, answer as String),
      SentenceOrderExercise order => _evaluateOrder(order, answer as List<int>),
    };
  }

  AnswerResult _evaluateMC(MultipleChoiceExercise ex, int selectedIndex) =>
      AnswerResult(
        isCorrect: ex.isCorrect(selectedIndex),
        explanation: ex.explanation,
        correctDisplay: ex.options[ex.correctIndex],
      );

  AnswerResult _evaluateFill(FillInBlankExercise ex, String answer) =>
      AnswerResult(
        isCorrect: ex.isCorrect(answer),
        explanation: ex.explanation,
        correctDisplay: ex.acceptedAnswers.first,
      );

  AnswerResult _evaluateOrder(SentenceOrderExercise ex, List<int> order) =>
      AnswerResult(
        isCorrect: ex.isCorrect(order),
        explanation: ex.explanation,
        correctDisplay: ex.correctSentence.join(' '),
      );
}

/// Computes star rating from accuracy ratio (0.0–1.0).
int starsForAccuracy(double accuracy) {
  if (accuracy >= 0.90) return 3;
  if (accuracy >= 0.70) return 2;
  return 1;
}
