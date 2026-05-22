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
  final String? persian;
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
    required this.exercises,
    this.grammarPoint,
    this.explanationNotes,
    this.examples = const [],
    this.titleFa,
    this.explanationFa,
    this.xpReward,
    this.estimatedMinutes,
    this.tags = const [],
    this.prerequisites = const [],
    this.isRevision = false,
  });

  final String id;
  final String level;
  final int order;
  final String title;
  final String explanation;
  final List<Exercise> exercises;

  /// Short learning objective label (grammarPoint field in JSON).
  final String? grammarPoint;

  /// Bullet notes from the explanation object.
  final List<String>? explanationNotes;

  /// Optional inline examples (legacy field; most lessons embed in explanation).
  final List<GrammarExample> examples;

  final String? titleFa;
  final String? explanationFa;

  /// True when the JSON source is a revision quiz (has 'questions' not 'exercises').
  final bool isRevision;
  final int? xpReward;
  final int? estimatedMinutes;
  final List<String> tags;
  final List<String> prerequisites;

  String localizedTitle(String lang) =>
      lang == 'fa' && titleFa != null ? titleFa! : title;

  String localizedExplanation(String lang) =>
      lang == 'fa' && explanationFa != null ? explanationFa! : explanation;

  factory GrammarUnit.fromJson(Map<String, dynamic> json) {
    // --- explanation: object {text,notes}, plain string, or missing (revision) ---
    String explanationText;
    List<String>? explanationNotes;
    final rawExplanation = json['explanation'];
    if (rawExplanation is Map<String, dynamic>) {
      explanationText = rawExplanation['text'] as String? ?? '';
      explanationNotes =
          (rawExplanation['notes'] as List<dynamic>?)?.cast<String>();
    } else {
      // Plain string OR null (revision quiz uses 'description' instead)
      explanationText = rawExplanation as String? ??
          json['description'] as String? ?? '';
    }

    // --- order: accepts both 'lessonOrder' (new) and 'order' (legacy) ---
    final order = (json['lessonOrder'] ?? json['order'] ?? 0) as int;

    // --- examples: optional in new schema ---
    final List<GrammarExample> examples = json['examples'] != null
        ? (json['examples'] as List<dynamic>)
            .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
            .toList()
        : const [];

    return GrammarUnit(
      id: json['id'] as String,
      level: json['level'] as String,
      order: order,
      title: json['title'] as String,
      explanation: explanationText,
      explanationNotes: explanationNotes,
      grammarPoint: json['grammarPoint'] as String?,
      examples: examples,
      // Revision JSONs use 'questions'; lesson JSONs use 'exercises'
      exercises: ((json['exercises'] ?? json['questions']) as List<dynamic>? ?? [])
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      titleFa: json['title_fa'] as String?,
      explanationFa: json['explanation_fa'] as String?,
      xpReward: json['xpReward'] as int?,
      estimatedMinutes: json['estimatedMinutes'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      prerequisites:
          (json['prerequisites'] as List<dynamic>?)?.cast<String>() ?? const [],
      isRevision: json['questions'] != null,
    );
  }
}
