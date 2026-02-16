import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'kiddy_frame_work_compare_logic.dart';
class KiddyFrameWorkComparePage extends StatelessWidget {
  const KiddyFrameWorkComparePage({super.key});
  @override
  Widget build(BuildContext context) {
    final logic = Get.find<KiddyFrameWorkCompareLogic>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(logic),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              switch (logic.mode.value) {
                case CompareMode.grid2:
                  return _buildGrid2View(logic);
                case CompareMode.grid4:
                  return _buildGrid4View(logic);
                case CompareMode.grid9:
                  return _buildGrid9View(logic);
                case CompareMode.gridView:
                  return _buildGridView(logic);
              }
            }),
          ),
          _buildBottomBar(logic),
        ],
      ),
    );
  }
  PreferredSizeWidget _buildAppBar(KiddyFrameWorkCompareLogic logic) {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Obx(() {
        final count = logic.selectedIndices.length;
        final total = logic.workPaths.length;
        return Text('Compare ($count of $total)');
      }),
      actions: [
        PopupMenuButton<CompareMode>(
          icon: const Icon(Icons.grid_view),
          onSelected: logic.switchMode,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: CompareMode.grid2,
              child: Text('2-Grid'),
            ),
            const PopupMenuItem(
              value: CompareMode.grid4,
              child: Text('4-Grid'),
            ),
            const PopupMenuItem(
              value: CompareMode.grid9,
              child: Text('9-Grid'),
            ),
            const PopupMenuItem(
              value: CompareMode.gridView,
              child: Text('Grid View'),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildGrid2View(KiddyFrameWorkCompareLogic logic) {
    return Obx(() {
      final direction = logic.splitDirection.value;
      final indices = logic.selectedIndices;
      if (indices.length < 2) {
        return _buildNotEnoughWorksHint();
      }
      return direction == SplitDirection.horizontal
          ? Row(
              children: [
                Expanded(child: _buildWorkView(indices[0], 0, logic)),
                Container(width: 2, color: Colors.white30),
                Expanded(child: _buildWorkView(indices[1], 1, logic)),
              ],
            )
          : Column(
              children: [
                Expanded(child: _buildWorkView(indices[0], 0, logic)),
                Container(height: 2, color: Colors.white30),
                Expanded(child: _buildWorkView(indices[1], 1, logic)),
              ],
            );
    });
  }
  Widget _buildGrid4View(KiddyFrameWorkCompareLogic logic) {
    return Obx(() {
      final indices = logic.selectedIndices;
      if (indices.length < 4) {
        return _buildNotEnoughWorksHint();
      }
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildWorkView(indices[0], 0, logic)),
                Container(width: 2, color: Colors.white30),
                Expanded(child: _buildWorkView(indices[1], 1, logic)),
              ],
            ),
          ),
          Container(height: 2, color: Colors.white30),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildWorkView(indices[2], 2, logic)),
                Container(width: 2, color: Colors.white30),
                Expanded(child: _buildWorkView(indices[3], 3, logic)),
              ],
            ),
          ),
        ],
      );
    });
  }
  Widget _buildGrid9View(KiddyFrameWorkCompareLogic logic) {
    return Obx(() {
      final indices = logic.selectedIndices;
      return GridView.builder(
        padding: EdgeInsets.all(1.w),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: indices.length,
        itemBuilder: (context, i) {
          if (i >= indices.length) return const SizedBox.shrink();
          return _buildWorkView(indices[i], i, logic, enableZoom: false);
        },
      );
    });
  }
  Widget _buildGridView(KiddyFrameWorkCompareLogic logic) {
    return Obx(() {
      return GridView.builder(
        padding: EdgeInsets.all(8.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
        itemCount: logic.workPaths.length,
        itemBuilder: (context, index) {
          return _buildWorkView(index, index, logic, enableZoom: false);
        },
      );
    });
  }
  Widget _buildWorkView(
    int workIndex,
    int controllerIndex,
    KiddyFrameWorkCompareLogic logic, {
    bool enableZoom = true,
  }) {
    return GestureDetector(
      onDoubleTap: () {
        logic.toggleMark(workIndex, MarkType.issue);
      },
      child: Container(
        color: Colors.grey[900],
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (enableZoom && controllerIndex < logic.transformControllers.length)
              InteractiveViewer(
                transformationController: logic.transformControllers[controllerIndex],
                minScale: 0.5,
                maxScale: 3.0,
                onInteractionUpdate: (details) {
                  if (logic.syncZoom.value) {
                  }
                },
                child: Image.file(
                  File(logic.workPaths[workIndex]),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorPlaceholder();
                  },
                ),
              )
            else
              Image.file(
                File(logic.workPaths[workIndex]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorPlaceholder();
                },
              ),
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '${workIndex + 1}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Obx(() {
              final mark = logic.marks[workIndex];
              if (mark == null) return const SizedBox.shrink();
              return Positioned(
                top: 8.h,
                right: 8.w,
                child: _buildMarkBadge(mark),
              );
            }),
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: PopupMenuButton<MarkType>(
                icon: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Icon(Icons.flag, size: 18.w, color: Colors.white),
                ),
                onSelected: (type) => logic.toggleMark(workIndex, type),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: MarkType.issue,
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Issue'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MarkType.done,
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Done'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MarkType.remove,
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Remove'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildMarkBadge(MarkType type) {
    IconData icon;
    Color color;
    switch (type) {
      case MarkType.issue:
        icon = Icons.error;
        color = Colors.red;
        break;
      case MarkType.done:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case MarkType.remove:
        icon = Icons.remove_circle;
        color = Colors.grey;
        break;
    }
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16.w, color: Colors.white),
    );
  }
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: 48.w,
          color: Colors.grey[600],
        ),
      ),
    );
  }
  Widget _buildNotEnoughWorksHint() {
    return Center(
      child: Text(
        'Not enough works for this mode',
        style: TextStyle(
          fontSize: 16.sp,
          color: Colors.white70,
        ),
      ),
    );
  }
  Widget _buildBottomBar(KiddyFrameWorkCompareLogic logic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: logic.canGoPrevious() ? Colors.white : Colors.grey,
              onPressed: logic.canGoPrevious() ? logic.previousGroup : null,
            )),
            Obx(() {
              if (logic.mode.value == CompareMode.grid2 ||
                  logic.mode.value == CompareMode.grid4) {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        logic.syncZoom.value ? Icons.link : Icons.link_off,
                        color: logic.syncZoom.value ? Colors.blue : Colors.grey,
                      ),
                      onPressed: logic.toggleSyncZoom,
                    ),
                    if (logic.mode.value == CompareMode.grid2)
                      IconButton(
                        icon: Icon(
                          logic.splitDirection.value == SplitDirection.horizontal
                              ? Icons.vertical_split
                              : Icons.horizontal_split,
                          color: Colors.white,
                        ),
                        onPressed: logic.toggleSplitDirection,
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            Obx(() {
              final issueCount = logic.getMarkedIndices(MarkType.issue).length;
              final doneCount = logic.getMarkedIndices(MarkType.done).length;
              return Row(
                children: [
                  if (issueCount > 0)
                    _buildMarkCounter(MarkType.issue, issueCount),
                  if (doneCount > 0)
                    Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: _buildMarkCounter(MarkType.done, doneCount),
                    ),
                ],
              );
            }),
            Obx(() => IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              color: logic.canGoNext() ? Colors.white : Colors.grey,
              onPressed: logic.canGoNext() ? logic.nextGroup : null,
            )),
          ],
        ),
      ),
    );
  }
  Widget _buildMarkCounter(MarkType type, int count) {
    Color color;
    IconData icon;
    switch (type) {
      case MarkType.issue:
        color = Colors.red;
        icon = Icons.error;
        break;
      case MarkType.done:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case MarkType.remove:
        color = Colors.grey;
        icon = Icons.remove_circle;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.w, color: color),
          SizedBox(width: 4.w),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
