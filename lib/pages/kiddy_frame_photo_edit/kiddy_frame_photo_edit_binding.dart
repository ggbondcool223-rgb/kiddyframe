import 'package:get/get.dart';
import 'kiddy_frame_photo_edit_logic.dart';
class KiddyFramePhotoEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFramePhotoEditLogic());
  }
}
