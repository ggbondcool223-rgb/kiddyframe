import 'package:get/get.dart';
import 'kiddy_frame_photo_select_logic.dart';
class KiddyFramePhotoSelectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFramePhotoSelectLogic());
  }
}
