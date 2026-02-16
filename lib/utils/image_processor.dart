import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
class ImageProcessor {
  static Future<Map<String, dynamic>?> getImageInfo(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final fileSize = await imageFile.length();
      return {
        'width': image.width,
        'height': image.height,
        'sizeKB': fileSize / 1024,
      };
    } catch (e) {
      print('Error getting image info: $e');
      return null;
    }
  }
  static Future<File?> rotateImage({
    required File imageFile,
    required int angle,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return null;
      switch (angle) {
        case 90:
          image = img.copyRotate(image, angle: 90);
          break;
        case 180:
          image = img.copyRotate(image, angle: 180);
          break;
        case 270:
          image = img.copyRotate(image, angle: 270);
          break;
        case -90:
          image = img.copyRotate(image, angle: -90);
          break;
      }
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFile = File('${tempDir.path}/rotated_$timestamp.jpg');
      final encodedImage = img.encodeJpg(image, quality: 95);
      await outputFile.writeAsBytes(encodedImage);
      return outputFile;
    } catch (e) {
      print('Error rotating image: $e');
      return null;
    }
  }
  static Future<File?> flipImage({
    required File imageFile,
    required bool horizontal,
    bool vertical = false,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) return null;
      if (horizontal) {
        image = img.flipHorizontal(image);
      }
      if (vertical) {
        image = img.flipVertical(image);
      }
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFile = File('${tempDir.path}/flipped_$timestamp.jpg');
      final encodedImage = img.encodeJpg(image, quality: 95);
      await outputFile.writeAsBytes(encodedImage);
      return outputFile;
    } catch (e) {
      print('Error flipping image: $e');
      return null;
    }
  }
  static Future<File?> cropImage({
    required File imageFile,
    required int x,
    required int y,
    required int width,
    required int height,
    int quality = 90,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final cropX = x.clamp(0, image.width);
      final cropY = y.clamp(0, image.height);
      final cropWidth = width.clamp(1, image.width - cropX);
      final cropHeight = height.clamp(1, image.height - cropY);
      final croppedImage = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFile = File('${tempDir.path}/cropped_$timestamp.jpg');
      final encodedImage = img.encodeJpg(croppedImage, quality: quality);
      await outputFile.writeAsBytes(encodedImage);
      return outputFile;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }
  static Future<File?> resizeImage({
    required File imageFile,
    required int width,
    required int height,
    int quality = 90,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;
      final resizedImage = img.copyResize(
        image,
        width: width,
        height: height,
      );
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFile = File('${tempDir.path}/resized_$timestamp.jpg');
      final encodedImage = img.encodeJpg(resizedImage, quality: quality);
      await outputFile.writeAsBytes(encodedImage);
      return outputFile;
    } catch (e) {
      print('Error resizing image: $e');
      return null;
    }
  }
  static Future<File?> saveImage({
    required File imageFile,
    required int width,
    required int height,
    String extension = 'jpg',
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final worksDir = Directory('${appDir.path}/works');
      if (!await worksDir.exists()) {
        await worksDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = '${worksDir.path}/work_$timestamp.$extension';
      final outputFile = await imageFile.copy(outputPath);
      return outputFile;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}
