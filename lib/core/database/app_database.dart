import 'package:drift/drift.dart';

// Conditional import: picks web or native executor automatically
import 'connection_web.dart' if (dart.library.io) 'connection_native.dart';

part 'app_database.g.dart';

// ── Tables ────────────────────────────────────────────────────────────────────

class LearnerProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().withDefault(const Constant('Learner'))();
  TextColumn get currentLevelId => text().withDefault(const Constant('a1'))();
  IntColumn get totalXp => integer().withDefault(const Constant(0))();
  IntColumn get currentStreakDays => integer().withDefault(const Constant(0))();
  TextColumn get lastActivityDate => text().nullable()();
  TextColumn get createdAt => text()();
}

class UnitProgress extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learnerId => integer().references(LearnerProfiles, #id)();
  TextColumn get unitId => text()();
  TextColumn get unitType => text()(); // grammar | vocabulary | exam
  TextColumn get status =>
      text().withDefault(const Constant('not_started'))(); // not_started | in_progress | complete
  IntColumn get stars => integer().withDefault(const Constant(0))(); // 0–3
  RealColumn get bestAccuracy => real().withDefault(const Constant(0.0))();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  TextColumn get lastAttemptAt => text().nullable()();
  TextColumn get sessionCheckpoint => text().nullable()(); // JSON: last completed exercise id
}

class ExerciseResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learnerId => integer().references(LearnerProfiles, #id)();
  TextColumn get unitId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get attemptNumber => integer()();
  BoolColumn get correct => boolean()();
  IntColumn get timeTakenMs => integer().nullable()();
  TextColumn get attemptedAt => text()();
}

class WordMastery extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learnerId => integer().references(LearnerProfiles, #id)();
  TextColumn get cardId => text()();
  IntColumn get repetitionCount => integer().withDefault(const Constant(0))();
  RealColumn get easinessFactor => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(0))();
  TextColumn get nextReviewDate => text().nullable()();
  TextColumn get lastReviewedAt => text().nullable()();
  BoolColumn get mastered => boolean().withDefault(const Constant(false))();
}

class ExamSessionResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get learnerId => integer().references(LearnerProfiles, #id)();
  TextColumn get examSetId => text()();
  TextColumn get sectionType => text()(); // reading | listening | grammar | writing
  RealColumn get accuracy => real()();
  IntColumn get timeTakenSeconds => integer()();
  RealColumn get readinessDelta => real()();
  TextColumn get completedAt => text()();
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  LearnerProfiles,
  UnitProgress,
  ExerciseResults,
  WordMastery,
  ExamSessionResults,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return openDatabaseConnection();
  }
}
