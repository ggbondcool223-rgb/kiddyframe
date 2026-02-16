import 'package:get/get.dart';
import 'kiddy_frame_preset_preview_logic.dart';
class KiddyFramePresetPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFramePresetPreviewLogic());
  }
}
