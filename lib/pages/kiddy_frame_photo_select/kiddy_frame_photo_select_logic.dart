import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/index.dart';
class PhotoAssetModel {
  final AssetEntity? asset;
  final String? filePath;
  final Uint8List? thumbnail;
  PhotoAssetModel({this.asset, this.filePath, this.thumbnail})
      : assert(
          asset != null || filePath != null,
          'Either asset or filePath must be provided',
        );
  bool get isCaptured => filePath != null;
  String get id => asset?.id ?? filePath!;
}
class KiddyFramePhotoSelectLogic extends GetxController {
  final String mode = Get.arguments?['mode'] ?? 'single';
  final String? studentId = Get.arguments?['studentId'];
  final photos = <PhotoAssetModel>[].obs;
  final capturedPhotos = <PhotoAssetModel>[].obs;
  final selectedPhotos = <dynamic>[].obs;
  final isLoading = false.obs;
  final maxPhotos = 1.obs;
  final minPhotos = 1.obs;
  @override
  void onInit() {
    super.onInit();
    if (mode == 'single') {
      maxPhotos.value = 1;
      minPhotos.value = 1;
    } else if (mode == 'batch') {
      maxPhotos.value = 20;
      minPhotos.value = 2;
    } else {
      errorToast('Invalid mode');
      return;
    }
    _requestPermissionAndLoadPhotos();
  }
  Future<void> _requestPermissionAndLoadPhotos() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (ps.isAuth || ps.hasAccess) {
        await _loadPhotos();
      } else {
        errorToast('Photos permission denied');
      }
    } catch (e) {
      errorToast('Failed to request permission: ${e.toString()}');
    }
  }
  Future<void> _loadPhotos() async {
    try {
      isLoading.value = true;
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );
      if (paths.isEmpty) {
        errorToast('No photos found');
        return;
      }
      await _loadRecentPhotos(paths[0]);
    } catch (e) {
      errorToast('Failed to load photos: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> _loadRecentPhotos(AssetPathEntity path) async {
    try {
      isLoading.value = true;
      final int count = await path.assetCountAsync;
      final List<AssetEntity> assets = await path.getAssetListRange(
        start: 0,
        end: count > 1000 ? 1000 : count,
      );
      photos.clear();
      for (final asset in assets) {
        final thumbnail = await asset.thumbnailDataWithSize(
          const ThumbnailSize(200, 200),
        );
        photos.add(PhotoAssetModel(asset: asset, thumbnail: thumbnail));
      }
    } catch (e) {
      errorToast('Failed to load photos: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  void togglePhoto(dynamic photoIdentifier) {
    if (isPhotoSelected(photoIdentifier)) {
      removePhoto(photoIdentifier);
    } else {
      if (mode == 'single') {
        selectedPhotos.clear();
        selectedPhotos.add(photoIdentifier);
      } else {
        if (selectedPhotos.length < maxPhotos.value) {
          selectedPhotos.add(photoIdentifier);
        } else {
          errorToast('Maximum ${maxPhotos.value} photos allowed');
        }
      }
    }
  }
  void removePhoto(dynamic photoIdentifier) {
    final String targetId = photoIdentifier is AssetEntity
        ? photoIdentifier.id
        : photoIdentifier as String;
    selectedPhotos.removeWhere((photo) {
      if (photo is AssetEntity) {
        return photo.id == targetId;
      } else if (photo is String) {
        return photo == targetId;
      }
      return false;
    });
  }
  void removePhotoAt(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }
  void clearAll() {
    if (selectedPhotos.isEmpty) {
      return;
    }
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All'),
        content: Text('Remove all ${selectedPhotos.length} selected photos?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final count = selectedPhotos.length;
              selectedPhotos.clear();
              Get.back();
              successToast('$count photos cleared');
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> openCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxWidth: 4000,
        maxHeight: 4000,
      );
      if (photo != null) {
        successToast('Photo captured');
        final filePath = photo.path;
        final file = File(filePath);
        final bytes = await file.readAsBytes();
        final newPhotoModel = PhotoAssetModel(
          filePath: filePath,
          thumbnail: bytes,
        );
        capturedPhotos.insert(0, newPhotoModel);
        if (selectedPhotos.length < maxPhotos.value) {
          selectedPhotos.add(filePath);
          successToast('Photo added to selection');
        } else {
          errorToast(
            'Maximum ${maxPhotos.value} photos reached, photo not selected',
          );
        }
      }
    } catch (e) {
      errorToast('Failed to open camera: ${e.toString()}');
    }
  }
  Future<void> refreshPhotos() async {
    try {
      await _loadPhotos();
      successToast('Photos refreshed');
    } catch (e) {
      errorToast('Failed to refresh: ${e.toString()}');
    }
  }
  bool isPhotoSelected(dynamic photoIdentifier) {
    if (photoIdentifier is AssetEntity) {
      return selectedPhotos.any(
        (p) => p is AssetEntity && p.id == photoIdentifier.id,
      );
    } else if (photoIdentifier is String) {
      return selectedPhotos.contains(photoIdentifier);
    }
    return false;
  }
  int getPhotoIndex(dynamic photoIdentifier) {
    if (photoIdentifier is AssetEntity) {
      return selectedPhotos.indexWhere(
        (p) => p is AssetEntity && p.id == photoIdentifier.id,
      );
    } else if (photoIdentifier is String) {
      return selectedPhotos.indexOf(photoIdentifier);
    }
    return -1;
  }
  void onNextTap() {
    if (selectedPhotos.isEmpty) {
      errorToast(
        'Please select at least ${minPhotos.value} photo${minPhotos.value > 1 ? 's' : ''}',
      );
      return;
    }
    if (selectedPhotos.length < minPhotos.value) {
      errorToast(
        'Please select at least ${minPhotos.value} photo${minPhotos.value > 1 ? 's' : ''}',
      );
      return;
    }
    try {
      if (mode == 'batch') {
        _navigateToEditDirectly();
      } else {
        Get.toNamed(
          '/kiddy_frame_photo_preprocess',
          arguments: {
            'photos': selectedPhotos,
            'mode': mode,
            'studentId': studentId,
          },
        );
      }
    } catch (e) {
      errorToast('Failed to proceed: ${e.toString()}');
    }
  }
  Future<void> _navigateToEditDirectly() async {
    try {
      final List<String> photoPaths = [];
      for (final photo in selectedPhotos) {
        if (photo is String) {
          photoPaths.add(photo);
        } else if (photo is AssetEntity) {
          final file = await photo.file;
          if (file != null) {
            photoPaths.add(file.path);
          }
        }
      }
      if (photoPaths.isEmpty) {
        errorToast('Failed to load photos');
        return;
      }
      Get.toNamed(
        '/kiddy_frame_photo_edit',
        arguments: {
          'photos': photoPaths,
          'cropBoxWidth': 280.0,
          'cropBoxHeight': 400.0,
          'studentId': studentId,
        },
      );
    } catch (e) {
      errorToast('Failed to navigate: ${e.toString()}');
    }
  }
}
