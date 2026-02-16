import 'package:get/get.dart';
import 'kiddy_frame_work_compare_logic.dart';
class KiddyFrameWorkCompareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFrameWorkCompareLogic());
  }
}
