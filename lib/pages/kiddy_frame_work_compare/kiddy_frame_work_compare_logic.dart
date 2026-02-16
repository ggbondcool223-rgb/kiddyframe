import 'package:flutter/material.dart';
import 'package:get/get.dart';
enum CompareMode {
  grid2,
  grid4,
  grid9,
  gridView,
}
enum SplitDirection {
  horizontal,
  vertical,
}
enum MarkType {
  issue,
  done,
  remove,
}
class KiddyFrameWorkCompareLogic extends GetxController {
  late final List<String> workPaths;
  final mode = CompareMode.grid2.obs;
  final selectedIndices = <int>[].obs;
  final syncZoom = true.obs;
  final syncPan = false.obs;
  final splitDirection = SplitDirection.horizontal.obs;
  final marks = <int, MarkType>{}.obs;
  final transformControllers = <TransformationController>[];
  final currentScale = 1.0.obs;
  @override
  void onInit() {
    super.onInit();
    workPaths = Get.arguments['workPaths'] as List<String>;
    final initialMode = Get.arguments['mode'] as CompareMode? ?? CompareMode.grid2;
    mode.value = initialMode;
    _initializeIndices();
    _initializeControllers();
  }
  @override
  void onClose() {
    for (var controller in transformControllers) {
      controller.dispose();
    }
    super.onClose();
  }
  void _initializeIndices() {
    final count = _getGridCount();
    selectedIndices.clear();
    for (int i = 0; i < count && i < workPaths.length; i++) {
      selectedIndices.add(i);
    }
  }
  void _initializeControllers() {
    transformControllers.clear();
    final count = _getGridCount();
    for (int i = 0; i < count; i++) {
      transformControllers.add(TransformationController());
    }
  }
  int _getGridCount() {
    switch (mode.value) {
      case CompareMode.grid2:
        return 2;
      case CompareMode.grid4:
        return 4;
      case CompareMode.grid9:
        return 9;
      case CompareMode.gridView:
        return workPaths.length;
    }
  }
  void switchMode(CompareMode newMode) {
    mode.value = newMode;
    _initializeIndices();
    _initializeControllers();
  }
  void toggleSplitDirection() {
    if (mode.value == CompareMode.grid2) {
      splitDirection.value = splitDirection.value == SplitDirection.horizontal
          ? SplitDirection.vertical
          : SplitDirection.horizontal;
    }
  }
  void toggleSyncZoom() {
    syncZoom.value = !syncZoom.value;
  }
  void toggleSyncPan() {
    syncPan.value = !syncPan.value;
  }
  void previousGroup() {
    final count = _getGridCount();
    final firstIndex = selectedIndices.first;
    if (firstIndex >= count) {
      selectedIndices.clear();
      for (int i = firstIndex - count; i < firstIndex; i++) {
        selectedIndices.add(i);
      }
      _resetTransforms();
    }
  }
  void nextGroup() {
    final count = _getGridCount();
    final lastIndex = selectedIndices.last;
    if (lastIndex + count < workPaths.length) {
      selectedIndices.clear();
      for (int i = lastIndex + 1; i <= lastIndex + count && i < workPaths.length; i++) {
        selectedIndices.add(i);
      }
      _resetTransforms();
    }
  }
  bool canGoPrevious() {
    return selectedIndices.isNotEmpty && selectedIndices.first >= _getGridCount();
  }
  bool canGoNext() {
    final count = _getGridCount();
    return selectedIndices.isNotEmpty &&
        selectedIndices.last + count < workPaths.length;
  }
  void _resetTransforms() {
    for (var controller in transformControllers) {
      controller.value = Matrix4.identity();
    }
    currentScale.value = 1.0;
  }
  void markWork(int index, MarkType type) {
    marks[index] = type;
    Get.snackbar(
      'Marked',
      'Work ${index + 1} marked as ${_getMarkTypeName(type)}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }
  void clearMark(int index) {
    marks.remove(index);
  }
  void toggleMark(int index, MarkType type) {
    if (marks[index] == type) {
      clearMark(index);
    } else {
      markWork(index, type);
    }
  }
  String _getMarkTypeName(MarkType type) {
    switch (type) {
      case MarkType.issue:
        return 'Issue';
      case MarkType.done:
        return 'Done';
      case MarkType.remove:
        return 'Remove';
    }
  }
  List<int> getMarkedIndices(MarkType type) {
    return marks.entries
        .where((e) => e.value == type)
        .map((e) => e.key)
        .toList();
  }
  void onScaleUpdate(ScaleUpdateDetails details, int controllerIndex) {
    if (!syncZoom.value) {
      return;
    }
    final scale = details.scale;
    currentScale.value = scale;
    for (var controller in transformControllers) {
      controller.value = Matrix4.identity()..scale(scale);
    }
  }
}
