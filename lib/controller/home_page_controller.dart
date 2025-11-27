import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class HomePageController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;
  final RxList<Map<String, dynamic>> allServices = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final Rx<Map<String, dynamic>> billingData = Rx<Map<String, dynamic>>({});
  final RxInt currentIndex = 0.obs;

  bool _isFetching = false;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();

    debounce(
      searchQuery,
          (_) => _performSearch(),
      time: const Duration(milliseconds: 500),
    );
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (kDebugMode) print("📍 Changed to tab: $index");
  }

  /// ✅ FETCH HOME DATA - GETS CLEANING_PRODUCTS
  Future<void> fetchHomeData() async {
    if (_isFetching) {
      if (kDebugMode) print("⚠️ Already fetching home data, skipping...");
      return;
    }

    try {
      _isFetching = true;
      isLoading.value = true;
      errorMsg.value = '';

      if (kDebugMode) print("📡 Fetching home data from /home endpoint...");

      // ✅ CALL HOME API
      final response = await ApiService.fetchHomeData();

      if (kDebugMode) {
        print("✅ Home API Response Status: ${response['status']}");
        print("📦 Response Message: ${response['message']}");
      }

      // ✅ CHECK IF RESPONSE IS SUCCESSFUL
      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        if (kDebugMode) {
          print("📊 Data Keys: ${(data as Map).keys.toList()}");
        }

        // ✅ EXTRACT cleaning_products ARRAY FROM RESPONSE
        List<dynamic> productsList = [];

        if (data is Map && data.containsKey('cleaning_products')) {
          productsList = data['cleaning_products'] as List? ?? [];
          if (kDebugMode) {
            print("✅ Found cleaning_products array: ${productsList.length} products");
          }
        } else {
          if (kDebugMode) print("⚠️ cleaning_products not found in response");
          allServices.clear();
          errorMsg.value = 'No cleaning products found';
          isLoading.value = false;
          _isFetching = false;
          return;
        }

        // ✅ VALIDATE AND TRANSFORM EACH PRODUCT
        if (productsList.isNotEmpty) {
          final validProducts = <Map<String, dynamic>>[];

          for (int i = 0; i < productsList.length; i++) {
            final item = productsList[i];

            // ✅ NULL CHECK
            if (item == null) {
              if (kDebugMode) print("⚠️ Product $i is null, skipping");
              continue;
            }

            // ✅ EXTRACT FIELDS
            final productId = item['id'];
            final title = item['title'];
            final price = item['price'];
            final comparePrice = item['compare_price'];
            final imageUrl = item['image_url'];

            // ✅ VALIDATE REQUIRED FIELDS
            if (productId == null || productId == 0) {
              if (kDebugMode) print("⚠️ Product $i: Missing ID");
              continue;
            }

            if (title == null || title.toString().isEmpty) {
              if (kDebugMode) print("⚠️ Product $productId: Missing title");
              continue;
            }

            // ✅ BUILD CLEAN PRODUCT MAP
            final product = <String, dynamic>{
              'id': productId,
              'title': title.toString().trim(),
              'price': _parseDouble(price),
              'compare_price': _parseDouble(comparePrice),
              'image_url': imageUrl?.toString() ?? '',
              'short_description': (item['short_description'] ?? '').toString(),
              'description': (item['description'] ?? '').toString(),
              'category_id': item['category_id'] ?? 1,
              'sub_category_id': item['sub_category_id'],
              'status': item['status'] ?? 1,
              'in_wishlist': item['in_wishlist'] ?? false,
              'created_at': item['created_at']?.toString(),
            };

            validProducts.add(product);

            if (kDebugMode && i == 0) {
              print("✅ Product $productId:");
              print("   - Title: ${product['title']}");
              print("   - Price: ₹${product['price']}");
              print("   - Image: ${product['image_url']}");
            }
          }

          // ✅ UPDATE allServices WITH VALID PRODUCTS
          allServices.assignAll(validProducts);

          if (kDebugMode) {
            print("✅ Successfully loaded ${validProducts.length} products");
            print("📊 Total products in allServices: ${allServices.length}");
          }

          // ✅ CLEAR ERROR IF PRODUCTS LOADED
          if (validProducts.isNotEmpty) {
            errorMsg.value = '';
          } else {
            errorMsg.value = 'No valid products found';
          }
        } else {
          if (kDebugMode) print("❌ cleaning_products array is empty");
          allServices.clear();
          errorMsg.value = 'No products available';
        }
      } else {
        allServices.clear();
        errorMsg.value = response['message'] ?? 'Failed to fetch home data';
        if (kDebugMode) {
          print("❌ Response Status: ${response['status']}");
          print("❌ Error: ${response['message']}");
        }
      }
    } catch (e) {
      allServices.clear();
      errorMsg.value = e.toString().replaceAll('Exception: ', '').trim();
      if (kDebugMode) print("❌ Exception in fetchHomeData: $e");
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  /// ✅ REFRESH HOME DATA
  Future<void> refreshHomeData() async {
    allServices.clear();
    errorMsg.value = '';
    await Future.delayed(const Duration(milliseconds: 300));
    await fetchHomeData();
  }

  /// ✅ UPDATE SEARCH QUERY
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// ✅ PERFORM LOCAL SEARCH ON LOADED PRODUCTS
  Future<void> _performSearch() async {
    final query = searchQuery.value.trim();

    if (query.isEmpty) {
      await fetchHomeData();
      return;
    }

    if (query.length < 1) {
      return;
    }

    try {
      isSearching.value = true;
      if (kDebugMode) print("🔍 Searching locally for: '$query'");

      // ✅ SEARCH IN ALREADY LOADED PRODUCTS
      final searchResults = allServices.where((service) {
        final title = service['title']?.toString().toLowerCase() ?? '';
        final desc = service['short_description']?.toString().toLowerCase() ?? '';
        final category = service['category_id']?.toString() ?? '';

        return title.contains(query.toLowerCase()) ||
            desc.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase());
      }).toList();

      if (kDebugMode) {
        print("✅ Search Results: ${searchResults.length} items found");
      }

      // ✅ UPDATE DISPLAY
      allServices.assignAll(searchResults);
    } catch (e) {
      if (kDebugMode) print("❌ Search error: $e");
      await fetchHomeData();
    } finally {
      isSearching.value = false;
    }
  }

  /// ✅ CLEAR SEARCH
  void clearSearch() {
    searchQuery.value = '';
    fetchHomeData();
  }

  /// ✅ PARSE DOUBLE SAFELY
  double _parseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// ✅ GET FILTERED SERVICES (FOR UI)
  List<Map<String, dynamic>> get filteredServices {
    return allServices.toList();
  }

  /// ✅ GO TO BILLING
  void goToBilling(Map<String, dynamic> data) {
    billingData.value = data;
    if (kDebugMode) print("💳 Navigating to billing");
  }
}