import 'package:get/get.dart';
import 'kiddy_frame_home_logic.dart';
class KiddyFrameHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFrameHomeLogic());
  }
}
