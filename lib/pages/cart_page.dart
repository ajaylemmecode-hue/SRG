import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';
import 'package:sizer/sizer.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600; // breakpoint

        return Obx(() {
          final items = cartController.cartItems;
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Your Cart",
                    style: TextStyle(
                      fontSize: isTablet ? 16.sp : 18.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
              ),

              // Items list
              Expanded(
                child: items.isEmpty
                    ? Center(
                  child: Text(
                    "Your cart is empty",
                    style: TextStyle(fontSize: isTablet ? 10.sp : 12.sp),
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _cartItem(item, cartController, isTablet);
                  },
                ),
              ),

              // Summary + Checkout
              _orderSummary(cartController, isTablet),
            ],
          );
        });
      },
    );
  }

  Widget _cartItem(
      Map<String, dynamic> item, CartController cartController, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(isTablet ? 2.w : 3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 1.5.h,
            offset: Offset(0, 0.5.h),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2.w),
            child: Image.asset(
              item['image'],
              width: isTablet ? 15.w : 20.w,
              height: isTablet ? 8.h : 10.h,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'],
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 12.sp : 14.sp)),
                SizedBox(height: 1.h),
                Text("₹ ${item['price']}",
                    style: TextStyle(
                        fontSize: isTablet ? 12.sp : 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => cartController.decreaseQuantity(item['title']),
                    child: CircleAvatar(
                      radius: isTablet ? 2.5.w : 3.w,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.remove, size: isTablet ? 3.5.w : 4.w),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text(
                      "${item['quantity']}",
                      style: TextStyle(fontSize: isTablet ? 12.sp : 14.sp),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cartController.increaseQuantity(item['title']),
                    child: CircleAvatar(
                      radius: isTablet ? 2.5.w : 3.w,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.add, size: isTablet ? 3.5.w : 4.w),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => cartController.removeFromCart(item['title']),
                icon: Icon(Icons.delete,
                    color: Colors.red, size: isTablet ? 5.w : 6.w),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _orderSummary(CartController cartController, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3.w),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 1.5.h,
                    offset: Offset(0, 0.5.h)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Order Summary",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isTablet ? 13.sp : 15.sp)),
                SizedBox(height: 1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Items (${cartController.totalItems})",
                        style: TextStyle(fontSize: isTablet ? 11.sp : 13.sp)),
                    Text(
                        "₹ ${(cartController.totalAmount - 50).toStringAsFixed(0)}",
                        style: TextStyle(fontSize: isTablet ? 11.sp : 13.sp)),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Service Charge",
                        style: TextStyle(fontSize: isTablet ? 11.sp : 13.sp)),
                    Text("₹ 50",
                        style: TextStyle(fontSize: isTablet ? 11.sp : 13.sp)),
                  ],
                ),
                SizedBox(height: 1.h),
                Divider(),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 13.sp : 15.sp)),
                    Text(
                      "₹ ${cartController.totalAmount.toStringAsFixed(0)}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: isTablet ? 13.sp : 15.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Proceed button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (cartController.cartItems.isNotEmpty) {
                  final homeController = Get.find<HomePageController>();
                  homeController.billingData.value = {
                    "items": cartController.cartItems.map((item) {
                      return {
                        "title": item['title'],
                        "price": item['price'],
                        "quantity": item['quantity'],
                        "image": item['image'],
                      };
                    }).toList(),
                    "totalAmount": cartController.totalAmount,
                  };
                  homeController.changeTab(HomePageTabs.billing);
                } else {
                  Get.snackbar(
                    "Cart Empty",
                    "Please add items before checkout",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80ED),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                padding: EdgeInsets.symmetric(vertical: isTablet ? 1.h : 1.5.h),
              ),
              child: Text(
                "Proceed to Checkout",
                style: TextStyle(
                    fontSize: isTablet ? 12.sp : 14.sp, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}