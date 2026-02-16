import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/index.dart';
import 'kiddy_frame_gallery_detail_logic.dart';
class KiddyFrameGalleryDetailView
    extends GetView<KiddyFrameGalleryDetailLogic> {
  const KiddyFrameGalleryDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildImageArea()),
              _buildInfoAndActions(),
            ],
          ),
          Obx(() {
            if (controller.isDeleting.value || controller.isSaving.value) {
              return Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16.h),
                      Text(
                        controller.isDeleting.value
                            ? 'Deleting...'
                            : 'Saving...',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.w),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Work Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  Widget _buildImageArea() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Hero(
          tag: 'work_${controller.work.id}',
          child: Container(
            constraints: BoxConstraints(maxWidth: 375.w, maxHeight: 600.h),
            child: Image.file(
              File(controller.work.filePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 320.w,
                  height: 480.h,
                  decoration: BoxDecoration(color: Colors.grey[800]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 80.w,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Image not found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildInfoAndActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.w),
          topRight: Radius.circular(20.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfo(),
          Divider(height: 1, color: Colors.grey[200]),
          _buildActionButtons(),
        ],
      ),
    );
  }
  Widget _buildInfo() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16.w,
                color: const Color(0xFF999999),
              ),
              SizedBox(width: 8.w),
              Text(
                'Created on ${getDateString(DateTime.parse(controller.work.createdAt))}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                size: 16.w,
                color: const Color(0xFF999999),
              ),
              SizedBox(width: 8.w),
              Text(
                'Size: ${controller.getFormattedFileSize()}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.save_alt_outlined,
            label: 'Save',
            onTap: controller.onSaveToAlbumTap,
          ),
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Colors.red,
            onTap: controller.onDeleteTap,
          ),
        ],
      ),
    );
  }
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28.w, color: color ?? const Color(0xFF333333)),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color ?? const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
