import 'package:get/get.dart';
import '../controllers/transfer_controller.dart';

class TransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TransferController>(TransferController(), permanent: false);
  }
}

