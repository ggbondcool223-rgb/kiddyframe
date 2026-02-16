import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'kiddy_frame_photo_select_logic.dart';
class KiddyFramePhotoSelectView extends GetView<KiddyFramePhotoSelectLogic> {
  const KiddyFramePhotoSelectView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildPhotoGrid()),
          _buildBottomPreview(),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, size: 20.w),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Recent Photos',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
  Widget _buildPhotoGrid() {
    return Obx(() {
      if (controller.isLoading.value && controller.photos.isEmpty) {
        return _buildLoadingIndicator();
      }
      return RefreshIndicator(
        onRefresh: controller.refreshPhotos,
        color: const Color(0xFFFF9A8B),
        child: GridView.builder(
          padding: EdgeInsets.all(2.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 2.w,
          ),
          itemCount:
              1 + controller.capturedPhotos.length + controller.photos.length,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildCameraButton();
            }
            final capturedCount = controller.capturedPhotos.length;
            if (index <= capturedCount) {
              final photoModel = controller.capturedPhotos[index - 1];
              return _buildPhotoCard(photoModel, isCaptured: true);
            }
            final photoModel = controller.photos[index - capturedCount - 1];
            return _buildPhotoCard(photoModel, isCaptured: false);
          },
        ),
      );
    });
  }
  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9A8B)),
      ),
    );
  }
  Widget _buildCameraButton() {
    return GestureDetector(
      onTap: controller.openCamera,
      child: Container(
        decoration: BoxDecoration(color: Colors.black54),
        child: Icon(Icons.camera_alt_outlined, size: 40.w, color: Colors.white),
      ),
    );
  }
  Widget _buildPhotoCard(
    PhotoAssetModel photoModel, {
    bool isCaptured = false,
  }) {
    return Obx(() {
      final photoIdentifier = photoModel.asset ?? photoModel.filePath!;
      final isSelected = controller.isPhotoSelected(photoIdentifier);
      final photoIndex = controller.getPhotoIndex(photoIdentifier);
      return GestureDetector(
        onTap: () => controller.togglePhoto(photoIdentifier),
        child: Stack(
          children: [
            if (photoModel.thumbnail != null)
              Container(
                color: Colors.grey[300],
                child: Image.memory(
                  photoModel.thumbnail!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(Icons.image, size: 40.w, color: Colors.grey[400]),
                ),
              ),
            if (isCaptured)
              Positioned(
                top: 4.w,
                left: 4.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9A8B),
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            if (isSelected)
              Container(color: Colors.black.withValues(alpha: 0.3)),
            if (isSelected)
              Positioned(
                top: 8.w,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => controller.removePhoto(photoIdentifier),
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9A8B),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16.w, color: Colors.white),
                  ),
                ),
              ),
            if (isSelected && photoIndex >= 0)
              Positioned(
                bottom: 8.w,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9A8B), Color(0xFFFF6B95)],
                    ),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Text(
                    '${photoIndex + 1}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
  Widget _buildBottomPreview() {
    return Obx(() {
      if (controller.selectedPhotos.isEmpty) {
        return const SizedBox.shrink();
      }
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.w),
            topRight: Radius.circular(20.w),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 24.w),
                  onPressed: controller.clearAll,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Photos',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF999999),
                        ),
                      ),
                      Text(
                        '${controller.selectedPhotos.length} / ${controller.maxPhotos.value}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_rounded,
                    size: 28.w,
                    color: const Color(0xFF4CC9F0),
                  ),
                  onPressed: controller.onNextTap,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 68.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.selectedPhotos.length,
                itemBuilder: (context, index) {
                  return _buildSelectedPhotoCard(index);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
  Widget _buildSelectedPhotoCard(int index) {
    final photoItem = controller.selectedPhotos[index];
    Widget buildCard(Uint8List? imageData) {
      return Container(
        width: 60.w,
        margin: EdgeInsets.only(right: 8.w),
        child: Stack(
          children: [
            if (imageData != null)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Image.memory(
                    imageData,
                    width: 60.w,
                    height: 68.h,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Center(
                  child: Icon(Icons.image, size: 30.w, color: Colors.grey[400]),
                ),
              ),
            Positioned(
              bottom: 4.w,
              left: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9A8B), Color(0xFFFF6B95)],
                  ),
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4.w,
              right: 4.w,
              child: GestureDetector(
                onTap: () => controller.removePhotoAt(index),
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 12.w, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (photoItem is AssetEntity) {
      return FutureBuilder<Uint8List?>(
        future: photoItem.thumbnailDataWithSize(const ThumbnailSize(150, 150)),
        builder: (context, snapshot) {
          return buildCard(snapshot.data);
        },
      );
    } else if (photoItem is String) {
      return FutureBuilder<Uint8List?>(
        future: File(photoItem).readAsBytes(),
        builder: (context, snapshot) {
          return buildCard(snapshot.data);
        },
      );
    }
    return buildCard(null);
  }
}
