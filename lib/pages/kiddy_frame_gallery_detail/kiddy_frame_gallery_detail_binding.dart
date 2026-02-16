import 'package:get/get.dart';
import 'kiddy_frame_gallery_detail_logic.dart';
class KiddyFrameGalleryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFrameGalleryDetailLogic());
  }
}
