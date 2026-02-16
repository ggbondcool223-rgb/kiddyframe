import 'package:get/get.dart';

import 'kiddy_frame_mind_logic.dart';

class KiddyFrameMindBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      KiddyFrameMindLogic(),
      permanent: true,
    );
  }
}
