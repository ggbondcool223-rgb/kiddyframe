import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../utils/index.dart';
import '../../utils/image_processor.dart';
class KiddyFramePhotoPreprocessLogic extends GetxController {
  final List<dynamic> photos = Get.arguments?['photos'] ?? [];
  late final RxString mode;
  final String? studentId = Get.arguments?['studentId'];
  final currentPhotoIndex = 0.obs;
  final currentPhotoFile = Rx<File?>(null);
  final processedPhotos = <File>[].obs;
  final currentTab = 0.obs;
  final imageWidth = 0.obs;
  final imageHeight = 0.obs;
  late TransformationController transformationController;
  final cropBoxLeft = 0.0.obs;
  final cropBoxTop = 0.0.obs;
  final cropBoxWidth = 0.0.obs;
  final cropBoxHeight = 0.0.obs;
  final containerWidth = 0.0.obs;
  final containerHeight = 0.0.obs;
  final imageDisplayLeft = 0.0.obs;
  final imageDisplayTop = 0.0.obs;
  final imageDisplayWidth = 0.0.obs;
  final imageDisplayHeight = 0.0.obs;
  final rotation = 0.obs;
  final isFlippedH = false.obs;
  final isFlippedV = false.obs;
  final isLoading = false.obs;
  final isProcessing = false.obs;
  Offset? _lastFocalPoint;
  String? _draggingCorner;
  Offset? _dragStartPoint;
  double? _dragStartWidth;
  double? _dragStartHeight;
  double? _dragStartLeft;
  double? _dragStartTop;
  @override
  void onInit() {
    super.onInit();
    transformationController = TransformationController();
    final modeValue = Get.arguments?['mode'] as String? ?? 'single';
    mode = modeValue.obs;
    if (photos.isEmpty) {
      errorToast('No photos to process');
      Get.back();
      return;
    }
    _loadCurrentPhoto();
  }
  Future<void> _loadCurrentPhoto() async {
    try {
      isLoading.value = true;
      final photoItem = photos[currentPhotoIndex.value];
      if (photoItem is AssetEntity) {
        final file = await photoItem.file;
        if (file != null) {
          currentPhotoFile.value = file;
          await _getImageInfo(file);
        } else {
          errorToast('Failed to load photo file');
        }
      } else if (photoItem is String) {
        final file = File(photoItem);
        currentPhotoFile.value = file;
        await _getImageInfo(file);
      } else {
        errorToast('Invalid photo type');
      }
    } catch (e) {
      errorToast('Failed to load photo: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> _getImageInfo(File file) async {
    try {
      final info = await ImageProcessor.getImageInfo(file);
      if (info != null) {
        imageWidth.value = info['width'];
        imageHeight.value = info['height'];
      }
    } catch (e) {
      print('Error getting image info: $e');
    }
  }
  void updateContainerSize(double width, double height) {
    if (containerWidth.value != width || containerHeight.value != height) {
      containerWidth.value = width;
      containerHeight.value = height;
    }
  }
  void updateImageDisplayRect(Rect displayRect) {
    if (imageWidth.value == 0 || imageHeight.value == 0) return;
    final containerW = displayRect.width;
    final containerH = displayRect.height;
    final imageAspect = imageWidth.value / imageHeight.value;
    final containerAspect = containerW / containerH;
    double actualImageWidth;
    double actualImageHeight;
    double offsetX;
    double offsetY;
    if (imageAspect > containerAspect) {
      actualImageWidth = containerW;
      actualImageHeight = containerW / imageAspect;
      offsetX = 0;
      offsetY = (containerH - actualImageHeight) / 2;
    } else {
      actualImageHeight = containerH;
      actualImageWidth = containerH * imageAspect;
      offsetX = (containerW - actualImageWidth) / 2;
      offsetY = 0;
    }
    imageDisplayLeft.value = offsetX;
    imageDisplayTop.value = offsetY;
    imageDisplayWidth.value = actualImageWidth;
    imageDisplayHeight.value = actualImageHeight;
    if (cropBoxWidth.value == 0 && imageDisplayWidth.value > 0) {
      initializeCropBox(containerW, containerH);
    }
  }
  void initializeCropBox(double containerW, double containerH) {
    if (containerW == 0 || containerH == 0 || imageDisplayWidth.value == 0)
      return;
    final maxWidth = imageDisplayWidth.value * 0.9;
    final maxHeight = imageDisplayHeight.value * 0.9;
    final initialSize = maxWidth < maxHeight ? maxWidth : maxHeight;
    cropBoxWidth.value = initialSize;
    cropBoxHeight.value = initialSize;
    cropBoxLeft.value =
        imageDisplayLeft.value +
        (imageDisplayWidth.value - cropBoxWidth.value) / 2;
    cropBoxTop.value =
        imageDisplayTop.value +
        (imageDisplayHeight.value - cropBoxHeight.value) / 2;
    _constrainCropBoxToBounds();
  }
  void selectTab(int index) {
    currentTab.value = index;
  }
  void onCropBoxPanStart(DragStartDetails details) {
    _lastFocalPoint = details.globalPosition;
  }
  void onCropBoxPanUpdate(DragUpdateDetails details) {
    if (_lastFocalPoint != null) {
      final delta = details.globalPosition - _lastFocalPoint!;
      cropBoxLeft.value += delta.dx;
      cropBoxTop.value += delta.dy;
      _constrainCropBoxToBounds();
      _lastFocalPoint = details.globalPosition;
    }
  }
  void onCornerDragStart(String corner, DragStartDetails details) {
    _draggingCorner = corner;
    _dragStartPoint = details.globalPosition;
    _dragStartWidth = cropBoxWidth.value;
    _dragStartHeight = cropBoxHeight.value;
    _dragStartLeft = cropBoxLeft.value;
    _dragStartTop = cropBoxTop.value;
  }
  void onCornerDragUpdate(DragUpdateDetails details) {
    if (_draggingCorner == null || _dragStartPoint == null) return;
    final delta = details.globalPosition - _dragStartPoint!;
    double newWidth = _dragStartWidth!;
    double newHeight = _dragStartHeight!;
    double newLeft = _dragStartLeft!;
    double newTop = _dragStartTop!;
    switch (_draggingCorner) {
      case 'tl':
        newWidth = _dragStartWidth! - delta.dx;
        newHeight = _dragStartHeight! - delta.dy;
        newLeft = _dragStartLeft! + delta.dx;
        newTop = _dragStartTop! + delta.dy;
        break;
      case 'tr':
        newWidth = _dragStartWidth! + delta.dx;
        newHeight = _dragStartHeight! - delta.dy;
        newTop = _dragStartTop! + delta.dy;
        break;
      case 'bl':
        newWidth = _dragStartWidth! - delta.dx;
        newHeight = _dragStartHeight! + delta.dy;
        newLeft = _dragStartLeft! + delta.dx;
        break;
      case 'br':
        newWidth = _dragStartWidth! + delta.dx;
        newHeight = _dragStartHeight! + delta.dy;
        break;
    }
    if (newWidth < 50 || newHeight < 50) return;
    final minLeft = imageDisplayLeft.value;
    final minTop = imageDisplayTop.value;
    final maxRight = imageDisplayLeft.value + imageDisplayWidth.value;
    final maxBottom = imageDisplayTop.value + imageDisplayHeight.value;
    if (newLeft < minLeft ||
        newTop < minTop ||
        newLeft + newWidth > maxRight ||
        newTop + newHeight > maxBottom) {
      return;
    }
    cropBoxWidth.value = newWidth;
    cropBoxHeight.value = newHeight;
    cropBoxLeft.value = newLeft;
    cropBoxTop.value = newTop;
  }
  void onCornerDragEnd(DragEndDetails details) {
    _draggingCorner = null;
    _dragStartPoint = null;
  }
  void _constrainCropBoxToBounds() {
    if (imageDisplayWidth.value == 0 || imageDisplayHeight.value == 0) return;
    final minLeft = imageDisplayLeft.value;
    final minTop = imageDisplayTop.value;
    final maxLeft =
        imageDisplayLeft.value + imageDisplayWidth.value - cropBoxWidth.value;
    final maxTop =
        imageDisplayTop.value + imageDisplayHeight.value - cropBoxHeight.value;
    final validMaxLeft = maxLeft < minLeft ? minLeft : maxLeft;
    final validMaxTop = maxTop < minTop ? minTop : maxTop;
    cropBoxLeft.value = cropBoxLeft.value.clamp(minLeft, validMaxLeft);
    cropBoxTop.value = cropBoxTop.value.clamp(minTop, validMaxTop);
  }
  Rect convertScreenToImageCoordinates() {
    final scaleX = imageWidth.value / imageDisplayWidth.value;
    final scaleY = imageHeight.value / imageDisplayHeight.value;
    final relativeLeft = cropBoxLeft.value - imageDisplayLeft.value;
    final relativeTop = cropBoxTop.value - imageDisplayTop.value;
    final pixelX = (relativeLeft * scaleX).clamp(
      0.0,
      imageWidth.value.toDouble(),
    );
    final pixelY = (relativeTop * scaleY).clamp(
      0.0,
      imageHeight.value.toDouble(),
    );
    final pixelWidth = (cropBoxWidth.value * scaleX).clamp(
      1.0,
      imageWidth.value.toDouble() - pixelX,
    );
    final pixelHeight = (cropBoxHeight.value * scaleY).clamp(
      1.0,
      imageHeight.value.toDouble() - pixelY,
    );
    return Rect.fromLTWH(pixelX, pixelY, pixelWidth, pixelHeight);
  }
  Future<void> onCropTap() async {
    if (currentPhotoFile.value == null || isProcessing.value) return;
    try {
      isProcessing.value = true;
      final cropRect = convertScreenToImageCoordinates();
      final x = cropRect.left.round();
      final y = cropRect.top.round();
      final width = cropRect.width.round();
      final height = cropRect.height.round();
      if (width < 10 || height < 10) {
        errorToast('Crop area is too small');
        return;
      }
      final cropped = await ImageProcessor.cropImage(
        imageFile: currentPhotoFile.value!,
        x: x,
        y: y,
        width: width,
        height: height,
        quality: 90,
      );
      if (cropped != null) {
        currentPhotoFile.value = cropped;
        await _getImageInfo(cropped);
        transformationController.value = Matrix4.identity();
        await Future.delayed(const Duration(milliseconds: 100));
        if (imageDisplayWidth.value > 0) {
          initializeCropBox(containerWidth.value, containerHeight.value);
        }
        successToast('Image cropped successfully!');
      } else {
        errorToast('Failed to crop');
      }
    } catch (e) {
      errorToast('Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }
  Future<void> rotateLeft() async {
    if (currentPhotoFile.value == null || isProcessing.value) return;
    try {
      isProcessing.value = true;
      final rotated = await ImageProcessor.rotateImage(
        imageFile: currentPhotoFile.value!,
        angle: -90,
      );
      if (rotated != null) {
        currentPhotoFile.value = rotated;
        await _getImageInfo(rotated);
        rotation.value = (rotation.value - 90) % 360;
        final temp = imageWidth.value;
        imageWidth.value = imageHeight.value;
        imageHeight.value = temp;
        successToast('Rotated left');
      } else {
        errorToast('Failed to rotate');
      }
    } catch (e) {
      errorToast('Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }
  Future<void> rotateRight() async {
    if (currentPhotoFile.value == null || isProcessing.value) return;
    try {
      isProcessing.value = true;
      final rotated = await ImageProcessor.rotateImage(
        imageFile: currentPhotoFile.value!,
        angle: 90,
      );
      if (rotated != null) {
        currentPhotoFile.value = rotated;
        await _getImageInfo(rotated);
        rotation.value = (rotation.value + 90) % 360;
        final temp = imageWidth.value;
        imageWidth.value = imageHeight.value;
        imageHeight.value = temp;
        successToast('Rotated right');
      } else {
        errorToast('Failed to rotate');
      }
    } catch (e) {
      errorToast('Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }
  Future<void> flipHorizontal() async {
    if (currentPhotoFile.value == null || isProcessing.value) return;
    try {
      isProcessing.value = true;
      final flipped = await ImageProcessor.flipImage(
        imageFile: currentPhotoFile.value!,
        horizontal: true,
      );
      if (flipped != null) {
        currentPhotoFile.value = flipped;
        isFlippedH.value = !isFlippedH.value;
        successToast('Flipped horizontally');
      } else {
        errorToast('Failed to flip');
      }
    } catch (e) {
      errorToast('Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }
  Future<void> flipVertical() async {
    if (currentPhotoFile.value == null || isProcessing.value) return;
    try {
      isProcessing.value = true;
      final flipped = await ImageProcessor.flipImage(
        imageFile: currentPhotoFile.value!,
        horizontal: false,
        vertical: true,
      );
      if (flipped != null) {
        currentPhotoFile.value = flipped;
        isFlippedV.value = !isFlippedV.value;
        successToast('Flipped vertically');
      } else {
        errorToast('Failed to flip');
      }
    } catch (e) {
      errorToast('Error: ${e.toString()}');
    } finally {
      isProcessing.value = false;
    }
  }
  Future<void> resetCurrentPhoto() async {
    if (isProcessing.value) return;
    try {
      isProcessing.value = true;
      await _loadCurrentPhoto();
      rotation.value = 0;
      isFlippedH.value = false;
      isFlippedV.value = false;
      transformationController.value = Matrix4.identity();
      successToast('Reset to original');
    } catch (e) {
      errorToast('Failed to reset');
    } finally {
      isProcessing.value = false;
    }
  }
  Future<void> onConfirmTap() async {
    if (isProcessing.value || currentPhotoFile.value == null) return;
    try {
      isProcessing.value = true;
      if (currentTab.value == 0) {
        await _applyCropBeforeConfirm();
      }
      if (currentPhotoFile.value != null) {
        if (!processedPhotos.contains(currentPhotoFile.value!)) {
          processedPhotos.add(currentPhotoFile.value!);
        }
      }
      _navigateToEdit();
    } catch (e) {
      errorToast('Failed to process photo: ${e.toString()}');
      isProcessing.value = false;
    }
  }
  Future<void> _applyCropBeforeConfirm() async {
    if (currentPhotoFile.value == null) return;
    try {
      final cropRect = convertScreenToImageCoordinates();
      final x = cropRect.left.round();
      final y = cropRect.top.round();
      final width = cropRect.width.round();
      final height = cropRect.height.round();
      if (width < 10 || height < 10) {
        return;
      }
      final cropped = await ImageProcessor.cropImage(
        imageFile: currentPhotoFile.value!,
        x: x,
        y: y,
        width: width,
        height: height,
        quality: 90,
      );
      if (cropped != null) {
        currentPhotoFile.value = cropped;
        await _getImageInfo(cropped);
      }
    } catch (e) {
      print('Error applying crop: $e');
    }
  }
  void onCancelTap() {
    Get.back();
  }
  void _navigateToEdit() {
    if (processedPhotos.isEmpty && currentPhotoFile.value != null) {
      processedPhotos.add(currentPhotoFile.value!);
    }
    if (processedPhotos.isEmpty) {
      errorToast('No photos to edit');
      return;
    }
    final photoPaths = processedPhotos.map((f) => f.path).toList();
    final cropWidth = cropBoxWidth.value > 0 ? cropBoxWidth.value : 280.0;
    final cropHeight = cropBoxHeight.value > 0 ? cropBoxHeight.value : 400.0;
    Get.offNamed(
      '/kiddy_frame_photo_edit',
      arguments: {
        'photos': photoPaths,
        'cropBoxWidth': cropWidth,
        'cropBoxHeight': cropHeight,
        'studentId': studentId,
      },
    );
  }
  @override
  void onClose() {
    transformationController.dispose();
    super.onClose();
  }
}
