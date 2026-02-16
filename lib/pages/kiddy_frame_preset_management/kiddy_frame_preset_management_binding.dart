import 'package:get/get.dart';
import 'kiddy_frame_preset_management_logic.dart';
class KiddyFramePresetManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFramePresetManagementLogic());
  }
}
