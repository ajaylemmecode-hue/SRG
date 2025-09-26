import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';

class HomeTab extends StatelessWidget {
  HomeTab({super.key});

  final List<Map<String, dynamic>> ads = [
    {
      "title": "Special 25% Off\nKitchen Cleaning",
      "code": "KITCHEN25",
      "color": Colors.green,
      "image": "assets/images/ad1.png",
    },
    {
      "title": "Flat 20% Off\non Deep Cleaning",
      "code": "CLEAN20",
      "color": Colors.blue,
      "image": "assets/images/ad2.png",
    },
    {
      "title": "New Customer\n30% Off First Service",
      "code": "WELCOME30",
      "color": Colors.purple,
      "image": "assets/images/ad3.png",
    },
  ];

  final List<Map<String, dynamic>> services = const [
    {"title": "Hall Deep Cleaning", "price": 1650, "image": "assets/images/one_img.webp"},
    {"title": "Kitchen Cleaning", "price": 1750, "image": "assets/images/two_img.webp"},
    {"title": "Bedroom Cleaning", "price": 1350, "image": "assets/images/three_img.webp"},
    {"title": "Bathroom Cleaning", "price": 699, "image": "assets/images/four_img.webp"},
    {"title": "Furniture Cleaning", "price": 1200, "image": "assets/images/five_img.webp"},
    {"title": "Balcony Cleaning", "price": 450, "image": "assets/images/six_img.webp"},
    {"title": "Upholstery Cleaning", "price": 250, "image": "assets/images/seven_img.webp"},
    {"title": "Ceiling & Wall Cleaning", "price": 3000, "image": "assets/images/eight_img.webp"},
    {"title": "Floor Cleaning", "price": "4 per sq.ft.", "image": "assets/images/nine_img.webp"},
    {"title": "Carpet Cleaning", "price": "6 per sq.ft.", "image": "assets/images/ten_img.webp"},
  ];

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomePageController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth >= 600;

    // Dynamic grid layout tuned to width so items get sufficient height.
    int crossAxisCount;
    double childAspectRatio;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
      childAspectRatio = 1.0;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.98;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
      childAspectRatio = 0.9;
    } else {
      crossAxisCount = 2;
      childAspectRatio = 0.70; // taller tiles on phones so button fits
    }

    // Carousel height responsive to device height
    final double carouselHeight = math.max(screenHeight * (isTablet ? 0.18 : 0.22), 140);

    return SafeArea(
      child: Stack(
        children: [
          Obx(() {
            final query = homeController.searchQuery.value.toLowerCase();
            final filteredServices = query.isEmpty
                ? services
                : services
                .where((s) => s["title"].toString().toLowerCase().contains(query))
                .toList();

            return ListView(
              padding: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 14.h), // leave room for FABs & nav
              children: [
                // Ads carousel - use LayoutBuilder inside each item so children scale to the exact carousel height
                // inside ListView children:
                CarouselSlider(
                  options: CarouselOptions(
                    height: math.max(screenHeight * 0.25, 160), // taller than before
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 0.9,
                  ),
                  items: ads.map((ad) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: ad["color"],
                        borderRadius: BorderRadius.circular(4.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.w),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final h = constraints.maxHeight;
                          return Row(
                            children: [
                              // Left text area
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            ad["title"],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 3.w, vertical: 0.7.h),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(1.w),
                                            ),
                                            child: Text(
                                              ad["code"],
                                              style: TextStyle(
                                                color: ad["color"],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          InkWell(
                                            onTap: () {
                                              Clipboard.setData(
                                                  ClipboardData(text: ad["code"]));
                                              Get.snackbar(
                                                "Copied",
                                                "${ad["code"]} copied!",
                                                snackPosition: SnackPosition.BOTTOM,
                                                backgroundColor: Colors.black87,
                                                colorText: Colors.white,
                                              );
                                            },
                                            child: Icon(Icons.copy,
                                                color: Colors.white, size: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Right image area fills full height
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: h,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(4.w),
                                      bottomRight: Radius.circular(4.w),
                                    ),
                                    child: Image.asset(
                                      ad["image"],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 2.h),

                // Header
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "RESIDENTIAL\n",
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          TextSpan(
                            text: "CLEANING\n",
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          TextSpan(
                            text: "SERVICES",
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(height: 0.5.h, width: 20.w, color: Colors.red),
                  ],
                ),

                SizedBox(height: 2.h),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Our Services", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 1.h),

                // Grid of services. childAspectRatio chosen above so cards have enough height for button.
                GridView.builder(
                  itemCount: filteredServices.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 3.w,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    return ServiceCard(
                      title: service["title"],
                      price: service["price"],
                      image: service["image"],
                    );
                  },
                ),
              ],
            );
          }),

          // Floating buttons (WhatsApp / Chat)
          Positioned(
            bottom: 6.h,
            right: 4.w,
            child: Column(
              children: [
                _GradientFab(
                  heroTag: "whatsapp",
                  icon: FontAwesomeIcons.whatsapp,
                  colors: const [Color(0xFF25D366), Color(0xFF128C7E)],
                  onTap: () async {
                    const phoneNumber = "9763954728";
                    const message = "Hi! I'm interested in your cleaning services.";
                    final whatsappUri = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
                    try {
                      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      Get.snackbar("Error", "Could not open WhatsApp", backgroundColor: Colors.red, colorText: Colors.white);
                    }
                  },
                ),
                SizedBox(height: 2.h),
                _GradientFab(
                  heroTag: "chat",
                  icon: Icons.chat,
                  colors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                  onTap: () async {
                    const phoneNumber = "9763954728";
                    const message = "Hi! I'm interested in your cleaning services.";
                    final smsUri = Uri(scheme: 'sms', path: phoneNumber, queryParameters: {'body': message});
                    final telUri = Uri(scheme: 'tel', path: phoneNumber);
                    try {
                      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
                    } catch (_) {
                      try {
                        await launchUrl(telUri, mode: LaunchMode.externalApplication);
                      } catch (e) {
                        Get.snackbar("Error", "Could not open messaging app", backgroundColor: Colors.red, colorText: Colors.white);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final dynamic price;
  final String image;

  const ServiceCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final priceStr = price is num ? price.toStringAsFixed(0) : price.toString();
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2.w),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Image expands and consumes available space so other widgets don't push the layout
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(2.w), topRight: Radius.circular(2.w)),
              child: Image.asset(image, width: double.infinity, fit: BoxFit.cover),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ),

          // Price
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("₹ $priceStr", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 14.sp)),
            ),
          ),

          // Button (keeps fixed comfortable height)
          Padding(
            padding: EdgeInsets.all(2.w),
            child: SizedBox(
              width: double.infinity,
              // use a reasonable minHeight so button doesn't become too small on tiny devices
              child: ElevatedButton.icon(
                onPressed: () {
                  final cartController = Get.find<CartController>();
                  final homeController = Get.find<HomePageController>();
                  cartController.addToCart({"title": title, "price": price, "image": image});
                  homeController.changeTab(4);
                },
                icon: Icon(Icons.shopping_cart, size: 13.sp, color: Colors.white),
                label: Text("Add to Cart", style: TextStyle(color: Colors.white, fontSize: 12.5.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 1.1.h : 0.95.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  minimumSize: const Size.fromHeight(0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GradientFab({super.key, required this.heroTag, required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
        boxShadow: [BoxShadow(color: colors.first.withOpacity(0.5), blurRadius: 16, spreadRadius: 2, offset: const Offset(0, 8))],
      ),
      child: FloatingActionButton(
        heroTag: heroTag,
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: onTap,
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}
