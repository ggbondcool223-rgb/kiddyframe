import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'kiddy_frame_mind_logic.dart';

class KiddyFrameMindView extends GetView<KiddyFrameMindLogic> {
  const KiddyFrameMindView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => controller.jfap.value
              ? const CircularProgressIndicator(color: Colors.orangeAccent)
              : buildError(),
        ),
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              controller.dbxjwyh();
            },
            icon: const Icon(
              Icons.restart_alt,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}
