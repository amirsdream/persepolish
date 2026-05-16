import 'package:flutter/material.dart';

enum LevelStatus { available, comingSoon }

enum UnitType { grammar, vocabulary, exam }

final class UnitSummary {
  const UnitSummary({
    required this.id,
    required this.title,
    this.titleFa,
    required this.unitType,
    required this.order,
    this.status = 'not_started',
    this.stars = 0,
  });

  final String id;
  final String title;
  final String? titleFa;
  final UnitType unitType;
  final int order;
  final String status;
  final int stars;

  bool get isComplete => status == 'complete';
  bool get isInProgress => status == 'in_progress';

  /// Returns the title in the requested language, falling back to English.
  String localizedTitle(String lang) =>
      (lang == 'fa' && titleFa != null) ? titleFa! : title;
}

final class Level {
  const Level({
    required this.id,
    required this.name,
    this.nameFa,
    required this.description,
    this.descriptionFa,
    required this.status,
    required this.unlockThreshold,
    required this.colorHex,
    required this.progressPercent,
    required this.isUnlocked,
    required this.grammarUnits,
    required this.vocabularySets,
    required this.examSets,
  });

  final String id;
  final String name;
  final String? nameFa;
  final String description;
  final String? descriptionFa;
  final LevelStatus status;
  final int unlockThreshold;
  final String colorHex;
  final double progressPercent;
  final bool isUnlocked;
  final List<UnitSummary> grammarUnits;
  final List<UnitSummary> vocabularySets;
  final List<UnitSummary> examSets;

  bool get isComingSoon => status == LevelStatus.comingSoon;

  int get totalStars => [...grammarUnits, ...vocabularySets]
      .fold(0, (sum, u) => sum + u.stars);

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  /// Returns the level name in the requested language, falling back to English.
  String localizedName(String lang) =>
      (lang == 'fa' && nameFa != null) ? nameFa! : name;

  /// Returns the level description in the requested language, falling back to English.
  String localizedDescription(String lang) =>
      (lang == 'fa' && descriptionFa != null) ? descriptionFa! : description;
}
