import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'kiddy_frame_home_logic.dart';
class KiddyFrameHomeView extends GetView<KiddyFrameHomeLogic> {
  const KiddyFrameHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF8F0).withOpacity(0.95),
                    const Color(0xFFFFE4D6).withOpacity(0.85),
                    const Color(0xFFFFF8F0).withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFunctionButtons(),
                  SizedBox(height: 8.h),
                  _buildGallerySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      title: Text(
        'Start Framing',
        style: TextStyle(
          fontSize: 26.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF333333),
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.settings_outlined, size: 24.w),
            color: const Color(0xFF333333),
            onPressed: controller.onSettings,
          ),
        ),
      ],
    );
  }
  Widget _buildFunctionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ).copyWith(top: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFunctionCard(
            iconPath: 'assets/icons/photo.png',
            label: 'Frame Photo',
            color: const Color(0xFFE3F2FD),
            onTap: controller.onFramePhoto,
          ),
          _buildFunctionCard(
            iconPath: 'assets/icons/batch.png',
            label: 'Batch Frame',
            color: const Color(0xFFF3E5F5),
            onTap: controller.onBatchFrame,
          ),
          _buildFunctionCard(
            iconPath: 'assets/icons/camera.png',
            label: 'Take Photo',
            color: const Color(0xFFE1F5FE),
            onTap: controller.onTakePhoto,
          ),
        ],
      ),
    );
  }
  Widget _buildFunctionCard({
    required String iconPath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                iconPath,
                width: 40.w,
                height: 40.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildGallerySection() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.w),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF333333),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Obx(
                          () => Text(
                            '${controller.works.length} works',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF999999),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.works.length >= 2) {
                        return GestureDetector(
                          onTap: controller.onCompareWorks,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF4CC9F0),
                                  Color(0xFF9C27B0),
                                ],
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
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: const Color(0xFFEEEEEE),
                ),
                Obx(() {
                  if (controller.isLoadingWorks.value) {
                    return _buildLoadingGallery();
                  } else if (controller.works.isEmpty) {
                    return _buildEmptyGallery();
                  } else {
                    return _buildWorksList();
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildLoadingGallery() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CC9F0)),
        ),
      ),
    );
  }
  Widget _buildEmptyGallery() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/bg.png',
            width: double.infinity,
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.8),
          ),
          Text(
            'No saved works yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF666666),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start by framing a photo!',
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
  Widget _buildWorksList() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 0.75,
        ),
        itemCount: controller.works.length,
        itemBuilder: (context, index) {
          return _buildWorkCard(controller.works[index]);
        },
      ),
    );
  }
  Widget _buildWorkCard(work) {
    return GestureDetector(
      onTap: () => controller.onViewWorkDetail(work),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'work_${work.id}',
                child: Image.file(
                  File(work.filePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        size: 40.w,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      work.createdAt,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
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
}
