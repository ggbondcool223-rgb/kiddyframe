import 'package:get/get.dart';
import 'kiddy_frame_student_detail_logic.dart';
class KiddyFrameStudentDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFrameStudentDetailLogic());
  }
}
