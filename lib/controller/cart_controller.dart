import 'package:get/get.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;

  void addToCart(Map<String, dynamic> service) {
    int index = cartItems.indexWhere((item) => item['title'] == service['title']);
    if (index >= 0) {
      cartItems[index]['quantity'] += 1;
    } else {
      cartItems.add({
        "title": service['title'],
        "price": service['price'], // can be int or string
        "image": service['image'],
        "quantity": 1,
      });
    }
  }

  void removeFromCart(String title) {
    cartItems.removeWhere((item) => item['title'] == title);
  }

  void increaseQuantity(String title) {
    int index = cartItems.indexWhere((item) => item['title'] == title);
    if (index >= 0) {
      cartItems[index]['quantity'] += 1;
      cartItems.refresh();
    }
  }

  void decreaseQuantity(String title) {
    int index = cartItems.indexWhere((item) => item['title'] == title);
    if (index >= 0 && cartItems[index]['quantity'] > 1) {
      cartItems[index]['quantity'] -= 1;
      cartItems.refresh();
    }
  }

  double get totalAmount {
    double sum = 0;
    for (var item in cartItems) {
      if (item['price'] is int) {
        sum += item['price'] * item['quantity'];
      }
    }
    return sum + 50; // ₹50 service charge
  }

  int get totalItems {
    int qty = 0;
    for (var item in cartItems) {
      qty += item['quantity'] as int;
    }
    return qty;
  }
}