import 'package:get/get.dart';
import '../controller/home_page_controller.dart';
import '../controller/cart_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HomePageController());
    Get.put(CartController()); // ✅ added
  }
}
