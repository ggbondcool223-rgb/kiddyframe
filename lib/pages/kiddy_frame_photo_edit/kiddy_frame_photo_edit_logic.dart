import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../utils/index.dart';
import '../../db_kiddy_frame/db_kiddy_frame_entity.dart';
import '../../db_kiddy_frame/db_kiddy_frame_service.dart';
class StickerItem {
  final StickerEntity sticker;
  final Rx<Offset> position;
  final RxDouble scale;
  final RxDouble rotation;
  StickerItem({
    required this.sticker,
    Offset? initialPosition,
    double initialScale = 1.0,
    double initialRotation = 0.0,
  }) : position = (initialPosition ?? Offset.zero).obs,
       scale = initialScale.obs,
       rotation = initialRotation.obs;
}
class TextItem {
  final RxString content;
  final Rx<Color> color;
  final RxDouble fontSize;
  final Rx<Offset> position;
  final RxDouble rotation;
  final RxString fontFamily;
  final RxBool isBold;
  final RxBool isItalic;
  final RxBool isUnderline;
  TextItem({
    String? initialContent,
    Color? initialColor,
    double initialFontSize = 24.0,
    Offset? initialPosition,
    double initialRotation = 0.0,
    String initialFontFamily = 'Roboto',
    bool initialIsBold = false,
    bool initialIsItalic = false,
    bool initialIsUnderline = false,
  }) : content = (initialContent ?? 'Text').obs,
       color = (initialColor ?? Colors.black).obs,
       fontSize = initialFontSize.obs,
       position = (initialPosition ?? Offset.zero).obs,
       rotation = initialRotation.obs,
       fontFamily = initialFontFamily.obs,
       isBold = initialIsBold.obs,
       isItalic = initialIsItalic.obs,
       isUnderline = initialIsUnderline.obs;
}
class KiddyFramePhotoEditLogic extends GetxController {
  final List<dynamic> photos = Get.arguments?['photos'] ?? [];
  final double cropBoxWidth = Get.arguments?['cropBoxWidth'] ?? 280.0;
  final double cropBoxHeight = Get.arguments?['cropBoxHeight'] ?? 400.0;
  final String? studentId = Get.arguments?['studentId'];
  final currentIndex = 0.obs;
  final currentPhotoFile = Rx<File?>(null);
  final GlobalKey previewKey = GlobalKey();
  final containerPosition = const Offset(0, 0).obs;
  final imageScale = 1.0.obs;
  final imageOffset = const Offset(0, 0).obs;
  final currentTool =
      0.obs;
  final selectedFrameCategory = 3.obs;
  final selectedFrameIndex = 0.obs;
  final frameCategories = <String>[
    'Color',
    'Cartoon',
    'Creative',
    'Simple',
    'Festival',
  ].obs;
  final frames = <FrameEntity>[].obs;
  final isLoadingFrames = false.obs;
  final backgroundTypes = <String>['Color', 'Gradient', 'Image'].obs;
  final selectedBackgroundType = 0.obs;
  final backgrounds = <BackgroundEntity>[].obs;
  final isLoadingBackgrounds = false.obs;
  final selectedBackgroundIndex = (-1).obs;
  final stickerCategories = <String>[
    'Rating',
    'Festival',
    'Praise',
    'Decoration',
  ].obs;
  final selectedStickerCategory = 0.obs;
  final stickers = <StickerEntity>[].obs;
  final isLoadingStickers = false.obs;
  final addedStickers = <StickerItem>[].obs;
  final textItems = <TextItem>[].obs;
  final selectedTextIndex = (-1).obs;
  final isSaving = false.obs;
  final frameOpacity = 1.0.obs;
  final availablePresets = <FramingPresetEntity>[].obs;
  final isLoadingPresets = false.obs;
  @override
  void onInit() {
    super.onInit();
    if (photos.isEmpty) {
      errorToast('No photos selected');
      Get.back();
      return;
    }
    _loadCurrentPhoto();
    _loadFrames(frameCategories[selectedFrameCategory.value]);
  }
  Future<void> _loadCurrentPhoto() async {
    try {
      final photoItem = photos[currentIndex.value];
      if (photoItem is String) {
        currentPhotoFile.value = File(photoItem);
      } else if (photoItem is AssetEntity) {
        final file = await photoItem.file;
        if (file != null) {
          currentPhotoFile.value = file;
        } else {
          errorToast('Failed to load photo file');
        }
      } else {
        errorToast('Invalid photo type');
      }
    } catch (e) {
      errorToast('Failed to load photo: ${e.toString()}');
    }
  }
  Future<void> _loadFrames(String category) async {
    try {
      isLoadingFrames.value = true;
      final dbService = Get.find<KiddyFrameDatabaseService>();
      final categoryId = category.toLowerCase();
      final loadedFrames = await dbService.database.getFramesByCategory(
        categoryId,
      );
      frames.value = loadedFrames;
      print('📸 Loaded ${loadedFrames.length} frames for category: $category');
      for (var frame in loadedFrames) {
        print('  - ${frame.name} (${frame.frameId})');
      }
    } catch (e) {
      frames.clear();
      print('Failed to load frames: ${e.toString()}');
      errorToast('Failed to load frames');
    } finally {
      isLoadingFrames.value = false;
    }
  }
  void selectTool(int index) {
    currentTool.value = index;
    if (index == 1 && backgrounds.isEmpty) {
      _loadBackgrounds(backgroundTypes[selectedBackgroundType.value]);
    } else if (index == 2 && stickers.isEmpty) {
      _loadStickers(stickerCategories[selectedStickerCategory.value]);
    }
  }
  void updateImageScale(double scale) {
    imageScale.value = scale.clamp(0.5, 3.0);
  }
  void updateImageOffset(Offset offset) {
    imageOffset.value = offset;
  }
  void resetImageTransform() {
    imageScale.value = 1.0;
    imageOffset.value = const Offset(0, 0);
  }
  void selectFrameCategory(int index) {
    selectedFrameCategory.value = index;
    selectedFrameIndex.value = 0;
    _loadFrames(frameCategories[index]);
  }
  void selectFrame(int index) async {
    if (index == 0) {
      if (selectedFrameIndex.value != 0) {
        frameOpacity.value = 0.0;
        await Future.delayed(const Duration(milliseconds: 200));
      }
      selectedFrameIndex.value = index;
      return;
    }
    await _applyFrameWithAnimation(index);
  }
  Future<void> _applyFrameWithAnimation(int index) async {
    if (selectedFrameIndex.value != 0) {
      frameOpacity.value = 0.0;
      await Future.delayed(const Duration(milliseconds: 200));
    }
    selectedFrameIndex.value = index;
    await Future.delayed(const Duration(milliseconds: 50));
    frameOpacity.value = 1.0;
  }
  Future<void> onSaveTap() async {
    if (currentPhotoFile.value == null) {
      errorToast('No photo to save');
      return;
    }
    try {
      isSaving.value = true;
      if (photos.length > 1) {
        await _saveAllPhotos();
      } else {
        await _saveSinglePhoto();
      }
    } catch (e) {
      errorToast('Failed to save: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }
  Future<void> _saveSinglePhoto() async {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Saving artwork...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    try {
      final savedFile = await _compositeImage();
      await _saveToDatabase(savedFile);
      Get.back();
      successToast('Artwork saved successfully');
      Get.back();
    } catch (e) {
      Get.back();
      rethrow;
    }
  }
  Future<void> _saveAllPhotos() async {
    final processedCount = 0.obs;
    final savedCount = 0.obs;
    final totalCount = photos.length;
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4CC9F0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Saving photos...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Column(
                      children: [
                        Text(
                          'Processing: ${processedCount.value}/$totalCount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Saved: ${savedCount.value}/$totalCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4CC9F0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    try {
      final currentIdx = currentIndex.value;
      final savedFrameIndex = selectedFrameIndex.value;
      final savedBackgroundIndex = selectedBackgroundIndex.value;
      final savedStickers = List<StickerItem>.from(addedStickers);
      final savedTexts = List<TextItem>.from(textItems);
      final savedImageScale = imageScale.value;
      final savedImageOffset = imageOffset.value;
      print('🚀 Starting save all photos: $totalCount photos...');
      for (int i = 0; i < photos.length; i++) {
        try {
          processedCount.value = i + 1;
          print('📷 Processing photo ${i + 1}/$totalCount...');
          currentIndex.value = i;
          await _loadCurrentPhoto();
          await Future.delayed(const Duration(milliseconds: 300));
          selectedFrameIndex.value = savedFrameIndex;
          selectedBackgroundIndex.value = savedBackgroundIndex;
          addedStickers.clear();
          for (final sticker in savedStickers) {
            addedStickers.add(
              StickerItem(
                sticker: sticker.sticker,
                initialPosition: sticker.position.value,
                initialScale: sticker.scale.value,
                initialRotation: sticker.rotation.value,
              ),
            );
          }
          textItems.clear();
          for (final text in savedTexts) {
            textItems.add(
              TextItem(
                initialContent: text.content.value,
                initialColor: text.color.value,
                initialFontSize: text.fontSize.value,
                initialPosition: text.position.value,
                initialRotation: text.rotation.value,
                initialFontFamily: text.fontFamily.value,
                initialIsBold: text.isBold.value,
                initialIsItalic: text.isItalic.value,
                initialIsUnderline: text.isUnderline.value,
              ),
            );
          }
          imageScale.value = savedImageScale;
          imageOffset.value = savedImageOffset;
          await Future.delayed(const Duration(milliseconds: 500));
          final compositeFile = await _compositeImage();
          await _saveToDatabase(compositeFile);
          savedCount.value = i + 1;
          print('✅ Successfully processed and saved photo ${i + 1}/$totalCount');
        } catch (e) {
          print('❌ Failed to process photo ${i + 1}: ${e.toString()}');
          continue;
        }
      }
      currentIndex.value = currentIdx;
      await _loadCurrentPhoto();
      Get.back();
      final actualSaved = savedCount.value;
      if (actualSaved == totalCount) {
        successToast('Successfully saved all $actualSaved photo(s)');
      } else {
        successToast('Successfully saved $actualSaved out of $totalCount photo(s)');
      }
      print('🎉 Save all photos completed: $actualSaved/$totalCount photos saved');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      Get.back();
      rethrow;
    }
  }
  Future<void> onResetTap() async {
    try {
      Get.dialog(
        AlertDialog(
          title: const Text('Reset'),
          content: const Text('Reset all edits?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                selectedFrameIndex.value = 0;
                selectedBackgroundIndex.value = -1;
                addedStickers.clear();
                textItems.clear();
                currentTool.value = 0;
                containerPosition.value = const Offset(0, 0);
                Get.back();
                successToast('Edits reset');
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      errorToast('Failed to reset: ${e.toString()}');
    }
  }
  Future<void> _loadBackgrounds(String type) async {
    try {
      isLoadingBackgrounds.value = true;
      final dbService = Get.find<KiddyFrameDatabaseService>();
      if (type == 'Color') {
        backgrounds.value = await dbService.database.getBackgroundsByType(
          'color',
        );
      } else if (type == 'Gradient') {
        backgrounds.value = await dbService.database.getBackgroundsByType(
          'gradient',
        );
      } else if (type == 'Image') {
        backgrounds.value = await dbService.database.getBackgroundsByType(
          'image',
        );
      }
      print('📸 Loaded ${backgrounds.length} backgrounds for type: $type');
    } catch (e) {
      backgrounds.clear();
      print('Failed to load backgrounds: ${e.toString()}');
    } finally {
      isLoadingBackgrounds.value = false;
    }
  }
  void selectBackgroundType(int index) {
    selectedBackgroundType.value = index;
    selectedBackgroundIndex.value = -1;
    _loadBackgrounds(backgroundTypes[index]);
  }
  void selectBackground(int index) {
    selectedBackgroundIndex.value = index;
    if (index >= 0) {
      successToast('Background applied');
    }
  }
  Future<void> _loadStickers(String category) async {
    try {
      isLoadingStickers.value = true;
      final dbService = Get.find<KiddyFrameDatabaseService>();
      final categoryId = category.toLowerCase();
      stickers.value = await dbService.database.getStickersByCategory(
        categoryId,
      );
      print('📸 Loaded ${stickers.length} stickers for category: $category');
    } catch (e) {
      stickers.clear();
      print('Failed to load stickers: ${e.toString()}');
    } finally {
      isLoadingStickers.value = false;
    }
  }
  void selectStickerCategory(int index) {
    selectedStickerCategory.value = index;
    _loadStickers(stickerCategories[index]);
  }
  void addSticker(StickerEntity sticker) {
    final newSticker = StickerItem(
      sticker: sticker,
      initialPosition: const Offset(160, 240),
      initialScale: 1.0,
    );
    addedStickers.add(newSticker);
    successToast('Sticker added');
  }
  void removeSticker(int index) {
    if (index >= 0 && index < addedStickers.length) {
      addedStickers.removeAt(index);
    }
  }
  void addText() {
    final newText = TextItem(
      initialContent: 'Text',
      initialColor: Colors.black,
      initialFontSize: 24.0,
      initialPosition: const Offset(160, 240),
    );
    textItems.add(newText);
    selectedTextIndex.value = textItems.length - 1;
    _showTextEditDialog(textItems.length - 1);
  }
  void _showTextEditDialog(int index) {
    if (index < 0 || index >= textItems.length) return;
    final textItem = textItems[index];
    final controller = TextEditingController(text: textItem.content.value);
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: const Color(0xFF4CC9F0), size: 24),
            const SizedBox(width: 8),
            const Text(
              'Edit Text',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Enter your text...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Font Size',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  Obx(
                    () => Text(
                      textItem.fontSize.value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4CC9F0),
                      ),
                    ),
                  ),
                ],
              ),
              Obx(
                () => SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF4CC9F0),
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: const Color(0xFF4CC9F0),
                    overlayColor: const Color(0xFF4CC9F0).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: textItem.fontSize.value,
                    min: 12,
                    max: 72,
                    divisions: 60,
                    onChanged: (value) {
                      textItem.fontSize.value = value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Color',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildColorOption(Colors.black, textItem),
                    _buildColorOption(Colors.white, textItem),
                    _buildColorOption(const Color(0xFF4CC9F0), textItem),
                    _buildColorOption(Colors.red, textItem),
                    _buildColorOption(Colors.orange, textItem),
                    _buildColorOption(Colors.yellow, textItem),
                    _buildColorOption(Colors.green, textItem),
                    _buildColorOption(Colors.blue, textItem),
                    _buildColorOption(Colors.purple, textItem),
                    _buildColorOption(Colors.pink, textItem),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Style',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStyleButton(
                      icon: Icons.format_bold,
                      label: 'Bold',
                      isActive: textItem.isBold.value,
                      onTap: () =>
                          textItem.isBold.value = !textItem.isBold.value,
                    ),
                    _buildStyleButton(
                      icon: Icons.format_italic,
                      label: 'Italic',
                      isActive: textItem.isItalic.value,
                      onTap: () =>
                          textItem.isItalic.value = !textItem.isItalic.value,
                    ),
                    _buildStyleButton(
                      icon: Icons.format_underline,
                      label: 'Underline',
                      isActive: textItem.isUnderline.value,
                      onTap: () => textItem.isUnderline.value =
                          !textItem.isUnderline.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(16),
        actions: [
          TextButton(
            onPressed: () {
              removeText(index);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontSize: 15)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel', style: TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              textItem.content.value = controller.text;
              Get.back();
              successToast('Text updated');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CC9F0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Done', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
  Widget _buildColorOption(Color color, TextItem textItem) {
    final isSelected = textItem.color.value == color;
    return GestureDetector(
      onTap: () => textItem.color.value = color,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF4CC9F0) : Colors.grey[300]!,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CC9F0).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
  Widget _buildStyleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4CC9F0) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF4CC9F0) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  void selectText(int index) {
    selectedTextIndex.value = index;
    _showTextEditDialog(index);
  }
  void removeText(int index) {
    if (index >= 0 && index < textItems.length) {
      textItems.removeAt(index);
      selectedTextIndex.value = -1;
    }
  }
  Future<File> _compositeImage() async {
    try {
      if (previewKey.currentContext == null) {
        throw Exception('Preview context not available');
      }
      final directory = await getApplicationDocumentsDirectory();
      final worksDir = Directory('${directory.path}/works');
      if (!await worksDir.exists()) {
        await worksDir.create(recursive: true);
      }
      final uuid = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${worksDir.path}/work_${timestamp}_$uuid.png';
      final renderObject = previewKey.currentContext!.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw Exception('Preview key is not attached to a RepaintBoundary');
      }
      final boundary = renderObject;
      if (boundary.debugNeedsPaint) {
        print('⚠️ Warning: Boundary needs paint, waiting...');
        await Future.delayed(const Duration(milliseconds: 100));
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('Failed to capture image data');
      }
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(byteData.buffer.asUint8List());
      if (!await outputFile.exists()) {
        throw Exception('Output file was not created');
      }
      final fileSize = await outputFile.length();
      print('📸 Composite image saved: $outputPath (${fileSize} bytes)');
      return outputFile;
    } catch (e) {
      print('❌ Composite image error: ${e.toString()}');
      throw Exception('Failed to composite image: ${e.toString()}');
    }
  }
  Future<void> _saveToDatabase(File file) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }
      final dbService = Get.find<KiddyFrameDatabaseService>();
      final fileSize = await file.length();
      final createdAt = getDateString(DateTime.now());
      String? decorationConfig;
      if (selectedFrameIndex.value > 0 && frames.isNotEmpty) {
        final frame = frames[selectedFrameIndex.value - 1];
        decorationConfig = '{"frame_id":"${frame.frameId}"}';
      }
      final work = WorkEntity(
        filePath: file.path,
        createdAt: createdAt,
        fileSize: fileSize,
        originalPhotoPath: currentPhotoFile.value!.path,
        decorationConfig: decorationConfig,
        studentId: studentId,
      );
      final workId = await dbService.database.insertWork(work);
      if (workId > 0) {
        print('💾 Work saved to database: ID=$workId, studentId=$studentId, path=${file.path}');
      } else {
        throw Exception('Database insert returned invalid ID: $workId');
      }
    } catch (e) {
      print('❌ Database save error: ${e.toString()}');
      throw Exception('Failed to save to database: ${e.toString()}');
    }
  }
  void onPreviousPhoto() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      _loadCurrentPhoto();
    }
  }
  void onNextPhoto() {
    if (currentIndex.value < photos.length - 1) {
      currentIndex.value++;
      _loadCurrentPhoto();
    }
  }
  void onSelectPhoto(int index) {
    if (index >= 0 && index < photos.length) {
      currentIndex.value = index;
      _loadCurrentPhoto();
    }
  }
  Future<void> onBatchFrame() async {
    if (photos.length <= 1) {
      errorToast('Batch processing requires multiple photos');
      return;
    }
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: const Color(0xFF9C27B0), size: 24),
            const SizedBox(width: 8),
            const Text(
              'Batch Process',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply current settings to all ${photos.length} photos?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will apply:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildBatchSettingItem(
              Icons.crop_portrait_outlined,
              'Frame',
              selectedFrameIndex.value == 0
                  ? 'White Border'
                  : frames.isNotEmpty && selectedFrameIndex.value > 0
                      ? frames[selectedFrameIndex.value - 1].name
                      : 'None',
            ),
            _buildBatchSettingItem(
              Icons.palette_outlined,
              'Background',
              selectedBackgroundIndex.value >= 0 &&
                      selectedBackgroundIndex.value < backgrounds.length
                  ? backgrounds[selectedBackgroundIndex.value].name
                  : 'Default',
            ),
            _buildBatchSettingItem(
              Icons.emoji_emotions_outlined,
              'Stickers',
              '${addedStickers.length} sticker(s)',
            ),
            _buildBatchSettingItem(
              Icons.text_fields,
              'Texts',
              '${textItems.length} text(s)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text('Cancel', style: TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C27B0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Process All', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _performBatchProcess();
  }
  Widget _buildBatchSettingItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9C27B0)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _performBatchProcess() async {
    try {
      final processedCount = 0.obs;
      final savedCount = 0.obs;
      final totalCount = photos.length;
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Processing photos...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Column(
                        children: [
                          Text(
                            'Processing: ${processedCount.value}/$totalCount',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saved: ${savedCount.value}/$totalCount',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4CC9F0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      final currentIdx = currentIndex.value;
      final savedFrameIndex = selectedFrameIndex.value;
      final savedBackgroundIndex = selectedBackgroundIndex.value;
      final savedStickers = List<StickerItem>.from(addedStickers);
      final savedTexts = List<TextItem>.from(textItems);
      final savedImageScale = imageScale.value;
      final savedImageOffset = imageOffset.value;
      print('🚀 Starting batch process for $totalCount photos...');
      for (int i = 0; i < photos.length; i++) {
        try {
          processedCount.value = i + 1;
          print('📷 Processing photo ${i + 1}/$totalCount...');
          currentIndex.value = i;
          await _loadCurrentPhoto();
          await Future.delayed(const Duration(milliseconds: 300));
          selectedFrameIndex.value = savedFrameIndex;
          selectedBackgroundIndex.value = savedBackgroundIndex;
          addedStickers.clear();
          for (final sticker in savedStickers) {
            addedStickers.add(
              StickerItem(
                sticker: sticker.sticker,
                initialPosition: sticker.position.value,
                initialScale: sticker.scale.value,
                initialRotation: sticker.rotation.value,
              ),
            );
          }
          textItems.clear();
          for (final text in savedTexts) {
            textItems.add(
              TextItem(
                initialContent: text.content.value,
                initialColor: text.color.value,
                initialFontSize: text.fontSize.value,
                initialPosition: text.position.value,
                initialRotation: text.rotation.value,
                initialFontFamily: text.fontFamily.value,
                initialIsBold: text.isBold.value,
                initialIsItalic: text.isItalic.value,
                initialIsUnderline: text.isUnderline.value,
              ),
            );
          }
          imageScale.value = savedImageScale;
          imageOffset.value = savedImageOffset;
          await Future.delayed(const Duration(milliseconds: 500));
          final compositeFile = await _compositeImage();
          await _saveToDatabase(compositeFile);
          savedCount.value = i + 1;
          print('✅ Successfully processed and saved photo ${i + 1}/$totalCount');
        } catch (e) {
          print('❌ Failed to process photo ${i + 1}: ${e.toString()}');
          continue;
        }
      }
      currentIndex.value = currentIdx;
      await _loadCurrentPhoto();
      Get.back();
      final actualSaved = savedCount.value;
      if (actualSaved == totalCount) {
        successToast('Successfully saved all $actualSaved photo(s)');
      } else {
        successToast('Successfully saved $actualSaved out of $totalCount photo(s)');
      }
      print('🎉 Batch process completed: $actualSaved/$totalCount photos saved');
      await Future.delayed(const Duration(milliseconds: 500));
      if (studentId != null) {
        int routeCount = 0;
        Get.until((route) {
          routeCount++;
          return routeCount >= 3;
        });
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
      errorToast('Batch process failed: ${e.toString()}');
      print('❌ Batch process error: ${e.toString()}');
    }
  }
  Future<void> loadPresetList() async {
    try {
      isLoadingPresets.value = true;
      final dbService = Get.find<KiddyFrameDatabaseService>();
      final presets = await dbService.database.getPresets(orderBy: 'usage_count DESC');
      availablePresets.value = presets;
    } catch (e) {
      errorToast('Failed to load presets: $e');
    } finally {
      isLoadingPresets.value = false;
    }
  }
  Future<void> saveAsPreset({
    required String name,
    String? description,
  }) async {
    try {
      if (frames.isEmpty && addedStickers.isEmpty && textItems.isEmpty) {
        errorToast('Nothing to save. Add some frames, stickers or text first.');
        return;
      }
      final config = _extractCurrentConfig();
      final presetId = const Uuid().v4();
      final now = DateTime.now().toIso8601String();
      String? thumbnailPath;
      try {
        final thumbnail = await _captureThumbnail();
        if (thumbnail != null) {
          final dir = await getApplicationDocumentsDirectory();
          final thumbDir = Directory('${dir.path}/preset_thumbnails');
          if (!await thumbDir.exists()) {
            await thumbDir.create(recursive: true);
          }
          thumbnailPath = '${thumbDir.path}/preset_$presetId.png';
          await File(thumbnailPath).writeAsBytes(thumbnail);
        }
      } catch (e) {
        print('Failed to generate thumbnail: $e');
      }
      final preset = FramingPresetEntity(
        presetId: presetId,
        name: name,
        description: description,
        thumbnailPath: thumbnailPath,
        configJson: jsonEncode(config),
        usageCount: 0,
        createdAt: now,
        updatedAt: now,
        isDefault: 0,
      );
      final dbService = Get.find<KiddyFrameDatabaseService>();
      final result = await dbService.database.insertPreset(preset);
      if (result > 0) {
        successToast('Preset saved successfully');
      } else {
        errorToast('Failed to save preset');
      }
    } catch (e) {
      errorToast('Error saving preset: $e');
    }
  }
  Map<String, dynamic> _extractCurrentConfig() {
    final config = <String, dynamic>{};
    if (selectedFrameIndex.value > 0 && frames.isNotEmpty) {
      final frame = frames[selectedFrameIndex.value - 1];
      config['frame'] = {
        'frameId': frame.frameId,
        'frameName': frame.name,
        'scale': 100,
      };
    }
    if (selectedBackgroundIndex.value >= 0 && backgrounds.isNotEmpty) {
      final bg = backgrounds[selectedBackgroundIndex.value];
      config['background'] = {
        'type': bg.type,
        'value': bg.colorValue ?? bg.filePath ?? '',
        'backgroundId': bg.backgroundId,
      };
    } else {
      config['background'] = {
        'type': 'color',
        'value': '#FFFFFF',
      };
    }
    final texts = textItems.map((textItem) {
      return {
        'content': textItem.content.value,
        'fontFamily': textItem.fontFamily.value,
        'fontSize': textItem.fontSize.value,
        'color': '#${textItem.color.value.value.toRadixString(16).padLeft(8, '0')}',
        'x': textItem.position.value.dx / cropBoxWidth,
        'y': textItem.position.value.dy / cropBoxHeight,
        'rotation': textItem.rotation.value,
        'isBold': textItem.isBold.value,
        'isItalic': textItem.isItalic.value,
        'isUnderline': textItem.isUnderline.value,
      };
    }).toList();
    config['texts'] = texts;
    final stickers = addedStickers.map((stickerItem) {
      return {
        'stickerId': stickerItem.sticker.stickerId,
        'x': stickerItem.position.value.dx / cropBoxWidth,
        'y': stickerItem.position.value.dy / cropBoxHeight,
        'scale': stickerItem.scale.value,
        'rotation': stickerItem.rotation.value,
      };
    }).toList();
    config['stickers'] = stickers;
    return config;
  }
  Future<void> applyPreset(FramingPresetEntity preset) async {
    try {
      final config = jsonDecode(preset.configJson) as Map<String, dynamic>;
      if (config.containsKey('frame')) {
        final frameConfig = config['frame'] as Map<String, dynamic>;
        final frameId = frameConfig['frameId'] as String;
        await _loadFrames(frameCategories[selectedFrameCategory.value]);
        final frameIndex = frames.indexWhere((f) => f.frameId == frameId);
        if (frameIndex >= 0) {
          selectedFrameIndex.value = frameIndex + 1;
        }
      }
      if (config.containsKey('background')) {
      }
      if (config.containsKey('texts')) {
        textItems.clear();
        final textsConfig = config['texts'] as List;
        for (final textConfig in textsConfig) {
          final text = textConfig as Map<String, dynamic>;
          final colorHex = text['color'] as String;
          final colorInt = int.parse(colorHex.replaceAll('#', ''), radix: 16);
          textItems.add(TextItem(
            initialContent: text['content'] as String,
            initialColor: Color(colorInt),
            initialFontSize: (text['fontSize'] as num).toDouble(),
            initialPosition: Offset(
              (text['x'] as num).toDouble() * cropBoxWidth,
              (text['y'] as num).toDouble() * cropBoxHeight,
            ),
            initialRotation: (text['rotation'] as num).toDouble(),
            initialFontFamily: text['fontFamily'] as String,
            initialIsBold: text['isBold'] as bool? ?? false,
            initialIsItalic: text['isItalic'] as bool? ?? false,
            initialIsUnderline: text['isUnderline'] as bool? ?? false,
          ));
        }
      }
      if (config.containsKey('stickers')) {
        addedStickers.clear();
      }
      final dbService = Get.find<KiddyFrameDatabaseService>();
      await dbService.database.incrementPresetUsage(preset.presetId);
      successToast('Preset applied');
    } catch (e) {
      errorToast('Failed to apply preset: $e');
    }
  }
  Future<Uint8List?> _captureThumbnail() async {
    try {
      final boundary = previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 0.5);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing thumbnail: $e');
      return null;
    }
  }
}
