// ✅ lib/controller/cart_controller.dart - COMPLETE FIXED VERSION

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/api/api_service.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';

class CartController extends GetxController {
  final RxList<Map<String, dynamic>> cartItems = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxInt totalItemsCount = 0.obs;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();
    if (userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty) {
      loadCart();
    }
    ever(userCtrl.isLoggedIn, (isLoggedIn) {
      if (isLoggedIn && userCtrl.token.value.isNotEmpty) {
        loadCart();
      } else {
        clearLocalCart();
      }
    });
  }

  String _normalizeImageUrl(dynamic rawImage) {
    if (rawImage == null || rawImage.toString().trim().isEmpty) {
      return 'https://via.placeholder.com/100?text=No+Image';
    }
    String url = rawImage.toString().trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://portfolio2.lemmecode.in/$url';
  }

  /// ✅ LOAD CART FROM API
  Future<void> loadCart() async {
    if (!userCtrl.isLoggedIn.value) {
      if (kDebugMode) print("❌ User not logged in");
      return;
    }
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final token = userCtrl.token.value;

      if (token.isEmpty) {
        if (kDebugMode) print("❌ Token is empty!");
        throw Exception('No authentication token');
      }

      if (kDebugMode) {
        print("📡 API: GET /cart");
        print("   Token: ${token.substring(0, 20)}...");
      }
      final response = await ApiService.getCart(token);

      if (kDebugMode) {
        print("✅ Cart API Response: ${response.toString()}");
      }

      final data = response['data'];
      List<dynamic> items = [];

      if (data is Map) {
        if (data.containsKey('cart_items')) {
          items = List.from(data['cart_items'] ?? []);
        } else if (data.containsKey('items')) {
          items = List.from(data['items'] ?? []);
        } else if (data.containsKey('cart')) {
          final cartData = data['cart'];
          if (cartData is List) {
            items = cartData;
          } else if (cartData is Map && cartData.containsKey('items')) {
            items = List.from(cartData['items'] ?? []);
          }
        }
      } else if (data is List) {
        items = data;
      }

      if (kDebugMode) print("📦 Found ${items.length} items in cart");

      final validCartItems = <Map<String, dynamic>>[];
      for (var item in items) {
        if (item != null && item is Map) {
          try {
            final rowId = item['row_id'] ?? item['rowId'] ?? item['id'];
            final productId = item['product_id'] ?? item['productId'] ?? item['id'];
            final productName = item['product_name'] ?? item['name'] ?? item['title'] ?? 'Unknown';
            final price = _parseDouble(item['price']);
            final quantity = item['qty'] ?? item['quantity'] ?? 1;
            final imageUrl = item['product_image'] ?? item['image'] ?? item['image_url'];
            final subtotal = _parseDouble(item['subtotal'] ?? (price * (quantity is int ? quantity : int.tryParse(quantity.toString()) ?? 1)));

            final product = {
              'row_id': rowId?.toString() ?? '',
              'id': productId is int ? productId : int.tryParse(productId.toString()) ?? 0,
              'title': productName.toString().trim(),
              'price': price,
              'quantity': quantity is int ? quantity : int.tryParse(quantity.toString()) ?? 1,
              'image': _normalizeImageUrl(imageUrl),
              'subtotal': subtotal,
            };

            if (product['id'] != null && product['id'] != 0) {
              validCartItems.add(product);
              if (kDebugMode) print("   ✅ Added: ${product['title']} x ${product['quantity']}");
            }
          } catch (e) {
            if (kDebugMode) print("⚠️ Error parsing item: $e");
          }
        }
      }

      cartItems.assignAll(validCartItems);
      _calculateTotals();

      if (kDebugMode) {
        print("✅ Cart loaded: ${validCartItems.length} items");
        print("   Total Amount: ₹${totalAmount.value}");
        print("   Total Items: ${totalItemsCount.value}");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Load cart error: $e");
      errorMsg.value = e.toString().replaceAll('Exception: ', '');
      cartItems.clear();
      _calculateTotals();
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ ADD TO CART - FIXED
  Future<void> addToCart(Map<String, dynamic> service, {int qty = 1}) async {
    final id = service['id'] ?? service['product_id'];
    if (kDebugMode) print("🛒 addToCart called - ID: $id, Qty: $qty");

    if (id == null || id == 0) throw Exception("Invalid product ID");
    if (!userCtrl.isLoggedIn.value || userCtrl.token.value.isEmpty) {
      throw Exception("Please login to add items to cart");
    }

    try {
      isLoading.value = true;
      final token = userCtrl.token.value;

      if (kDebugMode) print("📡 API: POST /cart/add - Product: $id, Qty: $qty");

      final response = await ApiService.addToCart(
          token: token,
          productId: id as int,
          quantity: qty
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (kDebugMode) print("✅ Add to cart response: ${response['message']}");

      // Wait a bit for server to process
      await Future.delayed(const Duration(milliseconds: 500));

      // Reload cart to get updated data
      await loadCart();

      if (kDebugMode) print("✅ Cart reloaded after add");

    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('SocketException')) {
        errorMessage = 'No internet connection';
      }
      if (kDebugMode) print("❌ Error in addToCart: $errorMessage");
      throw Exception(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ REMOVE FROM CART
  Future<void> removeFromCart(String rowId) async {
    if (!userCtrl.isLoggedIn.value || rowId.isEmpty) return;
    try {
      isLoading.value = true;
      final token = userCtrl.token.value;
      if (kDebugMode) print("📡 Removing item: $rowId");

      await ApiService.removeFromCart(token: token, rowId: rowId);
      await loadCart();

      Get.snackbar(
          "Removed",
          "Item removed from cart",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900],
          duration: const Duration(seconds: 2)
      );
    } catch (e) {
      if (kDebugMode) print("❌ Remove error: $e");
      Get.snackbar(
          "Error",
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900]
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ UPDATE CART QUANTITY - NEW METHOD
  Future<void> updateQuantity(String rowId, int newQty) async {
    if (rowId.isEmpty || newQty < 0) return;

    int index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
    if (index < 0) return;

    final product = Map<String, dynamic>.from(cartItems[index]);

    if (newQty == 0) {
      await removeFromCart(rowId);
      return;
    }

    try {
      isLoading.value = true;
      final token = userCtrl.token.value;

      if (kDebugMode) print("📡 Updating qty for ${product['title']}: ${product['quantity']} → $newQty");

      // First remove the item, then add with new quantity
      await ApiService.removeFromCart(token: token, rowId: rowId);
      await ApiService.addToCart(
          token: token,
          productId: product['id'] as int,
          quantity: newQty
      );

      await loadCart();
    } catch (e) {
      if (kDebugMode) print("❌ Update qty error: $e");
      Get.snackbar("Error", e.toString().replaceAll('Exception: ', ''));
      await loadCart(); // Reload to sync with server
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ INCREASE QUANTITY
  Future<void> increaseQuantity(String rowId) async {
    if (rowId.isEmpty) return;
    int index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
    if (index >= 0) {
      final currentQty = cartItems[index]['quantity'] ?? 1;
      await updateQuantity(rowId, currentQty + 1);
    }
  }

  /// ✅ DECREASE QUANTITY
  Future<void> decreaseQuantity(String rowId) async {
    if (rowId.isEmpty) return;
    int index = cartItems.indexWhere((item) => item['row_id'].toString() == rowId);
    if (index >= 0) {
      final currentQty = cartItems[index]['quantity'] ?? 1;
      if (currentQty > 1) {
        await updateQuantity(rowId, currentQty - 1);
      } else {
        await removeFromCart(rowId);
      }
    }
  }

  /// ✅ CLEAR CART
  Future<void> clearCart() async {
    if (!userCtrl.isLoggedIn.value) return;
    try {
      isLoading.value = true;
      final token = userCtrl.token.value;
      if (kDebugMode) print("📡 Clearing cart...");

      await ApiService.clearCart(token);
      cartItems.clear();
      _calculateTotals();

      Get.snackbar(
          "Cleared",
          "Cart cleared successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900]
      );
    } catch (e) {
      if (kDebugMode) print("❌ Clear error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ CALCULATE TOTALS
  void _calculateTotals() {
    double sum = 0.0;
    int count = 0;
    for (var item in cartItems) {
      final price = _parseDouble(item['price']);
      final qty = item['quantity'] as int? ?? 1;
      sum += price * qty;
      count += qty;
    }
    totalAmount.value = sum + 50.0; // +50 service charge
    totalItemsCount.value = count;

    if (kDebugMode) {
      print("💰 Totals calculated: Items=$count, Amount=₹$sum (+50 service)");
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  bool validateCart() {
    if (cartItems.isEmpty) {
      Get.snackbar(
          "Empty Cart",
          "Please add items first",
          backgroundColor: Colors.orange[100],
          colorText: Colors.orange[900]
      );
      return false;
    }
    return true;
  }

  void clearLocalCart() {
    cartItems.clear();
    errorMsg.value = '';
    _calculateTotals();
  }

  int get totalItems => totalItemsCount.value;

  /// ✅ Force refresh cart
  Future<void> refreshCart() async {
    if (kDebugMode) print("🔄 Force refreshing cart...");
    await loadCart();
  }
}