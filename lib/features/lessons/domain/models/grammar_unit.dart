import 'exercise.dart';

final class GrammarExample {
  const GrammarExample({
    required this.polish,
    required this.english,
    this.persian,
    this.note,
    this.noteFa,
  });

  final String polish;
  final String english;
  final String? persian; // Farsi translation of the Polish phrase
  final String? note;
  final String? noteFa;

  factory GrammarExample.fromJson(Map<String, dynamic> json) => GrammarExample(
        polish: json['polish'] as String,
        english: json['english'] as String,
        persian: json['persian'] as String?,
        note: json['note'] as String?,
        noteFa: json['note_fa'] as String?,
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
    this.titleFa,
    this.explanationFa,
  });

  final String id;
  final String level;
  final int order;
  final String title;
  final String explanation;
  final List<GrammarExample> examples;
  final List<Exercise> exercises;
  final String? titleFa;
  final String? explanationFa;

  /// Returns the title in the given teaching language, falling back to English.
  String localizedTitle(String lang) =>
      lang == 'fa' && titleFa != null ? titleFa! : title;

  /// Returns the explanation in the given teaching language, falling back to English.
  String localizedExplanation(String lang) =>
      lang == 'fa' && explanationFa != null ? explanationFa! : explanation;

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
        titleFa: json['title_fa'] as String?,
        explanationFa: json['explanation_fa'] as String?,
      );
}
