import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'kiddy_frame_settings_logic.dart';
class KiddyFrameSettingsView extends GetView<KiddyFrameSettingsLogic> {
  const KiddyFrameSettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        children: [
          _buildFeaturesCard(),
          SizedBox(height: 16.h),
          _buildInfoCard(),
          SizedBox(height: 16.h),
          _buildDangerZoneCard(),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20.w,
          color: const Color(0xFF333333),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Settings',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF333333),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey[200]),
      ),
    );
  }
  Widget _buildFeaturesCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            Icons.palette_outlined,
            'Framing Presets',
            'Manage your saved presets',
            () => Get.toNamed('/kiddy_frame_preset_management'),
          ),
          SizedBox(height: 12.h),
          _buildFeatureItem(
            Icons.people_outline,
            'Student Management',
            'Manage students and their works',
            () => Get.toNamed('/kiddy_frame_student_management'),
          ),
        ],
      ),
    );
  }
  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.w),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4081).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Icon(icon, size: 24.w, color: const Color(0xFFFF4081)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: const Color(0xFF999999),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Information',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.info_outline, 'Version', 'v1.0.0'),
          SizedBox(height: 12.h),
          _buildInfoRow(Icons.apps, 'App Name', 'KiddyFrame'),
        ],
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: const Color(0xFF999999)),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF666666)),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
      ],
    );
  }
  Widget _buildDangerZoneCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 16.h),
          _buildDangerButton(),
        ],
      ),
    );
  }
  Widget _buildDangerButton() {
    return Obx(() {
      return InkWell(
        onTap: controller.isClearingData.value
            ? null
            : controller.onClearAllData,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.delete_forever, size: 24.w, color: Colors.red),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clear All Data',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Delete all works and frames data',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isClearingData.value)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
              else
                Icon(Icons.arrow_forward_ios, size: 16.w, color: Colors.red),
            ],
          ),
        ),
      );
    });
  }
}
