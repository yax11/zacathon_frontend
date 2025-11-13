import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../zai/controllers/zai_controller.dart';
import '../../overview/controllers/overview_controller.dart';
import '../../../data/services/tts/google_tts_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    // Initialize TTS service for AI responses
    if (!Get.isRegistered<GoogleTtsService>()) {
      Get.put(GoogleTtsService(), permanent: true);
    }
    // Initialize ZaiController eagerly since IndexedStack creates all views immediately
    // Use put instead of lazyPut to ensure it's available when ZaiView is created
    if (!Get.isRegistered<ZaiController>()) {
      Get.put(ZaiController(), permanent: false);
    }
    // Initialize OverviewController to load user data
    if (!Get.isRegistered<OverviewController>()) {
      Get.put(OverviewController(), permanent: false);
    }
  }
}

