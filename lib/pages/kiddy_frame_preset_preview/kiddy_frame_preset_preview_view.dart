import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'kiddy_frame_preset_preview_logic.dart';
class KiddyFramePresetPreviewPage extends GetView<KiddyFramePresetPreviewLogic> {
  const KiddyFramePresetPreviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(controller.preset.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (controller.preset.isDefault == 0)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: controller.deletePreset,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewSection(),
            SizedBox(height: 24.h),
            _buildInfoSection(),
            SizedBox(height: 24.h),
            _buildConfigSection(),
            SizedBox(height: 100.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }
  Widget _buildPreviewSection() {
    return Container(
      width: double.infinity,
      height: 300.h,
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: controller.preset.thumbnailPath != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.file(
                File(controller.preset.thumbnailPath!),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              ),
            )
          : _buildPlaceholder(),
    );
  }
  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 64.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 8.h),
          Text(
            'No preview available',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.preset.name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          if (controller.preset.description != null && controller.preset.description!.isNotEmpty)
            Text(
              controller.preset.description!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildStatItem(
                Icons.access_time,
                'Created',
                _formatDate(controller.preset.createdAt),
              ),
              SizedBox(width: 24.w),
              _buildStatItem(
                Icons.history,
                'Used',
                '${controller.preset.usageCount} times',
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: Colors.grey[600]),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildConfigSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          _buildConfigItem('Frame', controller.getFrameName()),
          _buildConfigItem('Background', controller.getBackgroundType()),
          _buildConfigItem('Text Elements', '${controller.getTextCount()}'),
          _buildConfigItem('Stickers', '${controller.getStickerCount()}'),
        ],
      ),
    );
  }
  Widget _buildConfigItem(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBottomActions() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.applyToNewWork,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF4081),
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Apply to New Work',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}
