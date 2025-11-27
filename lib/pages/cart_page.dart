// ✅ lib/pages/cart_page.dart - COMPLETE FIXED VERSION

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/billing_details_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CartController cartCtrl;
  late UserController userCtrl;

  @override
  void initState() {
    super.initState();
    cartCtrl = Get.find<CartController>();
    userCtrl = Get.find<UserController>();

    // 🔥 Load cart when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartData();
    });
  }

  Future<void> _loadCartData() async {
    print("🛒 CartPage: Loading cart data...");
    print("   User logged in: ${userCtrl.isLoggedIn.value}");
    print("   Token present: ${userCtrl.token.value.isNotEmpty}");

    if (userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty) {
      await cartCtrl.loadCart();
      print("   Cart items after load: ${cartCtrl.cartItems.length}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () => _loadCartData(),
          ),
          Obx(() => cartCtrl.cartItems.isNotEmpty
              ? IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              onPressed: () => _showClearCartDialog()
          )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        print("🔄 CartPage rebuild - Items: ${cartCtrl.cartItems.length}, Loading: ${cartCtrl.isLoading.value}");

        // Check if user is logged in
        if (!userCtrl.isLoggedIn.value) {
          return _buildLoginRequired();
        }

        if (cartCtrl.isLoading.value) {
          return _buildLoadingState();
        }

        if (cartCtrl.errorMsg.value.isNotEmpty) {
          return _buildErrorState();
        }

        if (cartCtrl.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return RefreshIndicator(
          onRefresh: _loadCartData,
          child: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
        );
      }),
    );
  }

  // ==================== LOGIN REQUIRED ====================
  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: Colors.grey[300]),
          SizedBox(height: 2.h),
          Text(
            'Please login to view your cart',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const LoginPage()),
            icon: const Icon(Icons.login),
            label: const Text('Login Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ERROR STATE ====================
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          SizedBox(height: 2.h),
          Text(
            cartCtrl.errorMsg.value,
            style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _loadCartData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(3.w),
            itemCount: cartCtrl.cartItems.length,
            itemBuilder: (context, index) {
              final item = cartCtrl.cartItems[index];
              return _buildMobileCartItem(item);
            },
          ),
        ),
        _buildMobileCartSummary(),
      ],
    );
  }

  Widget _buildMobileCartItem(Map<String, dynamic> item) {
    final price = _parseDouble(item['price']);
    final qty = item['quantity'] ?? 1;
    final total = price * qty;
    final rowId = item['row_id']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: item['image'] ?? 'https://via.placeholder.com/100',
                    width: 22.w,
                    height: 22.w,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 22.w,
                        height: 22.w,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
                    ),
                    errorWidget: (_, __, ___) => Container(
                        width: 22.w,
                        height: 22.w,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image, color: Colors.grey[400])
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                // Title + Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          item['title'] ?? 'Unknown',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis
                      ),
                      SizedBox(height: 0.8.h),
                      Row(children: List.generate(5, (i) => Icon(Icons.star, size: 11.sp, color: Colors.amber))),
                      SizedBox(height: 1.h),
                      Text('₹ ${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.red[600])),
                    ],
                  ),
                ),
                // Delete Button
                IconButton(
                  onPressed: () => cartCtrl.removeFromCart(rowId),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                    child: Icon(Icons.close, color: Colors.red[600], size: 14.sp),
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
            decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)
                )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildQtyButton(Icons.remove, Colors.black87, () => cartCtrl.decreaseQuantity(rowId)),
                    Container(
                        width: 12.w,
                        alignment: Alignment.center,
                        child: Text('$qty', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold))
                    ),
                    _buildQtyButton(Icons.add, Colors.black87, () => cartCtrl.increaseQuantity(rowId)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total', style: TextStyle(fontSize: 10.sp, color: Colors.grey[600])),
                    Text('₹ ${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCartSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
                        Obx(() => Text('₹${(cartCtrl.totalAmount.value - 50).toStringAsFixed(0)}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500))),
                      ]
                  ),
                  SizedBox(height: 1.h),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Charge', style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                        Text('₹50', style: TextStyle(fontSize: 11.sp, color: Colors.grey[600])),
                      ]
                  ),
                  const Divider(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                        Obx(() => Text('₹${cartCtrl.totalAmount.value.toStringAsFixed(0)}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.red[600]))),
                      ]
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (cartCtrl.validateCart()) _navigateToBillingPage();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, color: Colors.white),
                      SizedBox(width: 2.w),
                      Text('PROCEED TO CHECKOUT', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                    ]
                ),
              ),
            ),
            SizedBox(height: 1.h),
            TextButton(
                onPressed: () => Get.back(),
                child: Text('Continue Shopping', style: TextStyle(fontSize: 12.sp, color: Colors.blue[600]))
            ),
          ],
        ),
      ),
    );
  }

  // ==================== WIDE SCREEN LAYOUT ====================
  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 7,
            child: Container(
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]
              ),
              child: Column(
                  children: [
                    _buildTableHeader(),
                    const Divider(height: 1),
                    Expanded(
                        child: ListView.separated(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                            itemCount: cartCtrl.cartItems.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) => _buildWideCartItemRow(cartCtrl.cartItems[index])
                        )
                    )
                  ]
              ),
            )
        ),
        Expanded(
            flex: 3,
            child: Container(
                margin: EdgeInsets.all(2.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                child: _buildWideSummary()
            )
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
          children: [
            Expanded(flex: 4, child: Text('PRODUCT', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey[700]))),
            Expanded(flex: 2, child: Text('PRICE', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey[700]), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('QUANTITY', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey[700]), textAlign: TextAlign.center)),
            Expanded(flex: 2, child: Text('TOTAL', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey[700]), textAlign: TextAlign.center)),
            SizedBox(width: 8.w),
          ]
      ),
    );
  }

  Widget _buildWideCartItemRow(Map<String, dynamic> item) {
    final price = _parseDouble(item['price']);
    final qty = item['quantity'] ?? 1;
    final total = price * qty;
    final rowId = item['row_id']?.toString() ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
          children: [
            Expanded(
                flex: 4,
                child: Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                              imageUrl: item['image'] ?? '',
                              width: 12.w,
                              height: 12.w,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(width: 12.w, height: 12.w, color: Colors.grey[200], child: const Icon(Icons.image))
                          )
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['title'] ?? '', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600), maxLines: 2),
                                SizedBox(height: 0.5.h),
                                Row(children: List.generate(5, (i) => Icon(Icons.star, size: 9.sp, color: Colors.amber)))
                              ]
                          )
                      ),
                    ]
                )
            ),
            Expanded(flex: 2, child: Text('₹ ${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 11.sp), textAlign: TextAlign.center)),
            Expanded(
                flex: 2,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildQtyButton(Icons.remove, Colors.black, () => cartCtrl.decreaseQuantity(rowId)),
                      Container(width: 6.w, alignment: Alignment.center, child: Text('$qty', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold))),
                      _buildQtyButton(Icons.add, Colors.black, () => cartCtrl.increaseQuantity(rowId))
                    ]
                )
            ),
            Expanded(flex: 2, child: Text('₹ ${total.toStringAsFixed(0)}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
            SizedBox(
                width: 8.w,
                child: IconButton(
                    onPressed: () => cartCtrl.removeFromCart(rowId),
                    icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)),
                        child: Icon(Icons.close, color: Colors.red, size: 12.sp)
                    )
                )
            ),
          ]
      ),
    );
  }

  Widget _buildWideSummary() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CART SUMMARY', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 3.h),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
                Obx(() => Text('₹${(cartCtrl.totalAmount.value - 50).toStringAsFixed(2)}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.red[600])))
              ]
          ),
          SizedBox(height: 2.h),
          const Divider(),
          SizedBox(height: 1.h),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                Obx(() => Text('₹${cartCtrl.totalAmount.value.toStringAsFixed(2)}', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.red[600])))
              ]
          ),
          SizedBox(height: 3.h),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    if (cartCtrl.validateCart()) _navigateToBillingPage();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                  ),
                  child: Text('PROCEED TO CHECKOUT', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.white))
              )
          ),
        ]
    );
  }

  // ==================== COMMON WIDGETS ====================
  Widget _buildLoadingState() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.red),
              SizedBox(height: 2.h),
              Text('Loading cart...', style: TextStyle(fontSize: 14.sp, color: Colors.grey))
            ]
        )
    );
  }

  Widget _buildEmptyCart() {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[300]),
              SizedBox(height: 2.h),
              Text('Your cart is empty', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey[600])),
              SizedBox(height: 1.h),
              Text('Add items to get started', style: TextStyle(fontSize: 12.sp, color: Colors.grey[500])),
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Continue Shopping'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h)
                  )
              )
            ]
        )
    );
  }

  Widget _buildQtyButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.all(1.2.w),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
            child: Icon(icon, color: Colors.white, size: 11.sp)
        )
    );
  }

  void _showClearCartDialog() {
    Get.defaultDialog(
        title: "Clear Cart",
        middleText: "Remove all items?",
        textConfirm: "Yes",
        textCancel: "No",
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () {
          cartCtrl.clearCart();
          Get.back();
        }
    );
  }

  void _navigateToBillingPage() {
    final billingData = {
      "items": cartCtrl.cartItems.map((item) => {
        "id": item['id'],
        "title": item['title'],
        "price": item['price'],
        "quantity": item['quantity'],
        "image": item['image']
      }).toList(),
      "totalAmount": cartCtrl.totalAmount.value,
      "totalItems": cartCtrl.totalItems
    };
    Get.to(() => BillingDetailsPage(billingData: billingData));
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}