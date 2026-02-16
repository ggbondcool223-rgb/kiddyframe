import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
import '../../db_kiddy_frame/db_kiddy_frame_entity.dart';
import '../../utils/index.dart';
class KiddyFramePresetPreviewLogic extends GetxController {
  final _dbService = Get.find<KiddyFrameDatabaseService>();
  late final FramingPresetEntity preset;
  final config = Rx<Map<String, dynamic>?>(null);
  @override
  void onInit() {
    super.onInit();
    preset = Get.arguments['preset'] as FramingPresetEntity;
    _parseConfig();
  }
  void _parseConfig() {
    try {
      config.value = jsonDecode(preset.configJson) as Map<String, dynamic>;
    } catch (e) {
      errorToast('Failed to parse preset config');
      config.value = null;
    }
  }
  Future<void> deletePreset() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Preset'),
          content: Text('Delete "${preset.name}"?\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        final result = await _dbService.database.deletePreset(preset.presetId);
        if (result > 0) {
          successToast('Preset deleted');
          Get.back(result: true);
        } else {
          errorToast('Failed to delete preset');
        }
      }
    } catch (e) {
      errorToast('Error: $e');
    }
  }
  void applyToNewWork() {
    Get.back();
    Get.toNamed(
      '/kiddy_frame_photo_select',
      arguments: {'presetId': preset.presetId},
    );
  }
  String getFrameName() {
    if (config.value == null) return 'None';
    final frame = config.value!['frame'] as Map<String, dynamic>?;
    return frame?['frameName'] as String? ?? 'None';
  }
  String getBackgroundType() {
    if (config.value == null) return 'None';
    final bg = config.value!['background'] as Map<String, dynamic>?;
    final type = bg?['type'] as String? ?? 'none';
    if (type == 'color') {
      return 'Color: ${bg?['value']}';
    } else if (type == 'pattern') {
      return 'Pattern';
    }
    return 'None';
  }
  int getTextCount() {
    if (config.value == null) return 0;
    final texts = config.value!['texts'] as List?;
    return texts?.length ?? 0;
  }
  int getStickerCount() {
    if (config.value == null) return 0;
    final stickers = config.value!['stickers'] as List?;
    return stickers?.length ?? 0;
  }
}
