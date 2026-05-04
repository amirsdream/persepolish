// Run: dart run tool/validate_content.dart
// Validates all JSON content files under assets/content/ against expected schemas.
// Exits 0 on success, 1 with error list on failure.

import 'dart:convert';
import 'dart:io';

void main() async {
  final errors = <String>[];
  final ids = <String>{};

  final contentDir = Directory('assets/content');
  if (!contentDir.existsSync()) {
    stderr.writeln('ERROR: assets/content/ directory not found. Run from project root.');
    exit(1);
  }

  await for (final entity in contentDir.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.json')) continue;
    final relativePath = entity.path.replaceAll('\\', '/');
    final content = entity.readAsStringSync();

    Map<String, dynamic> json;
    try {
      json = jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      errors.add('$relativePath: invalid JSON — $e');
      continue;
    }

    // Skip levels.json (different schema)
    if (relativePath.endsWith('levels.json')) {
      _validateLevelsJson(json, relativePath, errors);
      continue;
    }

    final pathParts = relativePath.split('/');
    // Expected: assets/content/{level}/{type}/{id}.json
    if (pathParts.length < 5) continue;
    final type = pathParts[pathParts.length - 2]; // grammar / vocabulary / exam

    switch (type) {
      case 'grammar':
        _validateGrammarUnit(json, relativePath, errors, ids);
      case 'vocabulary':
        _validateVocabularySet(json, relativePath, errors, ids);
      case 'exam':
        _validateExamSet(json, relativePath, errors, ids);
      default:
        // Unknown type directory — skip
        break;
    }
  }

  if (errors.isEmpty) {
    stdout.writeln('✅ Content validation passed. No errors found.');
    exit(0);
  } else {
    stderr.writeln('❌ Content validation failed with ${errors.length} error(s):\n');
    for (final e in errors) {
      stderr.writeln('  • $e');
    }
    exit(1);
  }
}

void _validateLevelsJson(
    Map<String, dynamic> json, String path, List<String> errors) {
  if (json['levels'] is! List) {
    errors.add('$path: missing "levels" array');
    return;
  }
  for (final level in json['levels'] as List) {
    final m = level as Map<String, dynamic>;
    _requireField(m, 'id', path, errors);
    _requireField(m, 'name', path, errors);
    _requireField(m, 'status', path, errors);
  }
}

void _validateGrammarUnit(Map<String, dynamic> json, String path,
    List<String> errors, Set<String> ids) {
  _requireField(json, 'id', path, errors);
  _requireField(json, 'level', path, errors);
  _requireField(json, 'title', path, errors);
  _requireField(json, 'explanation', path, errors);
  _requireField(json, 'exercises', path, errors);

  final id = json['id'] as String?;
  if (id != null) {
    if (!ids.add(id)) {
      errors.add('$path: duplicate ID "$id"');
    }
  }

  final explanation = json['explanation'] as String? ?? '';
  if (explanation.length < 50) {
    errors.add('$path: explanation too short (${explanation.length} chars, min 50)');
  }

  final exercises = json['exercises'];
  if (exercises is! List) {
    errors.add('$path: "exercises" must be an array');
    return;
  }
  if (exercises.length < 5) {
    errors.add('$path: only ${exercises.length} exercises (min 5 required)');
  }

  for (var i = 0; i < exercises.length; i++) {
    final ex = exercises[i] as Map<String, dynamic>;
    _requireField(ex, 'type', '$path[exercise $i]', errors);
    _requireField(ex, 'id', '$path[exercise $i]', errors);
    _requireField(ex, 'prompt', '$path[exercise $i]', errors);
    _requireField(ex, 'explanation', '$path[exercise $i]', errors);

    final exId = ex['id'] as String?;
    if (exId != null && !ids.add(exId)) {
      errors.add('$path[exercise $i]: duplicate exercise ID "$exId"');
    }

    final type = ex['type'] as String?;
    switch (type) {
      case 'multiple_choice':
        _requireField(ex, 'options', '$path[exercise $i]', errors);
        _requireField(ex, 'correct_index', '$path[exercise $i]', errors);
        final opts = ex['options'] as List?;
        if (opts != null && opts.length < 2) {
          errors.add('$path[exercise $i]: multiple_choice needs ≥2 options');
        }
      case 'fill_in_blank':
        _requireField(ex, 'sentence_template', '$path[exercise $i]', errors);
        _requireField(ex, 'accepted_answers', '$path[exercise $i]', errors);
        final answers = ex['accepted_answers'] as List?;
        if (answers != null && answers.isEmpty) {
          errors.add('$path[exercise $i]: accepted_answers must not be empty');
        }
      case 'sentence_order':
        _requireField(ex, 'words', '$path[exercise $i]', errors);
        _requireField(ex, 'correct_order', '$path[exercise $i]', errors);
        final words = ex['words'] as List?;
        final order = ex['correct_order'] as List?;
        if (words != null && order != null && words.length != order.length) {
          errors.add('$path[exercise $i]: words and correct_order length mismatch');
        }
      default:
        if (type != null) {
          errors.add('$path[exercise $i]: unknown exercise type "$type"');
        }
    }
  }
}

void _validateVocabularySet(Map<String, dynamic> json, String path,
    List<String> errors, Set<String> ids) {
  _requireField(json, 'id', path, errors);
  _requireField(json, 'level', path, errors);
  _requireField(json, 'title', path, errors);
  _requireField(json, 'cards', path, errors);

  final id = json['id'] as String?;
  if (id != null && !ids.add(id)) {
    errors.add('$path: duplicate ID "$id"');
  }

  final cards = json['cards'];
  if (cards is! List) {
    errors.add('$path: "cards" must be an array');
    return;
  }
  if (cards.length < 10) {
    errors.add('$path: only ${cards.length} cards (min 10 required)');
  }
  for (var i = 0; i < cards.length; i++) {
    final card = cards[i] as Map<String, dynamic>;
    _requireField(card, 'id', '$path[card $i]', errors);
    _requireField(card, 'polish', '$path[card $i]', errors);
    _requireField(card, 'english', '$path[card $i]', errors);
    _requireField(card, 'category', '$path[card $i]', errors);
  }
}

void _validateExamSet(Map<String, dynamic> json, String path,
    List<String> errors, Set<String> ids) {
  _requireField(json, 'id', path, errors);
  _requireField(json, 'level', path, errors);
  _requireField(json, 'title', path, errors);
  _requireField(json, 'section_type', path, errors);
  _requireField(json, 'time_limit_seconds', path, errors);
  _requireField(json, 'exercises', path, errors);

  final id = json['id'] as String?;
  if (id != null && !ids.add(id)) {
    errors.add('$path: duplicate ID "$id"');
  }

  final validSections = {'reading', 'listening', 'grammar', 'writing'};
  final section = json['section_type'] as String?;
  if (section != null && !validSections.contains(section)) {
    errors.add('$path: invalid section_type "$section" (must be one of $validSections)');
  }

  final exercises = json['exercises'];
  if (exercises is! List) {
    errors.add('$path: "exercises" must be an array');
    return;
  }
  if (exercises.length < 5) {
    errors.add('$path: only ${exercises.length} exercises (min 5 required)');
  }
}

void _requireField(
    Map<String, dynamic> json, String field, String path, List<String> errors) {
  if (!json.containsKey(field) || json[field] == null) {
    errors.add('$path: missing required field "$field"');
  }
}
