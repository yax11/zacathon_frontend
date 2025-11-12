import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../zai/controllers/zai_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    // Initialize ZaiController eagerly since IndexedStack creates all views immediately
    // Use put instead of lazyPut to ensure it's available when ZaiView is created
    if (!Get.isRegistered<ZaiController>()) {
      Get.put(ZaiController(), permanent: false);
    }
  }
}

