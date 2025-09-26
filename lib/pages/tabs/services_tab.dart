import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/pages/enquiry_form_page.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  static const List<Map<String, String>> services = [
    {"title": "Flats", "subtitle": "Complete apartment cleaning", "image": "assets/images/flat.png"},
    {"title": "Bungalows", "subtitle": "Full house deep cleaning", "image": "assets/images/bungalow.png"},
    {"title": "Offices", "subtitle": "Commercial workspace cleaning", "image": "assets/images/office.png"},
    {"title": "Societies", "subtitle": "Community area maintenance", "image": "assets/images/society.png"},
    {"title": "Restaurant Cleaning", "subtitle": "Food service hygiene", "image": "assets/images/restaurant.png"},
    {"title": "Shops Cleaning", "subtitle": "Retail space maintenance", "image": "assets/images/shops.png"},
    {"title": "School/Colleges Cleaning", "subtitle": "Educational facility care", "image": "assets/images/school.png"},
    {"title": "Car Wash", "subtitle": "Vehicle cleaning service", "image": "assets/images/carwash.png"},
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // ✅ Heading
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "OTHER\n",
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(
                    text: "SERVICES\n",
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Container(height: 0.5.h, width: 20.w, color: Colors.red),
            SizedBox(height: 1.h),
            Text(
              "Choose from our wide range of cleaning services",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13.sp),
            ),
            SizedBox(height: 3.h),

            // ✅ Responsive Grid with balanced aspect ratio
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.w,
                childAspectRatio: isTablet ? 1.1 : 0.8, // ✅ Better balance
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300), // ✅ prevent stretch on tablets
                  child: _AnimatedServiceCard(
                    title: service["title"]!,
                    subtitle: service["subtitle"]!,
                    image: service["image"]!,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedServiceCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String image;

  const _AnimatedServiceCard({
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  State<_AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<_AnimatedServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: () {
            final controller = Get.find<HomePageController>();
            if (widget.title == "Flats") {
              controller.changeTab(5);
            } else {
              Get.to(() => EnquiryFormPage(serviceName: widget.title));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.w),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(3.w),
                    topRight: Radius.circular(3.w),
                  ),
                  child: Image.asset(
                    widget.image,
                    height: isTablet ? 20.h : 15.h, // ✅ slightly smaller for tablets
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // ✅ Title & Subtitle
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14.sp : 12.sp,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isTablet ? 12.sp : 11.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // const Spacer(),

                // ✅ View Details (bottom aligned)
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Row(
                    children: [
                      Text(
                        "View Details",
                        style: TextStyle(
                          fontSize: isTablet ? 13.sp : 11.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: isTablet ? 13.sp : 11.sp,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}