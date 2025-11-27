// lib/pages/cart_details_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controller/cart_controller.dart';
import '../controller/home_page_controller.dart';

class CartDetailsPage extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const CartDetailsPage({super.key, required this.serviceData});

  @override
  Widget build(BuildContext context) {
    final cartCtrl = Get.find<CartController>();
    final homeCtrl = Get.find<HomePageController>();

    // Fetch cart on init
    cartCtrl.loadCart();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart Preview"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 📦 Service Details
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceData['title'] ?? 'Service',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "₹${(serviceData['price'] as num).toStringAsFixed(0)}",
                        style: TextStyle(color: Colors.red, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ➕ Add to Cart Button
            Padding(
              padding: EdgeInsets.all(4.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await cartCtrl.addToCart(serviceData, qty: 1);
                      Get.snackbar("✅ Success", "Added to cart!");

                      // Go to Cart Page
                      homeCtrl.changeTab(4);
                      Get.back(); // Close this page
                    } catch (e) {
                      Get.snackbar("❌ Error", e.toString());
                    }
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Add to Cart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ),

            // 🛒 Current Cart Items (Optional)
            Expanded(
              child: Obx(() {
                if (cartCtrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = cartCtrl.cartItems;
                if (items.isEmpty) {
                  return const Center(child: Text("Cart is empty"));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return ListTile(
                      title: Text(item['title']),
                      subtitle: Text("Qty: ${item['quantity']}"),
                      trailing: Text("₹${item['price'].toStringAsFixed(0)}"),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}