import 'exercise.dart';

final class GrammarExample {
  const GrammarExample({
    required this.polish,
    required this.english,
    this.note,
  });

  final String polish;
  final String english;
  final String? note;

  factory GrammarExample.fromJson(Map<String, dynamic> json) =>
      GrammarExample(
        polish: json['polish'] as String,
        english: json['english'] as String,
        note: json['note'] as String?,
      );
}

final class GrammarUnit {
  const GrammarUnit({
    required this.id,
    required this.level,
    required this.order,
    required this.title,
    required this.explanation,
    required this.examples,
    required this.exercises,
  });

  final String id;
  final String level;
  final int order;
  final String title;
  final String explanation;
  final List<GrammarExample> examples;
  final List<Exercise> exercises;

  factory GrammarUnit.fromJson(Map<String, dynamic> json) => GrammarUnit(
        id: json['id'] as String,
        level: json['level'] as String,
        order: json['order'] as int,
        title: json['title'] as String,
        explanation: json['explanation'] as String,
        examples: (json['examples'] as List<dynamic>)
            .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
            .toList(),
        exercises: (json['exercises'] as List<dynamic>)
            .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
