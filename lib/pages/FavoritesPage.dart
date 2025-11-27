// ✅ lib/pages/favorites_page.dart - FULLY RESPONSIVE WITH SIZER

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late WishlistController wishlistCtrl;
  late CartController cartCtrl;
  late UserController userCtrl;

  @override
  void initState() {
    super.initState();
    wishlistCtrl = Get.find<WishlistController>();
    cartCtrl = Get.find<CartController>();
    userCtrl = Get.find<UserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      wishlistCtrl.loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () {
              wishlistCtrl.loadWishlist();
              Get.snackbar(
                "Refreshed",
                "Favorites updated",
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 1),
              );
            },
          ),
          Obx(() => wishlistCtrl.wishlistItems.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () => _showClearDialog(),
          )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (wishlistCtrl.isLoading.value && wishlistCtrl.wishlistItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (wishlistCtrl.wishlistItems.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => wishlistCtrl.loadWishlist(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid - 3 columns on tablets, 2 on phones
              final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

              return GridView.builder(
                padding: EdgeInsets.all(3.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 3.w,
                  childAspectRatio: 0.7,
                ),
                itemCount: wishlistCtrl.wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = wishlistCtrl.wishlistItems[index];
                  return _buildFavoriteCard(item);
                },
              );
            },
          ),
        );
      }),
    );
  }

  // ✅ FAVORITE CARD - RESPONSIVE WITH SIZER
  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    final price = _parseDouble(item['price']);
    final comparePrice = _parseDouble(item['compare_price']);
    final hasDiscount = comparePrice > 0 && comparePrice > price;
    final discountPercent = hasDiscount
        ? ((comparePrice - price) / comparePrice * 100).round()
        : 0;
    final imageUrl = _normalizeImageUrl(item['image'] ?? item['image_url']);
    final productId = item['id'] ?? item['product_id'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section - Fixed aspect ratio
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    ),
                  ),
                ),

                // Discount Badge
                if (hasDiscount && discountPercent > 0)
                  Positioned(
                    top: 2.w,
                    left: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[600]!, Colors.red[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$discountPercent% OFF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Favorite Button
                Positioned(
                  top: 2.w,
                  right: 2.w,
                  child: GestureDetector(
                    onTap: () async {
                      if (productId != null) {
                        await wishlistCtrl.removeFromWishlist(productId);
                        Get.snackbar(
                          "Removed",
                          "Item removed from favorites",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange[100],
                          colorText: Colors.orange[900],
                          duration: const Duration(seconds: 2),
                        );
                      }
                    },
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
                        Icons.favorite,
                        color: Colors.red[600],
                        size: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Section - Flexible with min size
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - Takes available space
                  Flexible(
                    flex: 2,
                    child: Text(
                      item['title'] ?? item['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  // Price Row
                  Row(
                    children: [
                      Text(
                        "₹${price.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                      if (hasDiscount) ...[
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            "₹${comparePrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Add to Cart Button - Fixed height
                  SizedBox(
                    width: double.infinity,
                    height: 4.5.h,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart, size: 11.sp),
                          SizedBox(width: 1.w),
                          Text(
                            "Add",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 2.h),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Add items to your favorites to see them here',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Continue Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ADD TO CART
  Future<void> _addToCart(Map<String, dynamic> item) async {
    try {
      if (!userCtrl.isLoggedIn.value || userCtrl.token.value.isEmpty) {
        Get.snackbar(
          "Login Required",
          "Please login to add items to cart",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange[600],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

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
                  borderRadius: BorderRadius.circular(16),
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

      await cartCtrl.addToCart(item, qty: 1);

      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }

      await Future.delayed(const Duration(milliseconds: 300));

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "${item['title']} added to cart!",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Navigator.of(Get.overlayContext!).pop();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ✅ CLEAR ALL FAVORITES DIALOG
  void _showClearDialog() {
    Get.defaultDialog(
      title: "Clear All Favorites?",
      middleText: "This action cannot be undone.",
      textConfirm: "Clear",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        wishlistCtrl.clearWishlist();
        Get.back();
      },
    );
  }

  // ✅ HELPER: Parse double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ✅ HELPER: Normalize image URL
  String _normalizeImageUrl(dynamic rawImage) {
    if (rawImage == null || rawImage.toString().trim().isEmpty) {
      return 'https://via.placeholder.com/300?text=No+Image';
    }
    String url = rawImage.toString().trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return 'https://portfolio2.lemmecode.in$url';
  }
}