import 'package:sqflite/sqflite.dart';
class KiddyFrameMigration {
  static Future<void> migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
  }
  static Future<void> _migrateToV2(Database db) async {
    await db.execute('ALTER TABLE works ADD COLUMN student_id TEXT');
    await db.execute('CREATE INDEX idx_works_student ON works (student_id)');
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        age INTEGER,
        class_name TEXT,
        photo_path TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_students_name ON students (name)');
    await db.execute('CREATE INDEX idx_students_class ON students (class_name)');
    await db.execute('''
      CREATE TABLE framing_presets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        preset_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        description TEXT,
        thumbnail_path TEXT,
        config_json TEXT NOT NULL,
        usage_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_presets_created ON framing_presets (created_at DESC)');
    await db.execute('CREATE INDEX idx_presets_usage ON framing_presets (usage_count DESC)');
  }
}
