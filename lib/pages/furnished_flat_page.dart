import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:sizer/sizer.dart';

class FurnishedFlatPage extends StatefulWidget {
  const FurnishedFlatPage({super.key});

  @override
  State<FurnishedFlatPage> createState() => _FurnishedFlatPageState();
}

class _FurnishedFlatPageState extends State<FurnishedFlatPage> {
  String? selectedFlat;
  int quantity = 1;
  int unitPrice = 0;

  final Map<String, int> flatPrices = {
    "1 BHK": 1200,
    "2 BHK": 1800,
    "3 BHK": 2500,
    "4 BHK": 3200,
    "5 BHK": 4000,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select your flat type and get professional cleaning service",
              style: TextStyle(fontSize: 14.sp, color: Colors.black54),
            ),
            SizedBox(height: 2.h),
            Text(
              "Choose Your Flat Type",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),

            _buildFlatTypeCard(
              title: "1 BHK",
              description: "1 Bedroom, 1 Hall, 1 Kitchen",
              price: "₹ 1200",
              image: "assets/images/1bhk.png",
            ),
            SizedBox(height: 2.h),
            _buildFlatTypeCard(
              title: "2 BHK",
              description: "2 Bedrooms, 1 Hall, 1 Kitchen",
              price: "₹ 1800",
              image: "assets/images/2bhk.png",
            ),
            SizedBox(height: 2.h),
            _buildFlatTypeCard(
              title: "3 BHK",
              description: "3 Bedrooms, 1 Hall, 1 Kitchen",
              price: "₹ 2500",
              image: "assets/images/3bhk.png",
            ),
            SizedBox(height: 2.h),
            _buildFlatTypeCard(
              title: "4 BHK",
              description: "4 Bedrooms, 1 Hall, 1 Kitchen",
              price: "₹ 3200",
              image: "assets/images/3bhk.png",
            ),
            SizedBox(height: 2.h),
            _buildFlatTypeCard(
              title: "5 BHK",
              description: "5 Bedrooms, 1 Hall, 1 Kitchen",
              price: "₹ 4000",
              image: "assets/images/3bhk.png",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlatTypeCard({
    required String title,
    required String description,
    required String price,
    required String image,
  }) {
    final isSelected = selectedFlat == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFlat = title;
          unitPrice = flatPrices[title]!;
          quantity = 1;
        });

        // Show responsive popup dialog
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                final total = unitPrice * quantity;
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  title: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.w),
                            child: Image.asset(
                              image,
                              width: 40.w,
                              height: 40.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Description
                        Text(
                          description,
                          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                        ),
                        SizedBox(height: 2.h),

                        // Price
                        Text(
                          "Unit Price: $price",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Quantity Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) {
                                  setStateDialog(() {
                                    quantity--;
                                  });
                                }
                              },
                              icon: Icon(Icons.remove_circle, color: Colors.blue),
                              iconSize: 6.w,
                            ),
                            Text(
                              "$quantity",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setStateDialog(() {
                                  quantity++;
                                });
                              },
                              icon: Icon(Icons.add_circle, color: Colors.blue),
                              iconSize: 6.w,
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),

                        // Total
                        Center(
                          child: Text(
                            "Total: ₹ $total",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close, color: Colors.white, size: 5.w),
                              label: Text(
                                "Close",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 1.5.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                              ),
                              onPressed: () {
                                final cartController = Get.find<CartController>();
                                cartController.addToCart({
                                  "title": selectedFlat!,
                                  "price": unitPrice,
                                  "quantity": quantity,
                                  "image":
                                  "assets/images/${selectedFlat!.toLowerCase().replaceAll(' ', '')}.png",
                                });

                                Get.find<HomePageController>().changeTab(6);

                                Get.snackbar(
                                  "Added to Cart",
                                  "$selectedFlat added successfully",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade100,
                                );

                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.shopping_cart,
                                  color: Colors.white, size: 5.w),
                              label: Text(
                                "Add to Cart",
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // Services Section
                        Text(
                          "🧹 Services Included:",
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "🏠 Hall Cleaning:\n"
                              "• Dry Dusting, Vacuuming, Wet Wiping\n"
                              "• Cabinets Cleaning (Inside & Outside)\n"
                              "• Fans/AC, Floor Scrubbing & Mopping\n"
                              "• Dry Cleaning, Tables/Chairs/Lamp/Frames/TV set\n\n"
                              "🛏 Bedroom Cleaning:\n"
                              "• Dry Dusting, Vacuuming, Wet Wiping\n"
                              "• Cabinets Cleaning (Inside & Outside)\n"
                              "• Fans/AC, Floor Scrubbing & Mopping\n"
                              "• Bed (Inside/Outside)\n\n"
                              "🍳 Kitchen Cleaning:\n"
                              "• Dry Dusting, Vacuuming, Wet Wiping, Fans\n"
                              "• Floor Scrubbing & Mopping, Chimney/Stove (Exterior)\n"
                              "• Cabinets & Trolly Cleaning (Inside & Outside, Steam Cleaner)\n\n"
                              "🚿 Bathroom Cleaning:\n"
                              "• Commode Pot Cleaning (Toilet Cleaner Liquids)\n"
                              "• Shower, Taps, Exhaust (Wet Wiping)\n"
                              "• Hard Stain Removal, Drill Brush Scrubbing for Floor\n"
                              "• Sink Cleaning, Mirrors/Glass wiping\n\n"
                              "🌿 Balcony Cleaning:\n"
                              "• Dry Dusting, Vacuuming, Floor Scrubbing",
                          style: TextStyle(fontSize: 13.sp, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        height: 18.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 0.5.w,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3.w),
                bottomLeft: Radius.circular(3.w),
              ),
              child: Image.asset(
                image,
                width: 30.w,
                height: 18.h,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    SizedBox(height: 0.5.h),
                    Text(description,
                        style:
                        TextStyle(fontSize: 13.sp, color: Colors.black54)),
                    SizedBox(height: 0.5.h),
                    Text(price,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ],
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 7.w,
            ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }
}