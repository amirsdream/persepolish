import 'package:flutter_test/flutter_test.dart';
import 'package:lingualeap/features/lessons/domain/models/exercise.dart';
import 'package:lingualeap/features/lessons/domain/use_cases/submit_answer_use_case.dart';

void main() {
  const useCase = SubmitAnswerUseCase();

  group('SubmitAnswerUseCase — MultipleChoice', () {
    final exercise = MultipleChoiceExercise(
      id: 'test-mc-01',
      prompt: 'Test question',
      explanation: 'Option 0 is correct.',
      options: ['correct', 'wrong1', 'wrong2', 'wrong3'],
      correctIndex: 0,
    );

    test('returns isCorrect=true when correct index selected', () {
      final result = useCase.execute(exercise: exercise, answer: 0);
      expect(result.isCorrect, isTrue);
    });

    test('returns isCorrect=false for wrong index', () {
      final result = useCase.execute(exercise: exercise, answer: 2);
      expect(result.isCorrect, isFalse);
    });

    test('includes explanation in result', () {
      final result = useCase.execute(exercise: exercise, answer: 1);
      expect(result.explanation, equals('Option 0 is correct.'));
    });

    test('correctDisplay is the correct option text', () {
      final result = useCase.execute(exercise: exercise, answer: 1);
      expect(result.correctDisplay, equals('correct'));
    });
  });

  group('SubmitAnswerUseCase — FillInBlank', () {
    final exercise = FillInBlankExercise(
      id: 'test-fill-01',
      prompt: 'Test fill',
      explanation: 'Accept jestem or Jestem.',
      sentenceTemplate: '___ z Polski.',
      acceptedAnswers: ['jestem', 'Jestem'],
    );

    test('accepts exact match (lowercase)', () {
      final result = useCase.execute(exercise: exercise, answer: 'jestem');
      expect(result.isCorrect, isTrue);
    });

    test('accepts case-insensitive match', () {
      final result = useCase.execute(exercise: exercise, answer: 'JESTEM');
      expect(result.isCorrect, isTrue);
    });

    test('trims whitespace before comparison', () {
      final result = useCase.execute(exercise: exercise, answer: '  jestem  ');
      expect(result.isCorrect, isTrue);
    });

    test('returns false for wrong answer', () {
      final result = useCase.execute(exercise: exercise, answer: 'jesteś');
      expect(result.isCorrect, isFalse);
    });

    test('correctDisplay shows first accepted answer', () {
      final result = useCase.execute(exercise: exercise, answer: 'wrong');
      expect(result.correctDisplay, equals('jestem'));
    });
  });

  group('SubmitAnswerUseCase — SentenceOrder', () {
    final exercise = SentenceOrderExercise(
      id: 'test-order-01',
      prompt: 'Order the words',
      explanation: 'Correct order is [1, 0, 2].',
      words: ['świat', 'Dzień', 'dobry'],
      correctOrder: [1, 0, 2],
    );

    test('accepts correct order', () {
      final result = useCase.execute(exercise: exercise, answer: [1, 0, 2]);
      expect(result.isCorrect, isTrue);
    });

    test('rejects wrong order', () {
      final result = useCase.execute(exercise: exercise, answer: [0, 1, 2]);
      expect(result.isCorrect, isFalse);
    });

    test('rejects incomplete order', () {
      final result = useCase.execute(exercise: exercise, answer: [1, 0]);
      expect(result.isCorrect, isFalse);
    });

    test('correctDisplay joins correct words in order', () {
      final result = useCase.execute(exercise: exercise, answer: [0, 1, 2]);
      expect(result.correctDisplay, equals('Dzień świat dobry'));
    });
  });

  group('starsForAccuracy', () {
    test('returns 3 stars for accuracy >= 0.90', () {
      expect(starsForAccuracy(0.90), equals(3));
      expect(starsForAccuracy(1.00), equals(3));
      expect(starsForAccuracy(0.95), equals(3));
    });

    test('returns 2 stars for accuracy >= 0.70 and < 0.90', () {
      expect(starsForAccuracy(0.70), equals(2));
      expect(starsForAccuracy(0.80), equals(2));
      expect(starsForAccuracy(0.89), equals(2));
    });

    test('returns 1 star for accuracy < 0.70', () {
      expect(starsForAccuracy(0.69), equals(1));
      expect(starsForAccuracy(0.00), equals(1));
      expect(starsForAccuracy(0.50), equals(1));
    });
  });
}
