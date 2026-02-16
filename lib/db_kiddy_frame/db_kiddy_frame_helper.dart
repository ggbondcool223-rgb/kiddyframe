import 'data.dart';
import 'db_kiddy_frame_entity.dart';
class KiddyFrameDatabaseHelper {
  final KiddyFrameDatabase _db;
  KiddyFrameDatabaseHelper(this._db);
  Future<int> getTotalWorksCount() async {
    try {
      final works = await _db.getWorks();
      return works.length;
    } catch (e) {
      print('Error getting total works count: $e');
      return 0;
    }
  }
  Future<int> getTotalStorageSize() async {
    try {
      final works = await _db.getWorks();
      int totalSize = 0;
      for (final work in works) {
        totalSize += work.fileSize;
      }
      return totalSize;
    } catch (e) {
      print('Error getting total storage size: $e');
      return 0;
    }
  }
  Future<List<WorkEntity>> getWorksThisMonth() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      return await _db.getWorksByDateRange(
        startOfMonth.toIso8601String(),
        endOfMonth.toIso8601String(),
      );
    } catch (e) {
      print('Error getting works this month: $e');
      return [];
    }
  }
  Future<List<WorkEntity>> getWorksThisYear() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);
      return await _db.getWorksByDateRange(
        startOfYear.toIso8601String(),
        endOfYear.toIso8601String(),
      );
    } catch (e) {
      print('Error getting works this year: $e');
      return [];
    }
  }
  Future<Map<String, int>> getWorksCountByMonth(int year) async {
    try {
      final works = await _db.getWorks();
      final Map<String, int> monthCounts = {};
      for (int month = 1; month <= 12; month++) {
        final monthKey = '$year-${month.toString().padLeft(2, '0')}';
        monthCounts[monthKey] = 0;
      }
      for (final work in works) {
        final createdAt = DateTime.parse(work.createdAt);
        if (createdAt.year == year) {
          final monthKey =
              '$year-${createdAt.month.toString().padLeft(2, '0')}';
          monthCounts[monthKey] = (monthCounts[monthKey] ?? 0) + 1;
        }
      }
      return monthCounts;
    } catch (e) {
      print('Error getting works count by month: $e');
      return {};
    }
  }
  Future<List<FrameEntity>> getAvailableFramesByCategory(
    String category,
  ) async {
    try {
      final frames = await _db.getFramesByCategory(category);
      return frames.where((frame) => frame.isPro == 0).toList();
    } catch (e) {
      print('Error getting available frames by category: $e');
      return [];
    }
  }
  Future<List<FrameEntity>> getProFramesByCategory(String category) async {
    try {
      final frames = await _db.getFramesByCategory(category);
      return frames.where((frame) => frame.isPro == 1).toList();
    } catch (e) {
      print('Error getting pro frames by category: $e');
      return [];
    }
  }
  Future<String?> getSettingValue(String key, {String? defaultValue}) async {
    try {
      final setting = await _db.getSettingByKey(key);
      return setting?.settingValue ?? defaultValue;
    } catch (e) {
      print('Error getting setting value: $e');
      return defaultValue;
    }
  }
  Future<bool> updateSettingValue(String key, String value) async {
    try {
      final now = DateTime.now().toIso8601String();
      final setting = SettingEntity(
        settingKey: key,
        settingValue: value,
        updatedAt: now,
      );
      final result = await _db.upsertSetting(setting);
      return result > 0;
    } catch (e) {
      print('Error updating setting value: $e');
      return false;
    }
  }
  Future<List<ArtistCardEntity>> getRecentArtistCards({int limit = 10}) async {
    try {
      final cards = await _db.getArtistCards();
      return cards.take(limit).toList();
    } catch (e) {
      print('Error getting recent artist cards: $e');
      return [];
    }
  }
  Future<List<BatchRecordEntity>> getRecentBatchRecords({
    int limit = 10,
  }) async {
    try {
      final records = await _db.getBatchRecords();
      return records.take(limit).toList();
    } catch (e) {
      print('Error getting recent batch records: $e');
      return [];
    }
  }
  Future<bool> deleteWorkWithRelatedData(int workId) async {
    try {
      final artistCards = await _db.getArtistCardsByWorkId(workId);
      for (final card in artistCards) {
        await _db.deleteArtistCard(card.id!);
      }
      final result = await _db.deleteWork(workId);
      return result > 0;
    } catch (e) {
      print('Error deleting work with related data: $e');
      return false;
    }
  }
  Future<Map<String, dynamic>> getDatabaseStatistics() async {
    try {
      final worksCount = await getTotalWorksCount();
      final totalSize = await getTotalStorageSize();
      final framesCount = (await _db.getFrames()).length;
      final stickersCount = (await _db.getStickers()).length;
      final backgroundsCount = (await _db.getBackgrounds()).length;
      final artistCardsCount = (await _db.getArtistCards()).length;
      final batchRecordsCount = (await _db.getBatchRecords()).length;
      return {
        'works_count': worksCount,
        'total_size_bytes': totalSize,
        'total_size_mb': (totalSize / 1024 / 1024).toStringAsFixed(2),
        'frames_count': framesCount,
        'stickers_count': stickersCount,
        'backgrounds_count': backgroundsCount,
        'artist_cards_count': artistCardsCount,
        'batch_records_count': batchRecordsCount,
      };
    } catch (e) {
      print('Error getting database statistics: $e');
      return {};
    }
  }
}
