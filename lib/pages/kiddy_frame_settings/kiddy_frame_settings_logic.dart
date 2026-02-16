import 'dart:io';
import 'package:get/get.dart';
import '../../utils/index.dart';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
import 'package:flutter/material.dart';
class KiddyFrameSettingsLogic extends GetxController {
  final isClearingData = false.obs;
  Future<void> onClearAllData() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Clear All Data'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action will delete:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• All saved works'),
              Text('• All photos and frames'),
              Text('• All app data'),
              SizedBox(height: 16),
              Text(
                'This action cannot be undone!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      isClearingData.value = true;
      final dbService = Get.find<KiddyFrameDatabaseService>();
      final works = await dbService.database.getWorks();
      for (final work in works) {
        try {
          final file = File(work.filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Failed to delete file: ${work.filePath}');
        }
      }
      await dbService.database.clearAllWorks();
      isClearingData.value = false;
      successToast('All data cleared successfully');
      Get.back();
    } catch (e) {
      isClearingData.value = false;
      errorToast('Failed to clear data: ${e.toString()}');
    }
  }
}
