import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/wishlist_controller.dart';
class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late WishlistController wishlistController;
  bool _isInWishlist = false;

  @override
  void initState() {
    super.initState();
    wishlistController = Get.put(WishlistController());
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final isIn = await wishlistController.isInWishlist(widget.productId);
    setState(() {
      _isInWishlist = isIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Details"),
        actions: [
          IconButton(
            icon: Icon(_isInWishlist ? Icons.favorite : Icons.favorite_border),
            color: _isInWishlist ? Colors.red : null,
            onPressed: () async {
              await wishlistController.toggleWishlist(widget.productId);
              setState(() {
                _isInWishlist = !_isInWishlist;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Product ID: ${widget.productId}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await wishlistController.toggleWishlist(widget.productId);
                setState(() {
                  _isInWishlist = !_isInWishlist;
                });
              },
              child: Text(_isInWishlist ? "Remove from Wishlist" : "Add to Wishlist"),
            ),
          ],
        ),
      ),
    );
  }
}