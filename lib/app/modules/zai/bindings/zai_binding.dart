import 'package:get/get.dart';
import '../controllers/zai_controller.dart';

class ZaiBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure controller exists when navigating directly to zAI route
    if (!Get.isRegistered<ZaiController>()) {
      Get.put(ZaiController(), permanent: false);
    }
  }
}
