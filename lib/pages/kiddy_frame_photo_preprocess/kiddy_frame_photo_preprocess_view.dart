import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'kiddy_frame_photo_preprocess_logic.dart';
class KiddyFramePhotoPreprocessView
    extends GetView<KiddyFramePhotoPreprocessLogic> {
  const KiddyFramePhotoPreprocessView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(child: _buildPreviewArea()),
          _buildTabBar(),
          _buildToolsArea(),
        ],
      ),
    );
  }
  Widget _buildPreviewArea() {
    return Obx(() {
      if (controller.isLoading.value &&
          controller.currentPhotoFile.value == null) {
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (controller.currentPhotoFile.value == null) {
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: Icon(Icons.image, size: 80.w, color: Colors.grey[400]),
          ),
        );
      }
      if (controller.currentTab.value == 0) {
        return _buildCropArea();
      } else {
        return _buildRotatePreview();
      }
    });
  }
  Widget _buildCropArea() {
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.updateContainerSize(
              constraints.maxWidth,
              constraints.maxHeight,
            );
          });
          return Stack(
            children: [
              Center(child: _buildImageWithMeasurement(constraints)),
              if (controller.currentPhotoFile.value != null)
                _buildCropOverlay(),
              if (controller.isProcessing.value)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Processing...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  Widget _buildRotatePreview() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Obx(() {
          if (controller.isProcessing.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Processing...',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
              ],
            );
          }
          return Image.file(
            controller.currentPhotoFile.value!,
            fit: BoxFit.contain,
            key: ValueKey(controller.currentPhotoFile.value!.path),
          );
        }),
      ),
    );
  }
  Widget _buildImageWithMeasurement(BoxConstraints constraints) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateImageDisplayRect(
        Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight),
      );
    });
    return Image.file(
      controller.currentPhotoFile.value!,
      fit: BoxFit.contain,
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      key: ValueKey(controller.currentPhotoFile.value!.path),
    );
  }
  Widget _buildCropOverlay() {
    return Obx(() {
      if (controller.cropBoxWidth.value == 0 ||
          controller.cropBoxHeight.value == 0) {
        return const SizedBox.shrink();
      }
      final cropLeft = controller.cropBoxLeft.value;
      final cropTop = controller.cropBoxTop.value;
      final cropWidth = controller.cropBoxWidth.value;
      final cropHeight = controller.cropBoxHeight.value;
      return Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CropMaskPainter(
                  cropRect: Rect.fromLTWH(
                    cropLeft,
                    cropTop,
                    cropWidth,
                    cropHeight,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: cropLeft,
            top: cropTop,
            width: cropWidth,
            height: cropHeight,
            child: GestureDetector(
              onPanStart: controller.onCropBoxPanStart,
              onPanUpdate: controller.onCropBoxPanUpdate,
              behavior: HitTestBehavior.translucent,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4CC9F0), width: 2),
                ),
                child: Column(
                  children: List.generate(
                    3,
                    (i) => Expanded(
                      child: Row(
                        children: List.generate(
                          3,
                          (j) => Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(
                                    0xFF4CC9F0,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildCornerHandle('tl', cropLeft, cropTop),
          _buildCornerHandle('tr', cropLeft + cropWidth, cropTop),
          _buildCornerHandle('bl', cropLeft, cropTop + cropHeight),
          _buildCornerHandle(
            'br',
            cropLeft + cropWidth,
            cropTop + cropHeight,
          ),
        ],
      );
    });
  }
  Widget _buildCornerHandle(String corner, double left, double top) {
    final size = 24.w;
    final offset = size / 2;
    return Positioned(
      left: left - offset,
      top: top - offset,
      child: GestureDetector(
        onPanStart: (details) => controller.onCornerDragStart(corner, details),
        onPanUpdate: controller.onCornerDragUpdate,
        onPanEnd: controller.onCornerDragEnd,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFF4CC9F0),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildTabBar() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.onCancelTap,
            icon: Icon(Icons.close, size: 24.w, color: const Color(0xFF333333)),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
          ),
          _buildTab('Crop', 0),
          _buildTab('Rotate', 1),
          Obx(
            () => IconButton(
              onPressed: controller.isProcessing.value
                  ? null
                  : controller.onConfirmTap,
              icon: Icon(
                Icons.check,
                size: 24.w,
                color: controller.isProcessing.value
                    ? const Color(0xFF999999)
                    : const Color(0xFF4CC9F0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTab(String label, int index) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.currentTab.value == index;
        return GestureDetector(
          onTap: () => controller.selectTab(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected
                      ? const Color(0xFF4CC9F0)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF333333)
                      : const Color(0xFF999999),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
  Widget _buildToolsArea() {
    return Container(
      height: 120.h,
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Obx(() {
        if (controller.currentTab.value == 0) {
          return _buildCropTools();
        } else {
          return _buildRotateTools();
        }
      }),
    );
  }
  Widget _buildCropTools() {
    return Center(
      child: Text(
        'Drag corners to adjust crop area',
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF999999)),
      ),
    );
  }
  Widget _buildRotateTools() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 16.w),
          _buildRotateButton(
            icon: Icons.rotate_left,
            label: 'Rotate Left',
            onTap: controller.rotateLeft,
          ),
          SizedBox(width: 20.w),
          _buildRotateButton(
            icon: Icons.rotate_right,
            label: 'Rotate Right',
            onTap: controller.rotateRight,
          ),
          SizedBox(width: 20.w),
          _buildRotateButton(
            icon: Icons.flip,
            label: 'Flip H',
            onTap: controller.flipHorizontal,
          ),
          SizedBox(width: 20.w),
          _buildRotateButton(
            icon: Icons.flip,
            label: 'Flip V',
            onTap: controller.flipVertical,
          ),
          SizedBox(width: 20.w),
          _buildRotateButton(
            icon: Icons.refresh,
            label: 'Reset',
            onTap: controller.resetCurrentPhoto,
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }
  Widget _buildRotateButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Obx(() {
      final isDisabled = controller.isProcessing.value;
      return GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: Column(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Icon(icon, size: 30.w, color: const Color(0xFF666666)),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
class _CropMaskPainter extends CustomPainter {
  final Rect cropRect;
  _CropMaskPainter({required this.cropRect});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cropRect.top), paint);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        cropRect.bottom,
        size.width,
        size.height - cropRect.bottom,
      ),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, cropRect.top, cropRect.left, cropRect.height),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        cropRect.right,
        cropRect.top,
        size.width - cropRect.right,
        cropRect.height,
      ),
      paint,
    );
  }
  @override
  bool shouldRepaint(_CropMaskPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
