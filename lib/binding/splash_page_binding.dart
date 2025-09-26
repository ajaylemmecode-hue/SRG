import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/splash_page_controller.dart';
import '../controller/home_page_controller.dart';
import '../controller/cart_controller.dart';

class SplashPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashPageController>(() => SplashPageController(),);
  }
}
