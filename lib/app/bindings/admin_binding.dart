import 'package:get/get.dart';
import '../../presentation/controllers/admin_controller.dart';
import '../../presentation/controllers/order_controller.dart';
import '../../presentation/controllers/user_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminController());
    Get.lazyPut(() => OrderController());
    Get.lazyPut<UserController>(() => UserController());
  }
}
