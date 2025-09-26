import 'package:get/get.dart';
import '../api/api_service.dart';

class HomePageController extends GetxController {
  var isLoading = false.obs;
  var errorMsg = "".obs;

  // data from API
  var cleaningProducts = [].obs;
  var furnitureProducts = [].obs;
  var allServices = [].obs; // you can merge or keep separately

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      isLoading.value = true;
      errorMsg.value = "";
      final jsonData = await ApiService.fetchHomeData();

      cleaningProducts.assignAll(jsonData['data']['cleaning_products'] ?? []);
      furnitureProducts.assignAll(jsonData['data']['furniture_products'] ?? []);

      // optional: merge all into one list
      allServices.assignAll([
        ...cleaningProducts,
        ...furnitureProducts,
      ]);
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
