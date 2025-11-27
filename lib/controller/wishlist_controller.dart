// ✅ lib/controller/wishlist_controller.dart - COMPLETE FIXED VERSION

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';
import 'user_controller.dart';

class WishlistController extends GetxController {
  var wishlistItems = <Map<String, dynamic>>[].obs;
  var wishlistCount = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<UserController>().isLoggedIn, (isLoggedIn) {
      if (isLoggedIn) {
        loadWishlist();
      } else {
        clearWishlist();
      }
    });
  }

  /// Get authentication token
  String get _token {
    try {
      final userCtrl = Get.find<UserController>();
      return userCtrl.token.value;
    } catch (e) {
      return '';
    }
  }

  /// Check if user is logged in
  bool get _isLoggedIn {
    try {
      final userCtrl = Get.find<UserController>();
      return userCtrl.isLoggedIn.value;
    } catch (e) {
      return false;
    }
  }

  /// ✅ Clear wishlist data (with API call)
  void clearWishlist() {
    wishlistItems.clear();
    wishlistCount.value = 0;
    update();
  }

  /// ✅ Clear local wishlist (without API call) - FOR LOGIN CONTROLLER
  void clearLocalWishlist() {
    wishlistItems.clear();
    wishlistCount.value = 0;
    update();
    if (kDebugMode) print("🗑️ Local wishlist cleared");
  }

  /// ✅ Add product to wishlist
  Future<void> addToWishlist(int productId) async {
    if (!_isLoggedIn || _token.isEmpty) {
      Get.snackbar(
        "Login Required",
        "Please log in to add items to wishlist",
        backgroundColor: Colors.orange.shade100,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      if (kDebugMode) print("❤️ Adding product $productId to wishlist...");

      final response = await ApiService.addToWishlist(productId, _token);

      if (response['status'] == true) {
        await loadWishlist();
        update();

        Get.snackbar(
          "Success",
          "Added to wishlist!",
          backgroundColor: Colors.green.shade100,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        );

        if (kDebugMode) print("✅ Added to wishlist successfully");
      }
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print("❌ Add to wishlist error: $errorMessage");

      Get.snackbar(
        "Wishlist Error",
        errorMessage,
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// ✅ Remove product from wishlist
  Future<void> removeFromWishlist(int productId) async {
    if (!_isLoggedIn || _token.isEmpty) {
      return;
    }

    try {
      if (kDebugMode) print("💔 Removing product $productId from wishlist...");

      await ApiService.removeFromWishlist(productId, _token);

      wishlistItems.removeWhere((item) => item['id'] == productId);
      wishlistCount.value = wishlistItems.length;
      update();

      Get.snackbar(
        "Success",
        "Removed from wishlist!",
        backgroundColor: Colors.green.shade100,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );

      if (kDebugMode) print("✅ Removed from wishlist successfully");
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) print("❌ Remove from wishlist error: $errorMessage");

      Get.snackbar(
        "Error",
        errorMessage,
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// ✅ Check if product is in wishlist (API call)
  Future<bool> isInWishlist(int productId) async {
    if (!_isLoggedIn || _token.isEmpty) {
      return false;
    }

    try {
      final response = await ApiService.checkWishlist(productId, _token);
      return response['data']?['in_wishlist'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// ✅ Load all wishlist items
  Future<void> loadWishlist() async {
    if (!_isLoggedIn || _token.isEmpty) {
      clearWishlist();
      return;
    }

    try {
      isLoading.value = true;
      if (kDebugMode) print("📡 Loading wishlist...");

      final response = await ApiService.getWishlist(_token);

      if (response['status'] == true && response['data'] != null) {
        List<Map<String, dynamic>> items = [];

        if (response['data'] is List) {
          items = (response['data'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        } else if (response['data'] is Map) {
          final data = response['data'] as Map<String, dynamic>;

          if (data.containsKey('wishlist_items')) {
            final wishlistData = data['wishlist_items'];
            if (wishlistData is List) {
              items = wishlistData
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
            }
          } else if (data.containsKey('items')) {
            final wishlistData = data['items'];
            if (wishlistData is List) {
              items = wishlistData
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
            }
          }
        }

        wishlistItems.assignAll(items);
        wishlistCount.value = wishlistItems.length;
        update();

        if (kDebugMode) print("✅ Wishlist loaded: ${wishlistItems.length} items");
      } else {
        clearWishlist();
      }
    } catch (e) {
      if (!e.toString().contains('Unauthorized')) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        if (kDebugMode) print("❌ Load wishlist error: $errorMessage");
      }
      clearWishlist();
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Update wishlist count only
  Future<void> updateWishlistCount() async {
    if (!_isLoggedIn || _token.isEmpty) {
      wishlistCount.value = 0;
      return;
    }

    try {
      final response = await ApiService.getWishlistCount(_token);
      final count = response['data']?['wishlist_count'] ??
          response['data']?['count'] ??
          0;
      wishlistCount.value = count is int ? count : int.tryParse(count.toString()) ?? 0;

      if (kDebugMode) print("📊 Wishlist count: ${wishlistCount.value}");
    } catch (e) {
      wishlistCount.value = 0;
      if (kDebugMode) print("⚠️ Failed to get wishlist count: $e");
    }
  }

  /// ✅ Toggle wishlist status for a product
  Future<void> toggleWishlist(int productId) async {
    if (!_isLoggedIn || _token.isEmpty) {
      Get.snackbar(
        "Login Required",
        "Please log in to use wishlist",
        backgroundColor: Colors.orange.shade100,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final isIn = isItemInWishlist(productId);

    if (isIn) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }

  /// ✅ Check if item exists in local wishlist (no API call - fast)
  bool isItemInWishlist(int productId) {
    return wishlistItems.any((item) {
      final itemId = item['id'] ?? item['product_id'];
      return itemId == productId;
    });
  }

  /// ✅ Refresh wishlist
  Future<void> refreshWishlist() async {
    if (kDebugMode) print("🔄 Refreshing wishlist...");
    await loadWishlist();
  }
}