import 'package:get/get.dart';
import 'kiddy_frame_settings_logic.dart';
class KiddyFrameSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFrameSettingsLogic());
  }
}
