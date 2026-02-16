import 'package:get/get.dart';
import 'kiddy_frame_photo_preprocess_logic.dart';
class KiddyFramePhotoPreprocessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFramePhotoPreprocessLogic());
  }
}
