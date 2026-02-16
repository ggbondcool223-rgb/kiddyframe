import 'package:get/get.dart';
import 'kiddy_frame_student_management_logic.dart';
class KiddyFrameStudentManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KiddyFrameStudentManagementLogic());
  }
}
