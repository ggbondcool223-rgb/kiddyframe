import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'kiddy_frame_photo_edit_logic.dart';
import '../../main.dart' show primaryColor, accentColor1, bgColor, textColor;
class KiddyFramePhotoEditView extends GetView<KiddyFramePhotoEditLogic> {
  const KiddyFramePhotoEditView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildPreviewArea()),
          _buildToolsPanel(),
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
        'Edit Photo',
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
      actions: _buildAppBarActions(),
    );
  }
  List<Widget> _buildAppBarActions() {
    return [
      PopupMenuButton<String>(
        icon: Icon(Icons.more_vert, size: 24.w, color: const Color(0xFF333333)),
        onSelected: (value) {
          if (value == 'save_preset') {
            _showSavePresetDialog();
          } else if (value == 'load_preset') {
            _showLoadPresetDialog();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'save_preset',
            child: Row(
              children: [
                Icon(Icons.bookmark_add_outlined),
                SizedBox(width: 8),
                Text('Save as Preset'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'load_preset',
            child: Row(
              children: [
                Icon(Icons.bookmarks_outlined),
                SizedBox(width: 8),
                Text('Load Preset'),
              ],
            ),
          ),
        ],
      ),
      if (controller.photos.length > 1)
        IconButton(
          icon: Icon(
            Icons.auto_awesome,
            size: 24.w,
            color: const Color(0xFF9C27B0),
          ),
          onPressed: controller.onBatchFrame,
        ),
      IconButton(
        icon: Icon(Icons.save, size: 24.w, color: const Color(0xFFFF9500)),
        onPressed: controller.onSaveTap,
      ),
    ];
  }
  Widget _buildPreviewArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenCenterX = constraints.maxWidth / 2;
        final screenCenterY = constraints.maxHeight / 2;
        return Stack(
          children: [
            RepaintBoundary(
              key: controller.previewKey,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildBackgroundLayer()),
                    Center(
                      child: Obx(() {
                        final containerWidth = controller.cropBoxWidth;
                        final containerHeight = controller.cropBoxHeight;
                        return SizedBox(
                          width: containerWidth,
                          height: containerHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (controller.currentPhotoFile.value != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Transform.scale(
                                        scale: controller.imageScale.value,
                                        child: Transform.translate(
                                          offset: controller.imageOffset.value,
                                          child: Image.file(
                                            controller.currentPhotoFile.value!,
                                            width: containerWidth,
                                            height: containerHeight,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              if (controller.currentPhotoFile.value == null)
                                Positioned.fill(
                                  child: Center(
                                    child: Container(
                                      width: containerWidth,
                                      height: containerHeight,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image,
                                        size: 80.w,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ),
                              _buildFrameOverlay(
                                containerWidth,
                                containerHeight,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    Obx(() {
                      final containerWidth = controller.cropBoxWidth;
                      final containerHeight = controller.cropBoxHeight;
                      final offsetX = screenCenterX - containerWidth / 2;
                      final offsetY = screenCenterY - containerHeight / 2;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: _buildAbsoluteStickersLayer(offsetX, offsetY),
                      );
                    }),
                    Obx(() {
                      final containerWidth = controller.cropBoxWidth;
                      final containerHeight = controller.cropBoxHeight;
                      final offsetX = screenCenterX - containerWidth / 2;
                      final offsetY = screenCenterY - containerHeight / 2;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: _buildAbsoluteTextsLayer(offsetX, offsetY),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Obx(() {
              if (controller.currentTool.value == 4 &&
                  controller.currentPhotoFile.value != null) {
                final containerWidth = controller.cropBoxWidth;
                final containerHeight = controller.cropBoxHeight;
                return Center(
                  child: SizedBox(
                    width: containerWidth,
                    height: containerHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (details) {
                        controller.updateImageOffset(
                          controller.imageOffset.value + details.delta,
                        );
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            Positioned.fill(
              child: Obx(() {
                final containerWidth = controller.cropBoxWidth;
                final containerHeight = controller.cropBoxHeight;
                final offsetX = screenCenterX - containerWidth / 2;
                final offsetY = screenCenterY - containerHeight / 2;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ..._buildInteractiveStickersLayer(offsetX, offsetY),
                    ..._buildInteractiveTextsLayer(offsetX, offsetY),
                  ],
                );
              }),
            ),
            if (controller.photos.length > 1) _buildPhotoNavigator(),
          ],
        );
      },
    );
  }
  Widget _buildFrameOverlay(double containerWidth, double containerHeight) {
    return Obx(() {
      if (controller.frames.isEmpty) {
        return const SizedBox.shrink();
      }
      if (controller.selectedFrameIndex.value == 0) {
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 20.0),
              ),
            ),
          ),
        );
      }
      final frame = controller.frames[controller.selectedFrameIndex.value - 1];
      final framePath = frame.filePath;
      if (framePath.isEmpty && frame.defaultColors != null) {
        final borderColor = _parseColor(frame.defaultColors!);
        final borderWidth = frame.innerPaddingTop.toDouble();
        return Positioned.fill(
          child: Obx(() {
            return IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: controller.frameOpacity.value,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                ),
              ),
            );
          }),
        );
      }
      return Positioned.fill(
        child: Obx(() {
          return IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: controller.frameOpacity.value,
              child: Stack(
                children: [
                  Container(
                    decoration: frame.hasShadow == 1
                        ? BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          )
                        : null,
                    child: Image.asset(
                      framePath,
                      width: containerWidth,
                      height: containerHeight,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF4CC9F0),
                              width: 8.w,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }
  Widget _buildToolsPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 160.h,
            child: Obx(() {
              if (controller.currentTool.value == 0) {
                return _buildFramePanel();
              } else if (controller.currentTool.value == 1) {
                return _buildBackgroundPanel();
              } else if (controller.currentTool.value == 2) {
                return _buildStickerPanel();
              } else if (controller.currentTool.value == 3) {
                return _buildTextPanel();
              } else if (controller.currentTool.value == 4) {
                return _buildImageScalePanel();
              }
              return Center(
                child: Text(
                  'Other tools coming soon',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
              );
            }),
          ),
          _buildToolBar(),
        ],
      ),
    );
  }
  Widget _buildToolBar() {
    final tools = [
      {'icon': Icons.crop_portrait_outlined, 'label': 'Frame'},
      {'icon': Icons.palette_outlined, 'label': 'Background'},
      {'icon': Icons.emoji_emotions_outlined, 'label': 'Sticker'},
      {'icon': Icons.text_fields, 'label': 'Text'},
      {'icon': Icons.photo_size_select_large, 'label': 'Scale'},
    ];
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tools.length,
        itemBuilder: (context, index) {
          return _buildToolButton(
            icon: tools[index]['icon'] as IconData,
            label: tools[index]['label'] as String,
            index: index,
          );
        },
      ),
    );
  }
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return Obx(() {
      final isSelected = controller.currentTool.value == index;
      return GestureDetector(
        onTap: () => controller.selectTool(index),
        child: Container(
          width: 66.w,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 26.w,
                color: isSelected
                    ? const Color(0xFF4CC9F0)
                    : const Color(0xFF999999),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isSelected
                      ? const Color(0xFF4CC9F0)
                      : const Color(0xFF999999),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildFramePanel() {
    return Column(
      children: [
        _buildFrameCategoryTabs(),
        Expanded(child: _buildFrameList()),
      ],
    );
  }
  Widget _buildFrameCategoryTabs() {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.frameCategories.length,
          itemBuilder: (context, index) {
            return _buildCategoryTab(controller.frameCategories[index], index);
          },
        );
      }),
    );
  }
  Widget _buildCategoryTab(String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedFrameCategory.value == index;
      return GestureDetector(
        onTap: () => controller.selectFrameCategory(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF333333)
                    : const Color(0xFF999999),
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildFrameList() {
    return Obx(() {
      if (controller.isLoadingFrames.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4CC9F0),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Loading frames...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }
      final totalCount = 1 + controller.frames.length;
      if (totalCount == 1) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.crop_portrait_outlined,
                size: 48.w,
                color: Colors.grey[300],
              ),
              SizedBox(height: 12.h),
              Text(
                'No frames available',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: totalCount,
          itemBuilder: (context, index) {
            return _buildFrameItem(index);
          },
        ),
      );
    });
  }
  Widget _buildFrameItem(int index) {
    return Obx(() {
      final isSelected = controller.selectedFrameIndex.value == index;
      if (index == 0) {
        return GestureDetector(
          onTap: () => controller.selectFrame(0),
          child: Container(
            width: 70.w,
            margin: EdgeInsets.only(right: 10.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.w),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4CC9F0)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        border: Border.all(color: Colors.white, width: 6),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'White Border',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      final frame = controller.frames[index - 1];
      return GestureDetector(
        onTap: () => controller.selectFrame(index),
        child: Container(
          width: 70.w,
          margin: EdgeInsets.only(right: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4CC9F0)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.w),
                  child: _buildFrameThumbnail(frame),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                frame.name,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF666666),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildFrameThumbnail(dynamic frame) {
    if (frame.filePath.isEmpty && frame.defaultColors != null) {
      final borderColor = _parseColor(frame.defaultColors!);
      return Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Center(
          child: Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: borderColor, width: 3.w),
            ),
          ),
        ),
      );
    }
    final thumbnailPath = frame.thumbnailPath;
    final framePath = frame.filePath;
    if (thumbnailPath.isNotEmpty) {
      return Image.asset(
        thumbnailPath,
        width: 70.w,
        height: 70.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFrameImageFallback(framePath);
        },
      );
    }
    return _buildFrameImageFallback(framePath);
  }
  Widget _buildFrameImageFallback(String framePath) {
    return Image.asset(
      framePath,
      width: 70.w,
      height: 70.w,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(Icons.crop_portrait, size: 30.w, color: Colors.grey[400]),
        );
      },
    );
  }
  Widget _buildBackgroundPanel() {
    return Column(
      children: [
        _buildBackgroundTypeTabs(),
        Expanded(child: _buildBackgroundList()),
      ],
    );
  }
  Widget _buildBackgroundTypeTabs() {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.backgroundTypes.length,
          itemBuilder: (context, index) {
            return _buildBackgroundTypeTab(
              controller.backgroundTypes[index],
              index,
            );
          },
        );
      }),
    );
  }
  Widget _buildBackgroundTypeTab(String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedBackgroundType.value == index;
      return GestureDetector(
        onTap: () => controller.selectBackgroundType(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF333333)
                    : const Color(0xFF999999),
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildBackgroundList() {
    return Obx(() {
      if (controller.isLoadingBackgrounds.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4CC9F0),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Loading backgrounds...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }
      if (controller.backgrounds.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.palette_outlined, size: 48.w, color: Colors.grey[300]),
              SizedBox(height: 12.h),
              Text(
                'No backgrounds available',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.backgrounds.length,
          itemBuilder: (context, index) {
            return _buildBackgroundItem(index);
          },
        ),
      );
    });
  }
  Widget _buildBackgroundItem(int index) {
    return Obx(() {
      final isSelected = controller.selectedBackgroundIndex.value == index;
      final background = controller.backgrounds[index];
      return GestureDetector(
        onTap: () => controller.selectBackground(index),
        child: Container(
          width: 70.w,
          margin: EdgeInsets.only(right: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4CC9F0)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.w),
                      child: _buildBackgroundThumbnail(background),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                background.name,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF666666),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildBackgroundThumbnail(dynamic background) {
    if (background.type == 'color' && background.colorValue != null) {
      final color = _parseColor(background.colorValue!);
      return Container(width: 70.w, height: 70.w, color: color);
    }
    if (background.type == 'gradient' && background.colorValue != null) {
      final gradient = _parseGradient(background.colorValue!);
      return Container(
        width: 70.w,
        height: 70.w,
        decoration: BoxDecoration(gradient: gradient),
      );
    }
    if (background.type == 'image' && background.thumbnailPath != null) {
      return Image.asset(
        background.thumbnailPath!,
        width: 70.w,
        height: 70.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.image, size: 30.w, color: Colors.grey[400]),
          );
        },
      );
    }
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.palette, size: 30.w, color: Colors.grey[400]),
    );
  }
  Widget _buildStickerPanel() {
    return Column(
      children: [
        _buildStickerCategoryTabs(),
        Expanded(child: _buildStickerList()),
      ],
    );
  }
  Widget _buildStickerCategoryTabs() {
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Obx(() {
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.stickerCategories.length,
          itemBuilder: (context, index) {
            return _buildStickerCategoryTab(
              controller.stickerCategories[index],
              index,
            );
          },
        );
      }),
    );
  }
  Widget _buildStickerCategoryTab(String label, int index) {
    return Obx(() {
      final isSelected = controller.selectedStickerCategory.value == index;
      return GestureDetector(
        onTap: () => controller.selectStickerCategory(index),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF333333)
                    : const Color(0xFF999999),
              ),
            ),
          ),
        ),
      );
    });
  }
  Widget _buildStickerList() {
    return Obx(() {
      if (controller.isLoadingStickers.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4CC9F0),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Loading stickers...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }
      if (controller.stickers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_emotions_outlined,
                size: 48.w,
                color: Colors.grey[300],
              ),
              SizedBox(height: 12.h),
              Text(
                'No stickers available',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.stickers.length,
          itemBuilder: (context, index) {
            return _buildStickerItem(controller.stickers[index]);
          },
        ),
      );
    });
  }
  Widget _buildStickerItem(dynamic sticker) {
    return GestureDetector(
      onTap: () => controller.addSticker(sticker),
      child: Container(
        width: 70.w,
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      sticker.thumbnailPath.isNotEmpty
                          ? sticker.thumbnailPath
                          : sticker.filePath,
                      width: 56.w,
                      height: 56.w,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.emoji_emotions,
                          size: 30.w,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              sticker.name,
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFF666666)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTextPanel() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.text_fields, size: 32.w, color: const Color(0xFF4CC9F0)),
          SizedBox(height: 8.h),
          Text(
            'Add Text to Your Photo',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Tap the button below to add custom text',
            style: TextStyle(fontSize: 10.sp, color: const Color(0xFF999999)),
          ),
          SizedBox(height: 10.h),
          ElevatedButton.icon(
            onPressed: controller.addText,
            icon: Icon(Icons.add, size: 16.w),
            label: Text('Add Text', style: TextStyle(fontSize: 12.sp)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CC9F0),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildImageScalePanel() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Image Scale',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                Text(
                  '${(controller.imageScale.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4CC9F0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.zoom_out, size: 20.w, color: Colors.grey[600]),
                Expanded(
                  child: Slider(
                    value: controller.imageScale.value,
                    min: 0.5,
                    max: 3.0,
                    divisions: 25,
                    activeColor: const Color(0xFF4CC9F0),
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) {
                      controller.updateImageScale(value);
                    },
                  ),
                ),
                Icon(Icons.zoom_in, size: 20.w, color: Colors.grey[600]),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Drag image to reposition',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF999999),
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.resetImageTransform,
                  icon: Icon(Icons.refresh, size: 14.w),
                  label: Text('Reset', style: TextStyle(fontSize: 11.sp)),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4CC9F0),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
  Widget _buildBackgroundLayer() {
    return Obx(() {
      if (controller.backgrounds.isEmpty ||
          controller.selectedBackgroundIndex.value < 0 ||
          controller.selectedBackgroundIndex.value >=
              controller.backgrounds.length) {
        return Container(color: Colors.white);
      }
      final background =
          controller.backgrounds[controller.selectedBackgroundIndex.value];
      if (background.type == 'color' && background.colorValue != null) {
        final color = _parseColor(background.colorValue!);
        return Container(color: color);
      }
      if (background.type == 'gradient' && background.colorValue != null) {
        final gradient = _parseGradient(background.colorValue!);
        return Container(decoration: BoxDecoration(gradient: gradient));
      }
      if (background.type == 'image' && background.filePath != null) {
        return Image.asset(
          background.filePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.white);
          },
        );
      }
      return Container(color: Colors.white);
    });
  }
  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }
  LinearGradient _parseGradient(String jsonStr) {
    try {
      final data = json.decode(jsonStr);
      final colors = (data['colors'] as List)
          .map((c) => _parseColor(c as String))
          .toList();
      final begin = _parseAlignment(data['begin'] as String);
      final end = _parseAlignment(data['end'] as String);
      return LinearGradient(colors: colors, begin: begin, end: end);
    } catch (e) {
      return LinearGradient(
        colors: [Colors.white, Colors.grey[200]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }
  Alignment _parseAlignment(String alignmentStr) {
    switch (alignmentStr) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.topLeft;
    }
  }
  List<Widget> _buildAbsoluteStickersLayer(double offsetX, double offsetY) {
    return controller.addedStickers.map((stickerItem) {
      return Obx(
        () => Positioned(
          left: offsetX + stickerItem.position.value.dx,
          top: offsetY + stickerItem.position.value.dy,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: stickerItem.rotation.value,
              child: Transform.scale(
                scale: stickerItem.scale.value,
                child: Image.asset(
                  stickerItem.sticker.filePath,
                  width: 80.w,
                  height: 80.w,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.emoji_emotions,
                      size: 80.w,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
  List<Widget> _buildInteractiveStickersLayer(double offsetX, double offsetY) {
    return controller.addedStickers.asMap().entries.map((entry) {
      final index = entry.key;
      final stickerItem = entry.value;
      return Obx(
        () => Positioned(
          left: offsetX + stickerItem.position.value.dx,
          top: offsetY + stickerItem.position.value.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              stickerItem.position.value += details.delta;
            },
            onLongPress: () {
              _showStickerOptions(index);
            },
            child: Transform.rotate(
              angle: stickerItem.rotation.value,
              child: Transform.scale(
                scale: stickerItem.scale.value,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
  void _showStickerOptions(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Sticker Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.zoom_in),
              title: const Text('Scale'),
              subtitle: Obx(
                () => Slider(
                  value: controller.addedStickers[index].scale.value,
                  min: 0.5,
                  max: 3.0,
                  onChanged: (value) {
                    controller.addedStickers[index].scale.value = value;
                  },
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.rotate_right),
              title: const Text('Rotation'),
              subtitle: Obx(
                () => Slider(
                  value: controller.addedStickers[index].rotation.value,
                  min: 0,
                  max: 6.28,
                  onChanged: (value) {
                    controller.addedStickers[index].rotation.value = value;
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.removeSticker(index);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Get.back(), child: const Text('Done')),
        ],
      ),
    );
  }
  List<Widget> _buildAbsoluteTextsLayer(double offsetX, double offsetY) {
    return controller.textItems.map((textItem) {
      return Obx(
        () => Positioned(
          left: offsetX + textItem.position.value.dx,
          top: offsetY + textItem.position.value.dy,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: textItem.rotation.value,
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  textItem.content.value,
                  style: TextStyle(
                    fontSize: textItem.fontSize.value.sp,
                    color: textItem.color.value,
                    fontFamily: textItem.fontFamily.value,
                    fontWeight: textItem.isBold.value
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontStyle: textItem.isItalic.value
                        ? FontStyle.italic
                        : FontStyle.normal,
                    decoration: textItem.isUnderline.value
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
  List<Widget> _buildInteractiveTextsLayer(double offsetX, double offsetY) {
    return controller.textItems.asMap().entries.map((entry) {
      final index = entry.key;
      final textItem = entry.value;
      return Obx(
        () => Positioned(
          left: offsetX + textItem.position.value.dx,
          top: offsetY + textItem.position.value.dy,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: (details) {
              textItem.position.value += details.delta;
            },
            onTap: () => controller.selectText(index),
            child: Transform.rotate(
              angle: textItem.rotation.value,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: controller.selectedTextIndex.value == index
                      ? Border.all(color: const Color(0xFF4CC9F0), width: 2)
                      : null,
                ),
                child: Text(
                  textItem.content.value,
                  style: TextStyle(
                    fontSize: textItem.fontSize.value.sp,
                    color: textItem.color.value,
                    fontFamily: textItem.fontFamily.value,
                    fontWeight: textItem.isBold.value
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontStyle: textItem.isItalic.value
                        ? FontStyle.italic
                        : FontStyle.normal,
                    decoration: textItem.isUnderline.value
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
  Widget _buildPhotoNavigator() {
    return Positioned(
      bottom: 20.h,
      left: 0,
      right: 0,
      child: Obx(() {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: controller.currentIndex.value > 0
                      ? Colors.white
                      : Colors.grey,
                  size: 20.w,
                ),
                onPressed: controller.currentIndex.value > 0
                    ? controller.onPreviousPhoto
                    : null,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${controller.currentIndex.value + 1} / ${controller.photos.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color:
                      controller.currentIndex.value <
                          controller.photos.length - 1
                      ? Colors.white
                      : Colors.grey,
                  size: 20.w,
                ),
                onPressed:
                    controller.currentIndex.value < controller.photos.length - 1
                    ? controller.onNextPhoto
                    : null,
              ),
            ],
          ),
        );
      }),
    );
  }
  void _showSavePresetDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          width: 340.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Save as Preset',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Preset Name *',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: TextField(
                  controller: nameController,
                  style: TextStyle(fontSize: 15.sp, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g., Simple White Frame',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    counterText: '',
                  ),
                  maxLength: 30,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Description (Optional)',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: TextField(
                  controller: descController,
                  style: TextStyle(fontSize: 15.sp, color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Brief description of this preset',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[400],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    counterText: '',
                  ),
                  maxLength: 100,
                  maxLines: 3,
                  minLines: 3,
                ),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Preset name is required',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: EdgeInsets.all(16.w),
                            borderRadius: 12.r,
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        }
                        Get.back();
                        controller.saveAsPreset(
                          name: name,
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                        );
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, accentColor1],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_add,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Save Preset',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
  void _showLoadPresetDialog() {
    controller.loadPresetList();
    Get.dialog(
      AlertDialog(
        title: const Text('Load Preset'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: Obx(() {
            if (controller.isLoadingPresets.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.availablePresets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border, size: 64.w, color: Colors.grey),
                    SizedBox(height: 16.h),
                    const Text('No presets available'),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: controller.availablePresets.length,
              itemBuilder: (context, index) {
                final preset = controller.availablePresets[index];
                return ListTile(
                  leading: Icon(
                    preset.isDefault == 1
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: const Color(0xFFFF4081),
                  ),
                  title: Text(preset.name),
                  subtitle: preset.description != null
                      ? Text(preset.description!)
                      : null,
                  trailing: Text(
                    'Used ${preset.usageCount}x',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  onTap: () {
                    Get.back();
                    controller.applyPreset(preset);
                  },
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed('/kiddy_frame_preset_management');
            },
            child: const Text('Manage Presets'),
          ),
        ],
      ),
    );
  }
}
