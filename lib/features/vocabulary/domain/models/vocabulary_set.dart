import 'dart:convert';
import 'package:flutter/services.dart';

// ── VocabularyCard ────────────────────────────────────────────────────────────

final class VocabularyCard {
  const VocabularyCard({
    required this.id,
    required this.polish,
    required this.english,
    required this.pronunciation,
    required this.category,
    required this.examplePolish,
    required this.exampleEnglish,
    this.persian,
    this.examplePersian,
    this.gender,
    this.partOfSpeech,
    this.audioAsset,
    this.tags = const [],
  });

  final String id;
  final String polish;
  final String english;
  final String? persian;
  final String pronunciation;
  final String? gender;
  final String? partOfSpeech;
  final String category;
  final String examplePolish;
  final String exampleEnglish;
  final String? examplePersian;
  final String? audioAsset;
  final List<String> tags;

  /// Returns the meaning in the requested language, falling back to English.
  String localizedMeaning(String lang) =>
      lang == 'fa' && persian != null ? persian! : english;

  /// Returns the example sentence in the requested language, falling back to English.
  String localizedExample(String lang) =>
      lang == 'fa' && examplePersian != null ? examplePersian! : exampleEnglish;

  factory VocabularyCard.fromJson(Map<String, dynamic> json) => VocabularyCard(
        id: json['id'] as String,
        polish: json['polish'] as String,
        english: json['english'] as String,
        persian: json['persian'] as String?,
        pronunciation: json['pronunciation'] as String? ?? '',
        gender: json['gender'] as String?,
        partOfSpeech: json['partOfSpeech'] as String?,
        category: json['category'] as String? ?? 'general',
        examplePolish: json['examplePolish'] as String? ?? '',
        exampleEnglish: json['exampleEnglish'] as String? ?? '',
        examplePersian: json['examplePersian'] as String?,
        audioAsset: json['audioAsset'] as String?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
}

// ── VocabularySet ─────────────────────────────────────────────────────────────

final class VocabularySet {
  const VocabularySet({
    required this.id,
    required this.level,
    required this.chapter,
    required this.title,
    required this.cards,
    this.titleFa,
    this.description,
    this.descriptionFa,
  });

  final String id;
  final String level;
  final int chapter;
  final String title;
  final String? titleFa;
  final String? description;
  final String? descriptionFa;
  final List<VocabularyCard> cards;

  String localizedTitle(String lang) =>
      lang == 'fa' && titleFa != null ? titleFa! : title;

  String? localizedDescription(String lang) =>
      lang == 'fa' && descriptionFa != null ? descriptionFa : description;

  factory VocabularySet.fromJson(Map<String, dynamic> json) => VocabularySet(
        id: json['id'] as String,
        level: json['level'] as String,
        chapter: json['chapter'] as int? ?? 0,
        title: json['title'] as String,
        titleFa: json['title_fa'] as String?,
        description: json['description'] as String?,
        descriptionFa: json['description_fa'] as String?,
        cards: (json['cards'] as List<dynamic>)
            .map((c) => VocabularyCard.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  /// Loads a vocabulary set from Flutter assets.
  static Future<VocabularySet> loadFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return VocabularySet.fromJson(json);
  }
}
