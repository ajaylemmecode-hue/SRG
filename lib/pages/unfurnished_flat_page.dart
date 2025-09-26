import 'package:flutter/material.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:get/get.dart';

class UnfurnishedFlatPage extends StatefulWidget {
  const UnfurnishedFlatPage({super.key});

  @override
  State<UnfurnishedFlatPage> createState() => _UnfurnishedFlatPageState();
}

class _UnfurnishedFlatPageState extends State<UnfurnishedFlatPage> {
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select your flat type and get professional cleaning service (Unfurnished)",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            const Text(
              "Choose Your Flat Type",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildFlatTypeCard(
                title: "1 BHK",
                description: "1 Bedroom, 1 Hall, 1 Kitchen",
                price: "₹ 1200",
                image: "assets/images/1bhk.png"),
            const SizedBox(height: 15),
            _buildFlatTypeCard(
                title: "2 BHK",
                description: "2 Bedrooms, 1 Hall, 1 Kitchen",
                price: "₹ 1800",
                image: "assets/images/2bhk.png"),
            const SizedBox(height: 15),
            _buildFlatTypeCard(
                title: "3 BHK",
                description: "3 Bedrooms, 1 Hall, 1 Kitchen",
                price: "₹ 2500",
                image: "assets/images/3bhk.png"),
            const SizedBox(height: 15),
            _buildFlatTypeCard(
                title: "4 BHK",
                description: "4 Bedrooms, 1 Hall, 1 Kitchen",
                price: "₹ 3200",
                image: "assets/images/3bhk.png"),
            const SizedBox(height: 15),
            _buildFlatTypeCard(
                title: "5 BHK",
                description: "5 Bedrooms, 1 Hall, 1 Kitchen",
                price: "₹ 4000",
                image: "assets/images/3bhk.png"),
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

        // Show popup dialog
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                final total = unitPrice * quantity;
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
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
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              image,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          description,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),

                        // Price
                        Text(
                          "Unit Price: $price",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 20),

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
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.blue),
                              iconSize: 30,
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () {
                                setStateDialog(() {
                                  quantity++;
                                });
                              },
                              icon: const Icon(Icons.add_circle,
                                  color: Colors.blue),
                              iconSize: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Total
                        Center(
                          child: Text(
                            "Total: ₹ $total",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close, color: Colors.white),
                              label: const Text(
                                "Close",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                final cartController =
                                Get.find<CartController>();
                                cartController.addToCart({
                                  "title": selectedFlat!,
                                  "price": unitPrice,
                                  "quantity": quantity,
                                  "image":
                                  "assets/images/${selectedFlat!.toLowerCase().replaceAll(' ', '')}.png",
                                });

                                // Switch to Cart tab
                                Get.find<HomePageController>().changeTab(6);

                                Get.snackbar(
                                  "Added to Cart",
                                  "$selectedFlat added successfully",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.shade100,
                                );

                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.shopping_cart,
                                  color: Colors.white),
                              label: const Text(
                                "Add to Cart",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Services Section
                        const Text(
                          "🧹 Services Included (Unfurnished):",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "🏠 Hall Cleaning:\n"
                              "• Dusting & Sweeping\n"
                              "• Floor Scrubbing & Mopping\n\n"
                              "🛏 Bedroom Cleaning:\n"
                              "• Dusting & Sweeping\n"
                              "• Floor Scrubbing & Mopping\n\n"
                              "🍳 Kitchen Cleaning:\n"
                              "• Basic Dusting & Mopping\n"
                              "• Platform Cleaning\n\n"
                              "🚿 Bathroom Cleaning:\n"
                              "• Pot, Sink, Tap & Mirror Cleaning\n"
                              "• Floor Scrubbing & Hard Stain Removal\n\n"
                              "🌿 Balcony Cleaning:\n"
                              "• Dusting, Sweeping, Floor Mopping",
                          style: TextStyle(fontSize: 16, height: 1.6),
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
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                image,
                width: 100,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue)),
                    const SizedBox(height: 6),
                    Text(description,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(price,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ],
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}