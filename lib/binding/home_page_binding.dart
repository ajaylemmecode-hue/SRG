import 'package:get/get.dart';
import '../controller/home_page_controller.dart';
import '../controller/cart_controller.dart';
import '../controller/booking_controller.dart';
import '../controller/wishlist_controller.dart';

class HomePageBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ Register only page-related controllers
    Get.put(HomePageController());
    Get.put(CartController());
    Get.put(BookingController());
    Get.put(WishlistController());
  }
}
