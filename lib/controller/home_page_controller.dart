import 'package:get/get.dart';

class HomePageController extends GetxController {
  // 🔹 Bottom nav index
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  // 🔹 Billing data state
  var billingData = <String, dynamic>{
    "selectedFlat": "",
    "unitPrice": 0,
    "quantity": 1,
    "items": [],
    "totalAmount": 0.0,
  }.obs;

  // 🔹 Search state
  var isSearching = false.obs;
  var searchQuery = "".obs;

  void startSearch() {
    isSearching.value = true;
    searchQuery.value = "";
  }

  void stopSearch() {
    isSearching.value = false;
    searchQuery.value = "";
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }
}
