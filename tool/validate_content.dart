// Run: dart run tool/validate_content.dart
// Validates all JSON content files under assets/content/ against the schema
// defined in specs/002-pkpk-curriculum-content/contracts/content-schema.md
// Exits 0 on success, 1 with error list on failure.

import 'dart:convert';
import 'dart:io';

void main() async {
  final errors = <String>[];   // blocking — causes exit 1
  final warnings = <String>[]; // informational — logged but exit 0
  final ids = <String>{};

  final contentDir = Directory('assets/content');
  if (!contentDir.existsSync()) {
    stderr.writeln(
        'ERROR: assets/content/ directory not found. Run from project root.');
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

    if (relativePath.endsWith('levels.json')) {
      _validateLevelsJson(json, relativePath, errors);
      continue;
    }

    // Skip coming-soon placeholder files
    if (relativePath.endsWith('_coming_soon.json')) continue;

    final pathParts = relativePath.split('/');
    if (pathParts.length < 5) continue;
    final type = pathParts[pathParts.length - 2];

    final fileName = pathParts.last;
    switch (type) {
      case 'grammar':
        if (fileName.endsWith('-revision.json')) {
          _validateRevisionQuiz(json, relativePath, errors, ids);
        } else {
          _validateGrammarUnit(json, relativePath, errors, warnings, ids);
        }
      case 'vocabulary':
        _validateVocabularySet(json, relativePath, errors, ids);
      case 'exam':
        _validateExamSet(json, relativePath, errors, ids);
    }
  }

  if (warnings.isNotEmpty) {
    stdout.writeln('⚠️  ${warnings.length} warning(s):\n');
    for (final w in warnings) {
      stdout.writeln('  ⚠ $w');
    }
    stdout.writeln('');
  }

  if (errors.isEmpty) {
    stdout.writeln('✅ Content validation passed. No blocking errors found.');
    exit(0);
  } else {
    stderr.writeln(
        '❌ Content validation failed with ${errors.length} blocking error(s):\n');
    for (final e in errors) {
      stderr.writeln('  • $e');
    }
    exit(1);
  }
}

// ── levels.json ───────────────────────────────────────────────────────────────

void _validateLevelsJson(
    Map<String, dynamic> json, String path, List<String> errors) {
  if (json['levels'] is! List) {
    errors.add('$path: missing "levels" array');
    return;
  }
  for (final level in json['levels'] as List) {
    final m = level as Map<String, dynamic>;
    _req(m, 'id', path, errors);
    _req(m, 'name', path, errors);
    _req(m, 'status', path, errors);
  }
}

// ── Grammar lesson ────────────────────────────────────────────────────────────

void _validateGrammarUnit(Map<String, dynamic> json, String path,
    List<String> errors, List<String> warnings, Set<String> ids) {
  _req(json, 'id', path, errors);
  _req(json, 'level', path, errors);
  _req(json, 'title', path, errors);
  _req(json, 'explanation', path, errors);
  _req(json, 'exercises', path, errors);

  final id = json['id'] as String?;
  if (id != null && !ids.add(id)) {
    errors.add('$path: duplicate ID "$id"');
  }

  // explanation: object {text, notes?} OR plain string (legacy)
  final rawExplanation = json['explanation'];
  if (rawExplanation is Map<String, dynamic>) {
    final text = rawExplanation['text'] as String? ?? '';
    if (text.length < 50) {
      errors.add(
          '$path: explanation.text too short (${text.length} chars, min 50)');
    }
  } else if (rawExplanation is String) {
    if (rawExplanation.length < 50) {
      errors.add(
          '$path: explanation too short (${rawExplanation.length} chars, min 50)');
    }
  } else {
    errors.add('$path: explanation must be a string or {text, notes} object');
  }

  final exercises = json['exercises'];
  if (exercises is! List) {
    errors.add('$path: "exercises" must be an array');
    return;
  }
  if (exercises.length < 4) {
    errors.add('$path: only ${exercises.length} exercises (min 4 required)');
  }

  for (var i = 0; i < exercises.length; i++) {
    final ex = exercises[i] as Map<String, dynamic>;
    final label = '$path [exercise ${i + 1}]';
    _req(ex, 'id', label, errors);
    _req(ex, 'type', label, errors);
    // explanation is strongly recommended but tolerated as absent (app falls back to '')
    if (!ex.containsKey('explanation') || ex['explanation'] == null) {
      warnings.add('$label: missing recommended field "explanation" (shown after answer)');
    }

    final exId = ex['id'] as String?;
    if (exId != null && !ids.add(exId)) {
      errors.add('$label: duplicate exercise ID "$exId"');
    }

    final type = ex['type'] as String?;
    switch (type) {
      case 'multiple_choice':
        _req(ex, 'prompt', label, errors);
        _req(ex, 'options', label, errors);
        final ci = ex['correctIndex'] ?? ex['correct_index'];
        if (ci == null) {
          errors.add('$label: missing required field "correctIndex"');
        }
        final opts = ex['options'] as List?;
        if (opts != null && opts.length < 2) {
          errors.add('$label: multiple_choice needs ≥ 2 options');
        }

      case 'fill_blank':
        _req(ex, 'prompt', label, errors);
        _req(ex, 'answer', label, errors);
        _req(ex, 'acceptableAnswers', label, errors);
        final prompt = ex['prompt'] as String?;
        if (prompt != null && !prompt.contains('___')) {
          errors.add('$label: fill_blank prompt must contain "___"');
        }
        final answers = ex['acceptableAnswers'] as List?;
        if (answers != null && answers.isEmpty) {
          errors.add('$label: acceptableAnswers must not be empty');
        }

      case 'dictation_mc':
        _req(ex, 'options', label, errors);
        final ci = ex['correctIndex'] ?? ex['correct_index'];
        if (ci == null) {
          errors.add('$label: missing required field "correctIndex"');
        }
        final opts = ex['options'] as List?;
        if (opts != null && opts.length < 2) {
          errors.add('$label: dictation_mc needs ≥ 2 options');
        }
        // audioAsset is optional — graceful skip when absent

      case 'sentence_builder':
        _req(ex, 'prompt', label, errors);
        _req(ex, 'wordBank', label, errors);
        _req(ex, 'correctSequences', label, errors);
        final bank = ex['wordBank'] as List?;
        if (bank != null && bank.length < 3) {
          errors.add('$label: wordBank must have ≥ 3 words');
        }
        final seqs = ex['correctSequences'] as List?;
        if (seqs != null && seqs.isEmpty) {
          errors.add('$label: correctSequences must have ≥ 1 sequence');
        }

      // Legacy types — tolerated, not flagged as errors
      case 'fill_in_blank':
      case 'sentence_order':
        break;

      default:
        if (type != null) {
          errors.add('$label: unknown exercise type "$type"');
        }
    }
  }
}

