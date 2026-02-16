import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
import '../../db_kiddy_frame/db_kiddy_frame_entity.dart';
import '../../utils/index.dart';
class KiddyFramePresetManagementLogic extends GetxController {
  final _dbService = Get.find<KiddyFrameDatabaseService>();
  final presets = <FramingPresetEntity>[].obs;
  final isLoading = false.obs;
  final sortBy = 'created_at DESC'.obs;
  @override
  void onInit() {
    super.onInit();
    loadPresets();
  }
  Future<void> loadPresets() async {
    try {
      isLoading.value = true;
      final result = await _dbService.database.getPresets(orderBy: sortBy.value);
      presets.value = result;
    } catch (e) {
      errorToast('Failed to load presets: $e');
    } finally {
      isLoading.value = false;
    }
  }
  void changeSortBy(String newSortBy) {
    sortBy.value = newSortBy;
    loadPresets();
  }
  Future<void> deletePreset(FramingPresetEntity preset) async {
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
          loadPresets();
        } else {
          errorToast('Failed to delete preset');
        }
      }
    } catch (e) {
      errorToast('Error: $e');
    }
  }
  void viewPresetDetail(FramingPresetEntity preset) {
    Get.toNamed(
      '/kiddy_frame_preset_preview',
      arguments: {'preset': preset},
    );
  }
  Future<void> refresh() async {
    await loadPresets();
  }
}
