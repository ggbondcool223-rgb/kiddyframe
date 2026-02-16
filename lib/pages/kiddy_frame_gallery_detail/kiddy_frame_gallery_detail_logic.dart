import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../utils/index.dart';
import '../../db_kiddy_frame/db_kiddy_frame_entity.dart';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
class KiddyFrameGalleryDetailLogic extends GetxController {
  late final WorkEntity work;
  final isDeleting = false.obs;
  final isSaving = false.obs;
  @override
  void onInit() {
    super.onInit();
    work = Get.arguments['work'] as WorkEntity;
  }
  Future<void> onShareTap() async {
    try {
      final file = File(work.filePath);
      if (!await file.exists()) {
        errorToast('File not found');
        return;
      }
      await Share.shareXFiles(
        [XFile(work.filePath)],
        text: 'Check out my artwork created with KiddyFrame!',
      );
    } catch (e) {
      errorToast('Failed to share: ${e.toString()}');
    }
  }
  Future<void> onEditTap() async {
    try {
      final photoPath = work.originalPhotoPath ?? work.filePath;
      Get.toNamed(
        '/kiddy_frame_photo_edit',
        arguments: {
          'photos': [photoPath],
          'cropBoxWidth': 280.0,
          'cropBoxHeight': 400.0,
        },
      );
    } catch (e) {
      errorToast('Failed to open editor: ${e.toString()}');
    }
  }
  Future<void> onDeleteTap() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Delete Work'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this work?'),
              SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      isDeleting.value = true;
      final dbService = Get.find<KiddyFrameDatabaseService>();
      await dbService.database.deleteWork(work.id!);
      try {
        final file = File(work.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Failed to delete file: ${e.toString()}');
      }
      isDeleting.value = false;
      successToast('Work deleted successfully');
      Get.back(result: true);
    } catch (e) {
      isDeleting.value = false;
      errorToast('Failed to delete: ${e.toString()}');
    }
  }
  Future<void> onSaveToAlbumTap() async {
    try {
      isSaving.value = true;
      final file = File(work.filePath);
      if (!await file.exists()) {
        errorToast('File not found');
        isSaving.value = false;
        return;
      }
      final bytes = await file.readAsBytes();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        quality: 100,
        name: 'KiddyFrame_${DateTime.now().millisecondsSinceEpoch}',
      );
      isSaving.value = false;
      if (result['isSuccess'] == true) {
        successToast('Saved to album successfully');
      } else {
        errorToast('Failed to save to album');
      }
    } catch (e) {
      isSaving.value = false;
      errorToast('Failed to save: ${e.toString()}');
    }
  }
  String getFormattedFileSize() {
    final sizeInBytes = work.fileSize;
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
