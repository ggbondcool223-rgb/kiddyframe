import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_kiddy_frame_entity.dart';
import 'db_kiddy_frame_migration.dart';
class KiddyFrameDatabase extends GetxService {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'kiddy_frame.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: KiddyFrameMigration.migrate,
    );
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE works (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        original_photo_path TEXT,
        decoration_config TEXT,
        student_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE frames (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        frame_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        file_path TEXT NOT NULL,
        thumbnail_path TEXT NOT NULL,
        is_pro INTEGER NOT NULL DEFAULT 0,
        support_color_change INTEGER NOT NULL DEFAULT 0,
        default_colors TEXT,
        inner_padding_top INTEGER NOT NULL DEFAULT 50,
        inner_padding_right INTEGER NOT NULL DEFAULT 50,
        inner_padding_bottom INTEGER NOT NULL DEFAULT 50,
        inner_padding_left INTEGER NOT NULL DEFAULT 50,
        aspect_ratio_support TEXT,
        has_shadow INTEGER NOT NULL DEFAULT 0,
        shadow_config TEXT,
        adjustable_opacity INTEGER NOT NULL DEFAULT 0,
        decorations TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE frame_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE batch_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        batch_id TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        photo_count INTEGER NOT NULL,
        global_frame_config TEXT,
        individual_frames_config TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE artist_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        work_id INTEGER NOT NULL,
        work_title TEXT NOT NULL,
        creation_date TEXT,
        work_description TEXT,
        artist_name TEXT NOT NULL,
        artist_age INTEGER,
        artist_photo_path TEXT,
        school_info TEXT,
        template_id TEXT NOT NULL,
        show_artist_photo INTEGER NOT NULL DEFAULT 1,
        show_creation_date INTEGER NOT NULL DEFAULT 1,
        show_school_info INTEGER NOT NULL DEFAULT 1,
        watermark_path TEXT,
        card_file_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (work_id) REFERENCES works (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_key TEXT NOT NULL UNIQUE,
        setting_value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE stickers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sticker_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        file_path TEXT NOT NULL,
        thumbnail_path TEXT NOT NULL,
        is_pro INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE backgrounds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        background_id TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color_value TEXT,
        file_path TEXT,
        thumbnail_path TEXT,
        is_pro INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE INDEX idx_works_created_at ON works (created_at DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_works_student ON works (student_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_frames_category ON frames (category)
    ''');
    await db.execute('''
      CREATE INDEX idx_frame_categories_order ON frame_categories (order_index)
    ''');
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
    await db.execute('''
      CREATE INDEX idx_students_name ON students (name)
    ''');
    await db.execute('''
      CREATE INDEX idx_students_class ON students (class_name)
    ''');
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
    await db.execute('''
      CREATE INDEX idx_presets_created ON framing_presets (created_at DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_presets_usage ON framing_presets (usage_count DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_batch_records_created_at ON batch_records (created_at DESC)
    ''');
    await db.execute('''
      CREATE INDEX idx_artist_cards_work_id ON artist_cards (work_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_stickers_category ON stickers (category)
    ''');
    await db.execute('''
      CREATE INDEX idx_backgrounds_type ON backgrounds (type)
    ''');
  }
  Future<List<WorkEntity>> getWorks() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'works',
        orderBy: 'created_at DESC, id DESC',
      );
      return List.generate(maps.length, (i) => WorkEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting works: $e');
      return [];
    }
  }
  Future<WorkEntity?> getWorkById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'works',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) return null;
      return WorkEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting work by id: $e');
      return null;
    }
  }
  Future<int> insertWork(WorkEntity work) async {
    try {
      final db = await database;
      return await db.insert('works', work.toMap());
    } catch (e) {
      print('Error inserting work: $e');
      return -1;
    }
  }
  Future<int> updateWork(WorkEntity work) async {
    try {
      final db = await database;
      return await db.update(
        'works',
        work.toMap(),
        where: 'id = ?',
        whereArgs: [work.id],
      );
    } catch (e) {
      print('Error updating work: $e');
      return 0;
    }
  }
  Future<int> deleteWork(int id) async {
    try {
      final db = await database;
      return await db.delete('works', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting work: $e');
      return 0;
    }
  }
  Future<int> clearAllWorks() async {
    try {
      final db = await database;
      return await db.delete('works');
    } catch (e) {
      print('Error clearing all works: $e');
      return 0;
    }
  }
  Future<List<WorkEntity>> getWorksByDateRange(
    String startDate,
    String endDate,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'works',
        where: 'created_at BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'created_at DESC, id DESC',
      );
      return List.generate(maps.length, (i) => WorkEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting works by date range: $e');
      return [];
    }
  }
  Future<List<FrameEntity>> getFrames() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('frames');
      return List.generate(maps.length, (i) => FrameEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting frames: $e');
      return [];
    }
  }
  Future<List<FrameEntity>> getFramesByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'frames',
        where: 'category = ?',
        whereArgs: [category],
      );
      return List.generate(maps.length, (i) => FrameEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting frames by category: $e');
      return [];
    }
  }
  Future<FrameEntity?> getFrameById(String frameId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'frames',
        where: 'frame_id = ?',
        whereArgs: [frameId],
      );
      if (maps.isEmpty) return null;
      return FrameEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting frame by id: $e');
      return null;
    }
  }
  Future<int> insertFrame(FrameEntity frame) async {
    try {
      final db = await database;
      return await db.insert('frames', frame.toMap());
    } catch (e) {
      print('Error inserting frame: $e');
      return -1;
    }
  }
  Future<int> updateFrame(FrameEntity frame) async {
    try {
      final db = await database;
      return await db.update(
        'frames',
        frame.toMap(),
        where: 'frame_id = ?',
        whereArgs: [frame.frameId],
      );
    } catch (e) {
      print('Error updating frame: $e');
      return 0;
    }
  }
  Future<int> deleteFrame(String frameId) async {
    try {
      final db = await database;
      return await db.delete(
        'frames',
        where: 'frame_id = ?',
        whereArgs: [frameId],
      );
    } catch (e) {
      print('Error deleting frame: $e');
      return 0;
    }
  }
  Future<List<FrameCategoryEntity>> getFrameCategories() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'frame_categories',
        orderBy: 'order_index ASC',
      );
      return List.generate(
        maps.length,
        (i) => FrameCategoryEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting frame categories: $e');
      return [];
    }
  }
  Future<FrameCategoryEntity?> getDefaultFrameCategory() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'frame_categories',
        where: 'is_default = ?',
        whereArgs: [1],
      );
      if (maps.isEmpty) return null;
      return FrameCategoryEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting default frame category: $e');
      return null;
    }
  }
  Future<int> insertFrameCategory(FrameCategoryEntity category) async {
    try {
      final db = await database;
      return await db.insert('frame_categories', category.toMap());
    } catch (e) {
      print('Error inserting frame category: $e');
      return -1;
    }
  }
  Future<int> updateFrameCategory(FrameCategoryEntity category) async {
    try {
      final db = await database;
      return await db.update(
        'frame_categories',
        category.toMap(),
        where: 'category_id = ?',
        whereArgs: [category.categoryId],
      );
    } catch (e) {
      print('Error updating frame category: $e');
      return 0;
    }
  }
  Future<List<BatchRecordEntity>> getBatchRecords() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'batch_records',
        orderBy: 'created_at DESC, id DESC',
      );
      return List.generate(
        maps.length,
        (i) => BatchRecordEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting batch records: $e');
      return [];
    }
  }
  Future<BatchRecordEntity?> getBatchRecordById(String batchId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'batch_records',
        where: 'batch_id = ?',
        whereArgs: [batchId],
      );
      if (maps.isEmpty) return null;
      return BatchRecordEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting batch record by id: $e');
      return null;
    }
  }
  Future<int> insertBatchRecord(BatchRecordEntity record) async {
    try {
      final db = await database;
      return await db.insert('batch_records', record.toMap());
    } catch (e) {
      print('Error inserting batch record: $e');
      return -1;
    }
  }
  Future<int> updateBatchRecord(BatchRecordEntity record) async {
    try {
      final db = await database;
      return await db.update(
        'batch_records',
        record.toMap(),
        where: 'batch_id = ?',
        whereArgs: [record.batchId],
      );
    } catch (e) {
      print('Error updating batch record: $e');
      return 0;
    }
  }
  Future<int> deleteBatchRecord(String batchId) async {
    try {
      final db = await database;
      return await db.delete(
        'batch_records',
        where: 'batch_id = ?',
        whereArgs: [batchId],
      );
    } catch (e) {
      print('Error deleting batch record: $e');
      return 0;
    }
  }
  Future<List<ArtistCardEntity>> getArtistCards() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'artist_cards',
        orderBy: 'created_at DESC, id DESC',
      );
      return List.generate(
        maps.length,
        (i) => ArtistCardEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting artist cards: $e');
      return [];
    }
  }
  Future<List<ArtistCardEntity>> getArtistCardsByWorkId(int workId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'artist_cards',
        where: 'work_id = ?',
        whereArgs: [workId],
        orderBy: 'created_at DESC, id DESC',
      );
      return List.generate(
        maps.length,
        (i) => ArtistCardEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting artist cards by work id: $e');
      return [];
    }
  }
  Future<int> insertArtistCard(ArtistCardEntity card) async {
    try {
      final db = await database;
      return await db.insert('artist_cards', card.toMap());
    } catch (e) {
      print('Error inserting artist card: $e');
      return -1;
    }
  }
  Future<int> updateArtistCard(ArtistCardEntity card) async {
    try {
      final db = await database;
      return await db.update(
        'artist_cards',
        card.toMap(),
        where: 'id = ?',
        whereArgs: [card.id],
      );
    } catch (e) {
      print('Error updating artist card: $e');
      return 0;
    }
  }
  Future<int> deleteArtistCard(int id) async {
    try {
      final db = await database;
      return await db.delete('artist_cards', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting artist card: $e');
      return 0;
    }
  }
  Future<List<SettingEntity>> getSettings() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('settings');
      return List.generate(maps.length, (i) => SettingEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting settings: $e');
      return [];
    }
  }
  Future<SettingEntity?> getSettingByKey(String key) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        where: 'setting_key = ?',
        whereArgs: [key],
      );
      if (maps.isEmpty) return null;
      return SettingEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting setting by key: $e');
      return null;
    }
  }
  Future<int> insertSetting(SettingEntity setting) async {
    try {
      final db = await database;
      return await db.insert('settings', setting.toMap());
    } catch (e) {
      print('Error inserting setting: $e');
      return -1;
    }
  }
  Future<int> updateSetting(SettingEntity setting) async {
    try {
      final db = await database;
      return await db.update(
        'settings',
        setting.toMap(),
        where: 'setting_key = ?',
        whereArgs: [setting.settingKey],
      );
    } catch (e) {
      print('Error updating setting: $e');
      return 0;
    }
  }
  Future<int> upsertSetting(SettingEntity setting) async {
    try {
      final existing = await getSettingByKey(setting.settingKey);
      if (existing == null) {
        return await insertSetting(setting);
      } else {
        return await updateSetting(setting);
      }
    } catch (e) {
      print('Error upserting setting: $e');
      return 0;
    }
  }
  Future<int> deleteSetting(String key) async {
    try {
      final db = await database;
      return await db.delete(
        'settings',
        where: 'setting_key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      print('Error deleting setting: $e');
      return 0;
    }
  }
  Future<List<StickerEntity>> getStickers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('stickers');
      return List.generate(maps.length, (i) => StickerEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting stickers: $e');
      return [];
    }
  }
  Future<List<StickerEntity>> getStickersByCategory(String category) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'stickers',
        where: 'category = ?',
        whereArgs: [category],
      );
      return List.generate(maps.length, (i) => StickerEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting stickers by category: $e');
      return [];
    }
  }
  Future<int> insertSticker(StickerEntity sticker) async {
    try {
      final db = await database;
      return await db.insert('stickers', sticker.toMap());
    } catch (e) {
      print('Error inserting sticker: $e');
      return -1;
    }
  }
  Future<int> updateSticker(StickerEntity sticker) async {
    try {
      final db = await database;
      return await db.update(
        'stickers',
        sticker.toMap(),
        where: 'sticker_id = ?',
        whereArgs: [sticker.stickerId],
      );
    } catch (e) {
      print('Error updating sticker: $e');
      return 0;
    }
  }
  Future<int> deleteSticker(String stickerId) async {
    try {
      final db = await database;
      return await db.delete(
        'stickers',
        where: 'sticker_id = ?',
        whereArgs: [stickerId],
      );
    } catch (e) {
      print('Error deleting sticker: $e');
      return 0;
    }
  }
  Future<List<BackgroundEntity>> getBackgrounds() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('backgrounds');
      return List.generate(
        maps.length,
        (i) => BackgroundEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting backgrounds: $e');
      return [];
    }
  }
  Future<List<BackgroundEntity>> getBackgroundsByType(String type) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'backgrounds',
        where: 'type = ?',
        whereArgs: [type],
      );
      return List.generate(
        maps.length,
        (i) => BackgroundEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting backgrounds by type: $e');
      return [];
    }
  }
  Future<int> insertBackground(BackgroundEntity background) async {
    try {
      final db = await database;
      return await db.insert('backgrounds', background.toMap());
    } catch (e) {
      print('Error inserting background: $e');
      return -1;
    }
  }
  Future<int> updateBackground(BackgroundEntity background) async {
    try {
      final db = await database;
      return await db.update(
        'backgrounds',
        background.toMap(),
        where: 'background_id = ?',
        whereArgs: [background.backgroundId],
      );
    } catch (e) {
      print('Error updating background: $e');
      return 0;
    }
  }
  Future<int> deleteBackground(String backgroundId) async {
    try {
      final db = await database;
      return await db.delete(
        'backgrounds',
        where: 'background_id = ?',
        whereArgs: [backgroundId],
      );
    } catch (e) {
      print('Error deleting background: $e');
      return 0;
    }
  }
  Future<List<StudentEntity>> getStudents({String? className}) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps;
      if (className != null) {
        maps = await db.query(
          'students',
          where: 'class_name = ?',
          whereArgs: [className],
          orderBy: 'name ASC',
        );
      } else {
        maps = await db.query(
          'students',
          orderBy: 'created_at DESC',
        );
      }
      return List.generate(maps.length, (i) => StudentEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }
  Future<StudentEntity?> getStudentById(String studentId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'students',
        where: 'student_id = ?',
        whereArgs: [studentId],
      );
      if (maps.isEmpty) return null;
      return StudentEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting student by id: $e');
      return null;
    }
  }
  Future<List<StudentEntity>> searchStudents(String keyword) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'students',
        where: 'name LIKE ? OR class_name LIKE ?',
        whereArgs: ['%$keyword%', '%$keyword%'],
        orderBy: 'name ASC',
      );
      return List.generate(maps.length, (i) => StudentEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error searching students: $e');
      return [];
    }
  }
  Future<int> getStudentWorkCount(String studentId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM works WHERE student_id = ?',
        [studentId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error getting student work count: $e');
      return 0;
    }
  }
  Future<int> insertStudent(StudentEntity student) async {
    try {
      final db = await database;
      return await db.insert('students', student.toMap());
    } catch (e) {
      print('Error inserting student: $e');
      return -1;
    }
  }
  Future<int> updateStudent(StudentEntity student) async {
    try {
      final db = await database;
      return await db.update(
        'students',
        student.toMap(),
        where: 'student_id = ?',
        whereArgs: [student.studentId],
      );
    } catch (e) {
      print('Error updating student: $e');
      return 0;
    }
  }
  Future<int> deleteStudent(
    String studentId, {
    bool deleteWorks = false,
  }) async {
    try {
      final db = await database;
      if (deleteWorks) {
        await db.delete(
          'works',
          where: 'student_id = ?',
          whereArgs: [studentId],
        );
      } else {
        await db.update(
          'works',
          {'student_id': null},
          where: 'student_id = ?',
          whereArgs: [studentId],
        );
      }
      return await db.delete(
        'students',
        where: 'student_id = ?',
        whereArgs: [studentId],
      );
    } catch (e) {
      print('Error deleting student: $e');
      return 0;
    }
  }
  Future<int> assignWorkToStudent(int workId, String studentId) async {
    try {
      final db = await database;
      return await db.update(
        'works',
        {'student_id': studentId},
        where: 'id = ?',
        whereArgs: [workId],
      );
    } catch (e) {
      print('Error assigning work to student: $e');
      return 0;
    }
  }
  Future<void> assignWorksToStudent(
    List<int> workIds,
    String studentId,
  ) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (final workId in workIds) {
        batch.update(
          'works',
          {'student_id': studentId},
          where: 'id = ?',
          whereArgs: [workId],
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print('Error assigning works to student: $e');
    }
  }
  Future<List<WorkEntity>> getWorksByStudent(String studentId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'works',
        where: 'student_id = ?',
        whereArgs: [studentId],
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => WorkEntity.fromMap(maps[i]));
    } catch (e) {
      print('Error getting works by student: $e');
      return [];
    }
  }
  Future<int> unassignWorkFromStudent(int workId) async {
    try {
      final db = await database;
      return await db.update(
        'works',
        {'student_id': null},
        where: 'id = ?',
        whereArgs: [workId],
      );
    } catch (e) {
      print('Error unassigning work from student: $e');
      return 0;
    }
  }
  Future<List<FramingPresetEntity>> getPresets({
    String orderBy = 'created_at DESC',
  }) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'framing_presets',
        orderBy: orderBy,
      );
      return List.generate(
        maps.length,
        (i) => FramingPresetEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting presets: $e');
      return [];
    }
  }
  Future<FramingPresetEntity?> getPresetById(String presetId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'framing_presets',
        where: 'preset_id = ?',
        whereArgs: [presetId],
      );
      if (maps.isEmpty) return null;
      return FramingPresetEntity.fromMap(maps.first);
    } catch (e) {
      print('Error getting preset by id: $e');
      return null;
    }
  }
  Future<List<FramingPresetEntity>> getRecentlyUsedPresets({
    int limit = 3,
  }) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'framing_presets',
        where: 'usage_count > 0',
        orderBy: 'usage_count DESC',
        limit: limit,
      );
      return List.generate(
        maps.length,
        (i) => FramingPresetEntity.fromMap(maps[i]),
      );
    } catch (e) {
      print('Error getting recently used presets: $e');
      return [];
    }
  }
  Future<int> insertPreset(FramingPresetEntity preset) async {
    try {
      final db = await database;
      return await db.insert('framing_presets', preset.toMap());
    } catch (e) {
      print('Error inserting preset: $e');
      return -1;
    }
  }
  Future<int> updatePreset(FramingPresetEntity preset) async {
    try {
      final db = await database;
      return await db.update(
        'framing_presets',
        preset.toMap(),
        where: 'preset_id = ?',
        whereArgs: [preset.presetId],
      );
    } catch (e) {
      print('Error updating preset: $e');
      return 0;
    }
  }
  Future<int> deletePreset(String presetId) async {
    try {
      final db = await database;
      return await db.delete(
        'framing_presets',
        where: 'preset_id = ?',
        whereArgs: [presetId],
      );
    } catch (e) {
      print('Error deleting preset: $e');
      return 0;
    }
  }
  Future<int> incrementPresetUsage(String presetId) async {
    try {
      final db = await database;
      return await db.rawUpdate(
        'UPDATE framing_presets SET usage_count = usage_count + 1, updated_at = ? WHERE preset_id = ?',
        [DateTime.now().toIso8601String(), presetId],
      );
    } catch (e) {
      print('Error incrementing preset usage: $e');
      return 0;
    }
  }
}
