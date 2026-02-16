import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'kiddy_frame_student_detail_logic.dart';

class KiddyFrameStudentDetailPage
    extends GetView<KiddyFrameStudentDetailLogic> {
  const KiddyFrameStudentDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(controller.student.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStudentInfoCard(),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  'Works Timeline',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Obx(() {
                  if (controller.works.length >= 2) {
                    return GestureDetector(
                      onTap: controller.compareWorks,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CC9F0), Color(0xFF9C27B0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CC9F0).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.compare_arrows,
                              size: 16.w,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Compare',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                SizedBox(width: 8.w),
                Obx(
                  () => Text(
                    '${controller.workCount.value} works',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.works.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.works.length,
                  itemBuilder: (context, index) {
                    final work = controller.works[index];
                    return _buildWorkCard(work);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createWork,
        backgroundColor: const Color(0xFFFF4081),
        label: const Text('Create Work'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getColorFromName(controller.student.name),
            _getColorFromName(controller.student.name).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.w,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(
              _getInitials(controller.student.name),
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            controller.student.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.student.className != null) ...[
                Icon(Icons.school, size: 16.w, color: Colors.white),
                SizedBox(width: 4.w),
                Text(
                  controller.student.className!,
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ],
              if (controller.student.age != null) ...[
                if (controller.student.className != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Container(
                      width: 1,
                      height: 14.h,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                Text(
                  '${controller.student.age} years old',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ],
            ],
          ),
          if (controller.student.notes != null &&
              controller.student.notes!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Text(
                controller.student.notes!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 80.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No works yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap "Create Work" to start framing',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkCard(dynamic work) {
    return GestureDetector(
      onTap: () => controller.viewWork(work),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(work.filePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_outlined,
                      size: 32.w,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    _formatDate(work.createdAt),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromName(String name) {
    final colors = [
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF673AB7),
      const Color(0xFF3F51B5),
      const Color(0xFF2196F3),
      const Color(0xFF00BCD4),
      const Color(0xFF009688),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
    ];
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate.substring(0, 10);
    }
  }

  void _showDeleteDialog() async {
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Delete Student'),
        content: controller.workCount.value > 0
            ? Text(
                'Delete "${controller.student.name}"?\nThis student has ${controller.workCount.value} work(s).\n\nWhat do you want to do?',
              )
            : Text(
                'Delete "${controller.student.name}"?\nThis action cannot be undone.',
              ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          if (controller.workCount.value > 0) ...[
            TextButton(
              onPressed: () => Get.back(result: 'keep_works'),
              child: const Text('Delete student only'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Get.back(result: 'delete_all'),
              child: const Text('Delete student and works'),
            ),
          ] else
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Get.back(result: 'delete'),
              child: const Text('Delete'),
            ),
        ],
      ),
    );
    if (result == null) return;
    final deleteWorks = result == 'delete_all' || result == 'delete';
    controller.executeDeleteStudent(deleteWorks);
  }
}
