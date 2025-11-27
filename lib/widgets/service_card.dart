// ✅ lib/widgets/service_card.dart - COMPLETE FIXED VERSION

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/pages/cart_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final dynamic price;
  final dynamic comparePrice;
  final String? imageUrl;
  final Map<String, dynamic> serviceData;

  const ServiceCard({
    super.key,
    required this.title,
    required this.price,
    this.comparePrice,
    this.imageUrl,
    required this.serviceData,
  });

  String? getFullImageUrl() {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://')) {
      return imageUrl;
    }
    const baseUrl = 'https://portfolio2.lemmecode.in';
    return '$baseUrl$imageUrl';
  }

  int? getDiscountPercentage() {
    try {
      final comparePriceNum = _parseDouble(comparePrice);
      final priceNum = _parseDouble(price);
      if (comparePriceNum <= 0 || priceNum <= 0) return null;
      if (comparePriceNum <= priceNum) return null;
      final discount = (((comparePriceNum - priceNum) / comparePriceNum) * 100);
      return discount.round();
    } catch (e) {
      return null;
    }
  }

  double _parseDouble(dynamic value) {
    try {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceNum = _parseDouble(price);
    final priceStr = priceNum.toStringAsFixed(0);
    final hasDiscount = comparePrice != null && _parseDouble(comparePrice) > priceNum;
    final discountPercent = getDiscountPercentage();
    final fullImageUrl = getFullImageUrl();
    final productId = serviceData['id'];

    return GestureDetector(
      onTap: () => _showProductDetailsModal(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.w),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  _buildImageSection(fullImageUrl, hasDiscount, discountPercent),
                  if (productId != null && productId != 0)
                    Positioned(
                      top: 2.w,
                      right: 2.w,
                      child: _buildWishlistButton(productId),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTitle(),
                  SizedBox(height: 1.5.w),
                  _buildPriceSection(priceStr, hasDiscount),
                  SizedBox(height: 2.5.w),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showProductDetailsModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 1.1.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility, size: 13.sp),
                          SizedBox(width: 2.w),
                          Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ WISHLIST BUTTON
  Widget _buildWishlistButton(int productId) {
    return GetBuilder<WishlistController>(
      builder: (wishlistCtrl) {
        final isInWishlist = wishlistCtrl.isItemInWishlist(productId);
        return GestureDetector(
          onTap: () => _toggleWishlist(productId),
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red[600] : Colors.grey[600],
              size: 18.sp,
            ),
          ),
        );
      },
    );
  }

  // ✅ TOGGLE WISHLIST METHOD - THIS WAS MISSING!
  Future<void> _toggleWishlist(int productId) async {
    try {
      final userCtrl = Get.find<UserController>();
      final wishlistCtrl = Get.find<WishlistController>();

      if (!userCtrl.isLoggedIn.value || userCtrl.token.value.isEmpty) {
        Get.snackbar(
          "Login Required",
          "Please log in to add items to wishlist",
          backgroundColor: Colors.orange[600],
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          mainButton: TextButton(
            onPressed: () {
              Get.back();
              Get.to(() => const LoginPage());
            },
            child: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
        return;
      }

      final isInWishlist = wishlistCtrl.isItemInWishlist(productId);
      if (isInWishlist) {
        await wishlistCtrl.removeFromWishlist(productId);
      } else {
        await wishlistCtrl.addToWishlist(productId);
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

// ✅ Replace _onAddToCart method in service_card.dart with this:

  /// 🔥 ADD TO CART - FINAL FIXED VERSION (No Snackbar Errors)
  Future<void> _onAddToCart() async {
    try {
      final userCtrl = Get.find<UserController>();
      final cartController = Get.find<CartController>();

      // CHECK LOGIN
      if (!userCtrl.isLoggedIn.value || userCtrl.token.value.isEmpty) {
        Get.snackbar(
          "Login Required",
          "Please login to add items to cart",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[600],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );
        return;
      }

      // VALIDATE PRODUCT ID
      final productId = serviceData['id'];
      if (productId == null || productId == 0) {
        Get.snackbar(
            "Error",
            "Invalid product",
            backgroundColor: Colors.red[600],
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM
        );
        return;
      }

      // 🔥 SHOW LOADING DIALOG
      Get.dialog(
        PopScope(
          canPop: false,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.blue),
                    SizedBox(height: 16),
                    Text("Adding to cart...", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // 🔥 CALL API
      print("🛒 Adding product ID: $productId to cart");
      await cartController.addToCart(serviceData, qty: 1);

      // CLOSE LOADING DIALOG
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }

      // 🔥 Wait for overlay to settle
      await Future.delayed(const Duration(milliseconds: 300));

      // 🔥 SUCCESS - Show simple snackbar
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text("$title added to cart!")),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
                    Get.to(() => const CartPage());
                  },
                  child: const Text("VIEW CART", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      print("❌ Add to cart error: $errorMessage");

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text("Error: $errorMessage"),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ✅ PARSE DESCRIPTION TO POINTS
  List<String> _parseDescriptionToPoints(String htmlString) {
    if (htmlString.isEmpty) return [];
    String cleaned = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&lsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return [];

    List<String> points = [];
    if (cleaned.contains('•')) {
      points = cleaned.split('•').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (cleaned.contains('\n')) {
      points = cleaned.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (RegExp(r'\d+\.').hasMatch(cleaned)) {
      points = cleaned.split(RegExp(r'\d+\.')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      if (cleaned.length < 200) {
        points = [cleaned];
      } else {
        points = cleaned.split(RegExp(r'\.\s+(?=[A-Z])')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    }
    return points;
  }

  // ✅ PRODUCT DETAILS MODAL
  void _showProductDetailsModal(BuildContext context) {
    final priceNum = _parseDouble(price);
    final priceStr = priceNum.toStringAsFixed(0);
    final hasDiscount = comparePrice != null && _parseDouble(comparePrice) > priceNum;
    final discountPercent = getDiscountPercentage();
    final fullImageUrl = getFullImageUrl();

    String rawDescription = serviceData['description']?.toString() ?? serviceData['short_description']?.toString() ?? '';
    final descriptionPoints = _parseDescriptionToPoints(rawDescription);
    final servicesIncluded = serviceData['services_included'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: fullImageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: fullImageUrl,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(height: 300, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator())),
                        errorWidget: (_, __, ___) => Container(height: 300, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 80)),
                      )
                          : Container(height: 300, color: Colors.grey[200], child: Icon(Icons.image, size: 80, color: Colors.grey)),
                    ),
                    const SizedBox(height: 20),
                    Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text("₹$priceStr", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red[600])),
                        if (hasDiscount) ...[
                          const SizedBox(width: 10),
                          Text("₹${_parseDouble(comparePrice).toStringAsFixed(0)}", style: TextStyle(fontSize: 18, color: Colors.grey[500], decoration: TextDecoration.lineThrough)),
                          if (discountPercent != null) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(5)),
                              child: Text("$discountPercent% OFF", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ],
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (descriptionPoints.isNotEmpty) ...[
                      const Text("Services Included:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 15),
                      ...descriptionPoints.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: BoxDecoration(color: Colors.blue[600], shape: BoxShape.circle)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(point, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4))),
                          ],
                        ),
                      )),
                    ],
                    if (servicesIncluded.isNotEmpty && servicesIncluded.length != descriptionPoints.length) ...[
                      const SizedBox(height: 20),
                      const Text("Additional Services:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 10),
                      ...servicesIncluded.map((service) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(service.toString(), style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
                          ],
                        ),
                      )),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _onAddToCart();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_rounded, size: 24),
                            SizedBox(width: 12),
                            Text("Add to Cart", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(String? imageUrl, bool hasDiscount, int? discountPercent) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(3.w), topRight: Radius.circular(3.w)),
          child: _buildImage(imageUrl),
        ),
        if (hasDiscount && discountPercent != null)
          Positioned(
            top: 2.w,
            left: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red[600]!, Colors.red[400]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(1.5.w),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_offer_rounded, color: Colors.white, size: 9.sp),
                  SizedBox(width: 1.w),
                  Text("$discountPercent% OFF", style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return _buildFallbackImage();
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => _buildPlaceholder(),
      errorWidget: (_, __, ___) => _buildErrorImage(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))),
            SizedBox(height: 1.h),
            Text('Loading...', style: TextStyle(fontSize: 9.sp, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey[400]),
          SizedBox(height: 1.h),
          Text('Image unavailable', style: TextStyle(fontSize: 9.sp, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.blue[50],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cleaning_services_rounded, size: 45, color: Colors.blue[300]),
          SizedBox(height: 1.h),
          Text(title.split(' ').first, style: TextStyle(fontSize: 10.sp, color: Colors.blue[700], fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5.sp, color: Colors.black87, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis);
  }

  Widget _buildPriceSection(String priceStr, bool hasDiscount) {
    return Row(
      children: [
        Text("₹$priceStr", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[600], fontSize: 15.sp)),
        if (hasDiscount) ...[
          SizedBox(width: 2.w),
          Text("₹${_parseDouble(comparePrice).toStringAsFixed(0)}", style: TextStyle(fontSize: 11.sp, color: Colors.grey[500], decoration: TextDecoration.lineThrough, decorationColor: Colors.grey[500], decorationThickness: 1.5)),
        ],
      ],
    );
  }
}