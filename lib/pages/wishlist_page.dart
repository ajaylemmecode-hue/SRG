import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/pages/product_details_page.dart';
import 'package:sizer/sizer.dart';
import '../controller/wishlist_controller.dart';
import '../models/wishlist_model.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WishlistController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wishlist"),
        actions: [
          Obx(() => Padding(
            padding: EdgeInsets.only(right: 16.sp),
            child: Text(
              "${controller.wishlistCount}",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.wishlistItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 60.sp, color: Colors.grey[400]),
                SizedBox(height: 2.h),
                Text(
                  "Your wishlist is empty",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text("Continue Shopping"),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(2.w),
          itemCount: controller.wishlistItems.length,
          itemBuilder: (context, index) {
            final item = controller.wishlistItems[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              child: ListTile(
                leading: Image.network(
                  item['image_url'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
                ),
                title: Text(item['title']),
                subtitle: Text("₹${item['price']}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => controller.removeFromWishlist(item['id']),
                ),
                onTap: () => Get.to(ProductDetailsPage(productId: item['id'])),
              ),
            );
          },
        );
      }),
    );
  }
}