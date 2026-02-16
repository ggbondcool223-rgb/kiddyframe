import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/index.dart';
import '../../db_kiddy_frame/db_kiddy_frame_entity.dart';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
class KiddyFrameHomeLogic extends GetxController {
  final works = <WorkEntity>[].obs;
  final isLoadingWorks = false.obs;
  @override
  void onInit() {
    super.onInit();
    loadWorks();
  }
  @override
  void onReady() {
    super.onReady();
    loadWorks();
  }
  Future<void> loadWorks() async {
    try {
      isLoadingWorks.value = true;
      final dbService = Get.find<KiddyFrameDatabaseService>();
      final workList = await dbService.database.getWorks();
      works.value = workList;
    } catch (e) {
      errorToast('Failed to load works: ${e.toString()}');
    } finally {
      isLoadingWorks.value = false;
    }
  }
  Future<void> onTakePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxWidth: 4000,
        maxHeight: 4000,
      );
      if (photo != null) {
        successToast('Photo captured successfully');
        await Get.toNamed(
          '/kiddy_frame_photo_edit',
          arguments: {
            'photos': [photo.path],
            'cropBoxWidth': 280.0,
            'cropBoxHeight': 400.0,
          },
        );
        await loadWorks();
      }
    } catch (e) {
      errorToast('Failed to take photo: ${e.toString()}');
    }
  }
  Future<void> onFramePhoto() async {
    try {
      await Get.toNamed(
        '/kiddy_frame_photo_select',
        arguments: {'mode': 'single'},
      );
      await loadWorks();
    } catch (e) {
      errorToast('Failed to open frame photo: ${e.toString()}');
    }
  }
  Future<void> onBatchFrame() async {
    try {
      await Get.toNamed(
        '/kiddy_frame_photo_select',
        arguments: {'mode': 'batch'},
      );
      await loadWorks();
    } catch (e) {
      errorToast('Failed to open batch frame: ${e.toString()}');
    }
  }
  Future<void> onSettings() async {
    try {
      await Get.toNamed('/kiddy_frame_settings');
      await loadWorks();
    } catch (e) {
      errorToast('Failed to open settings: ${e.toString()}');
    }
  }
  Future<void> onViewWorkDetail(WorkEntity work) async {
    try {
      final result = await Get.toNamed(
        '/kiddy_frame_gallery_detail',
        arguments: {'work': work},
      );
      if (result == true) {
        await loadWorks();
      }
    } catch (e) {
      errorToast('Failed to open work detail: ${e.toString()}');
    }
  }
  Future<void> onDeleteWork(WorkEntity work) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Work'),
          content: const Text('Are you sure you want to delete this work?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        final dbService = Get.find<KiddyFrameDatabaseService>();
        await dbService.database.deleteWork(work.id!);
        await loadWorks();
        successToast('Work deleted');
      }
    } catch (e) {
      errorToast('Failed to delete work: ${e.toString()}');
    }
  }
  Future<void> onCompareWorks() async {
    if (works.length < 2) {
      errorToast('Need at least 2 works for comparison');
      return;
    }
    try {
      final workPaths = works.map((work) => work.filePath).toList();
      await Get.toNamed(
        '/kiddy_frame_work_compare',
        arguments: {
          'workPaths': workPaths,
        },
      );
    } catch (e) {
      errorToast('Failed to open compare mode: ${e.toString()}');
    }
  }
}
