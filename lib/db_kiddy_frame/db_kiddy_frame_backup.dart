import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'data.dart';
import 'db_kiddy_frame_entity.dart';
class KiddyFrameBackup {
  final KiddyFrameDatabase _db;
  KiddyFrameBackup(this._db);
  Future<Map<String, dynamic>> exportAllData() async {
    try {
      final works = await _db.getWorks();
      final frames = await _db.getFrames();
      final frameCategories = await _db.getFrameCategories();
      final batchRecords = await _db.getBatchRecords();
      final artistCards = await _db.getArtistCards();
      final settings = await _db.getSettings();
      final stickers = await _db.getStickers();
      final backgrounds = await _db.getBackgrounds();
      return {
        'version': 1,
        'exported_at': DateTime.now().toIso8601String(),
        'works': works.map((w) => w.toMap()).toList(),
        'frames': frames.map((f) => f.toMap()).toList(),
        'frame_categories': frameCategories.map((c) => c.toMap()).toList(),
        'batch_records': batchRecords.map((r) => r.toMap()).toList(),
        'artist_cards': artistCards.map((c) => c.toMap()).toList(),
        'settings': settings.map((s) => s.toMap()).toList(),
        'stickers': stickers.map((s) => s.toMap()).toList(),
        'backgrounds': backgrounds.map((b) => b.toMap()).toList(),
      };
    } catch (e) {
      print('Error exporting data: $e');
      rethrow;
    }
  }
  Future<String> exportToJson() async {
    try {
      final data = await exportAllData();
      return jsonEncode(data);
    } catch (e) {
      print('Error exporting to JSON: $e');
      rethrow;
    }
  }
  Future<File> exportToFile(String dirPath) async {
    try {
      final jsonData = await exportToJson();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'kiddy_frame_backup_$timestamp.json';
      final filePath = path.join(dirPath, fileName);
      final file = File(filePath);
      await file.writeAsString(jsonData);
      return file;
    } catch (e) {
      print('Error exporting to file: $e');
      rethrow;
    }
  }
  Future<Map<String, int>> importFromJson(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      final Map<String, int> importCounts = {
        'works': 0,
        'frames': 0,
        'frame_categories': 0,
        'batch_records': 0,
        'artist_cards': 0,
        'settings': 0,
        'stickers': 0,
        'backgrounds': 0,
      };
      if (data['works'] != null) {
        for (final workMap in data['works']) {
          final work = WorkEntity.fromMap(workMap);
          await _db.insertWork(work);
          importCounts['works'] = importCounts['works']! + 1;
        }
      }
      if (data['frames'] != null) {
        for (final frameMap in data['frames']) {
          final frame = FrameEntity.fromMap(frameMap);
          await _db.insertFrame(frame);
          importCounts['frames'] = importCounts['frames']! + 1;
        }
      }
      if (data['frame_categories'] != null) {
        for (final categoryMap in data['frame_categories']) {
          final category = FrameCategoryEntity.fromMap(categoryMap);
          await _db.insertFrameCategory(category);
          importCounts['frame_categories'] =
              importCounts['frame_categories']! + 1;
        }
      }
      if (data['batch_records'] != null) {
        for (final recordMap in data['batch_records']) {
          final record = BatchRecordEntity.fromMap(recordMap);
          await _db.insertBatchRecord(record);
          importCounts['batch_records'] = importCounts['batch_records']! + 1;
        }
      }
      if (data['artist_cards'] != null) {
        for (final cardMap in data['artist_cards']) {
          final card = ArtistCardEntity.fromMap(cardMap);
          await _db.insertArtistCard(card);
          importCounts['artist_cards'] = importCounts['artist_cards']! + 1;
        }
      }
      if (data['settings'] != null) {
        for (final settingMap in data['settings']) {
          final setting = SettingEntity.fromMap(settingMap);
          await _db.upsertSetting(setting);
          importCounts['settings'] = importCounts['settings']! + 1;
        }
      }
      if (data['stickers'] != null) {
        for (final stickerMap in data['stickers']) {
          final sticker = StickerEntity.fromMap(stickerMap);
          await _db.insertSticker(sticker);
          importCounts['stickers'] = importCounts['stickers']! + 1;
        }
      }
      if (data['backgrounds'] != null) {
        for (final backgroundMap in data['backgrounds']) {
          final background = BackgroundEntity.fromMap(backgroundMap);
          await _db.insertBackground(background);
          importCounts['backgrounds'] = importCounts['backgrounds']! + 1;
        }
      }
      return importCounts;
    } catch (e) {
      print('Error importing from JSON: $e');
      rethrow;
    }
  }
  Future<Map<String, int>> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonData = await file.readAsString();
      return await importFromJson(jsonData);
    } catch (e) {
      print('Error importing from file: $e');
      rethrow;
    }
  }
  Future<bool> clearAllData() async {
    try {
      final db = await _db.database;
      await db.delete('works');
      await db.delete('frames');
      await db.delete('frame_categories');
      await db.delete('batch_records');
      await db.delete('artist_cards');
      await db.delete('settings');
      await db.delete('stickers');
      await db.delete('backgrounds');
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }
}
