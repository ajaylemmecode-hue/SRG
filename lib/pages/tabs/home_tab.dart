// lib/pages/home_tab.dart

import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/widgets/service_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomePageController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
      childAspectRatio = 0.70;
    }

    return SafeArea(
      child: Stack(
        children: [
          Obx(() {
            if (homeController.isLoading.value) {
              return _buildLoadingState();
            }

            if (homeController.errorMsg.value.isNotEmpty) {
              return _buildErrorState(homeController);
            }

            final allServicesFromAPI = homeController.allServices;
            final query = homeController.searchQuery.value.toLowerCase();
            final filteredServices = query.isEmpty
                ? allServicesFromAPI
                : allServicesFromAPI.where((s) {
              final title = s["title"]?.toString().toLowerCase() ?? "";
              return title.contains(query);
            }).toList();

            return RefreshIndicator(
              onRefresh: () => homeController.refreshHomeData(),
              color: Colors.blue,
              child: ListView(
                padding: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 14.h),
                children: [
                  _buildPromotionalCarousel(screenHeight),
                  SizedBox(height: 3.h),
                  _buildSectionHeader(),
                  SizedBox(height: 2.5.h),
                  _buildServicesHeader(filteredServices.length),
                  SizedBox(height: 1.5.h),
                  filteredServices.isEmpty
                      ? _buildEmptyState(query, homeController)
                      : _buildServicesGrid(
                    filteredServices,
                    crossAxisCount,
                    childAspectRatio,
                  ),
                ],
              ),
            );
          }),
          _buildFloatingButtons(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 2.h),
          Text(
            "Loading services...",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(HomePageController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 70,
              color: Colors.red[300],
            ),
            SizedBox(height: 2.h),
            Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                controller.errorMsg.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.red[700],
                ),
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () => controller.fetchHomeData(),
              icon: Icon(Icons.refresh_rounded, size: 20.sp),
              label: Text(
                "Try Again",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionalCarousel(double screenHeight) {
    return CarouselSlider(
      options: CarouselOptions(
        height: math.max(screenHeight * 0.25, 160),
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        pauseAutoPlayOnTouch: true,
      ),
      items: ads.map((ad) => _buildAdCard(ad)).toList(),
    );
  }

  Widget _buildAdCard(Map<String, dynamic> ad) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ad["color"], ad["color"].withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            ad["title"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildCouponCode(ad),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4.w),
                      bottomRight: Radius.circular(4.w),
                    ),
                    child: Image.asset(
                      ad["image"],
                      height: constraints.maxHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white.withOpacity(0.1),
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCouponCode(Map<String, dynamic> ad) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 0.8.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1.5.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            ad["code"],
            style: TextStyle(
              color: ad["color"],
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: ad["code"]));
            Get.snackbar(
              "✓ Copied!",
              "${ad["code"]} copied to clipboard",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.black87,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              margin: EdgeInsets.all(3.w),
              borderRadius: 2.w,
            );
          },
          child: Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.copy_rounded,
              color: Colors.white,
              size: 14.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "RESIDENTIAL\n",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: "CLEANING\n",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text: "SERVICES",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 0.5.h,
          width: 20.w,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(1.w),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesHeader(int count) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Our Services",
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 0.5.h,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Text(
              "$count Services",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query, HomePageController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 70,
              color: Colors.grey[300],
            ),
            SizedBox(height: 2.h),
            Text(
              query.isEmpty
                  ? "No services available"
                  : "No results for \"$query\"",
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (query.isNotEmpty) ...[
              SizedBox(height: 1.h),
              TextButton(
                onPressed: () => controller.updateSearch(""),
                child: Text(
                  "Clear search",
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🔥 सुधारित: Product ID validation सह
  Widget _buildServicesGrid(
      List<Map<String, dynamic>> services,
      int crossAxisCount,
      double childAspectRatio,
      ) {
    return GridView.builder(
      itemCount: services.length,
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
        final service = services[index];

        // ✅ Validation: service मध्ये id आहे का?
        if (service['id'] == null || service['id'] == 0) {
          return Container(
            alignment: Alignment.center,
            child: Text(
              "Invalid Service",
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          );
        }

        return ServiceCard(
          title: service["title"] ?? "Unknown Service",
          price: service["price"] ?? 0,
          comparePrice: service["compare_price"],
          imageUrl: service["image_url"],
          serviceData: service,
        );
      },
    );
  }

  Widget _buildFloatingButtons() {
    return Positioned(
      bottom: 6.h,
      right: 4.w,
      child: Column(
        children: [
          _GradientFab(
            heroTag: "whatsapp",
            icon: FontAwesomeIcons.whatsapp,
            colors: const [Color(0xFF25D366), Color(0xFF128C7E)],
            onTap: _onWhatsAppTap,
          ),
          SizedBox(height: 2.h),
          _GradientFab(
            heroTag: "chat",
            icon: Icons.chat_rounded,
            colors: const [Color(0xFFFF416C), Color(0xFFFF4B2B)],
            onTap: _onChatTap,
          ),
        ],
      ),
    );
  }

  // 🔥 सुधारित: WhatsApp URL मधून spaces काढले
  Future<void> _onWhatsAppTap() async {
    const phoneNumber = "919763954728"; // 👈 +91 प्रीफिक्स दिला
    const message = "Hi! I'm interested in your cleaning services.";
    final whatsappUri = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}", // 👈 spaces काढले
    );
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Get.snackbar(
        "Error",
        "Could not open WhatsApp",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _onChatTap() async {
    const phoneNumber = "9763954728";
    const message = "Hi! I'm interested in your cleaning services.";
    final smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );
    final telUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar(
          "Error",
          "Could not open messaging app",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}

class _GradientFab extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GradientFab({
    required this.heroTag,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
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