// ── Vocabulary set ────────────────────────────────────────────────────────────

void _validateVocabularySet(Map<String, dynamic> json, String path,
    List<String> errors, Set<String> ids) {
  _req(json, 'id', path, errors);
  _req(json, 'level', path, errors);
  _req(json, 'title', path, errors);
  _req(json, 'cards', path, errors);

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
    final label = '$path [card ${i + 1}]';
    _req(card, 'id', label, errors);
    _req(card, 'polish', label, errors);
    _req(card, 'english', label, errors);
    _req(card, 'category', label, errors);
  }
}

// ── Revision quiz ─────────────────────────────────────────────────────────────
// Revision quizzes live under grammar/ and end in -revision.json.
// They use a lighter schema: id, level, title, passThreshold, questions[].

void _validateRevisionQuiz(Map<String, dynamic> json, String path,
    List<String> errors, Set<String> ids) {
  _req(json, 'id', path, errors);
  _req(json, 'level', path, errors);
  _req(json, 'title', path, errors);
  _req(json, 'questions', path, errors);

  final id = json['id'] as String?;
  if (id != null && !ids.add(id)) {
    errors.add('$path: duplicate ID "$id"');
  }

  final threshold = json['passThreshold'];
  if (threshold == null) {
    errors.add('$path: missing "passThreshold" (should be 0.70)');
  }

  final questions = json['questions'];
  if (questions is! List) {
    errors.add('$path: "questions" must be an array');
    return;
  }
  if (questions.length < 5) {
    errors.add('$path: only ${questions.length} questions (min 5 required)');
  }
  for (var i = 0; i < questions.length; i++) {
    final q = questions[i] as Map<String, dynamic>;
    final label = '$path [question ${i + 1}]';
    _req(q, 'id', label, errors);
    _req(q, 'type', label, errors);
    _req(q, 'prompt', label, errors);
    _req(q, 'explanation', label, errors);
  }
}

// ── Exam set ──────────────────────────────────────────────────────────────────

void _validateExamSet(Map<String, dynamic> json, String path,
    List<String> errors, Set<String> ids) {
  _req(json, 'id', path, errors);
  _req(json, 'level', path, errors);
  _req(json, 'title', path, errors);

  final id = json['id'] as String?;
  if (id != null && !ids.add(id)) {
    errors.add('$path: duplicate ID "$id"');
  }

  // Exam files may use 'exercises' (simple) or 'sections' (full PKE-style)
  final exercises = json['exercises'];
  final sections = json['sections'];
  if (exercises == null && sections == null) {
    errors.add('$path: exam must have either "exercises" or "sections" array');
    return;
  }
  if (exercises != null && exercises is! List) {
    errors.add('$path: "exercises" must be an array');
  }
  if (sections != null && sections is! List) {
    errors.add('$path: "sections" must be an array');
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

void _req(Map<String, dynamic> json, String field, String path,
    List<String> errors) {
  if (!json.containsKey(field) || json[field] == null) {
    errors.add('$path: missing required field "$field"');
  }
}
