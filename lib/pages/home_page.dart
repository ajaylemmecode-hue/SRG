//hi anmol
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/notification_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/billing_details_page.dart';
import 'package:new_suvarnraj_group/pages/enquiry_form_page.dart';
import 'package:new_suvarnraj_group/pages/flat_details_page.dart';
import 'package:new_suvarnraj_group/pages/furnished_flat_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';
import 'package:new_suvarnraj_group/pages/notification_page.dart';
import 'package:new_suvarnraj_group/pages/tabs/bookings_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/home_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/profile_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/services_tab.dart';
import 'package:new_suvarnraj_group/pages/cart_page.dart';
import 'package:new_suvarnraj_group/pages/unfurnished_flat_page.dart';

class HomePageTabs {
  static const int home = 0;
  static const int services = 1;
  static const int bookings = 2;
  static const int profile = 3;

  // 🔹 Special pages
  static const int cart = 4;
  static const int flatDetails = 5;
  static const int furnishedFlat = 6;
  static const int unfurnishedFlat = 7;
  static const int enquiry = 8;
  static const int billing = 9;
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomePageController controller = Get.put(HomePageController());
  final CartController cartController = Get.put(CartController());
  final notifCtrl = Get.put(NotificationController());
  final userCtrl = Get.find<UserController>();

  final PageController pageController = PageController();

  final List<Widget> swipePages = [
    HomeTab(),
    const ServicesTab(),
    const BookingsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // 🔹 Adjust based on screen width
    double iconSize = width < 400 ? 22 : 28;
    double fontSize = width < 400 ? 14 : 16;
    double smallFont = width < 400 ? 12 : 14;

    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      // 🔹 AppBar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            // 🔹 Logo (flexible, no cutoff)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Image.asset(
                "assets/images/logo.jpg",
                height: width < 400 ? 32 : 40,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: controller.isSearching.value
                  ? TextField(
                autofocus: true,
                style: TextStyle(fontSize: fontSize),
                decoration: InputDecoration(
                  hintText: "Search services...",
                  hintStyle: TextStyle(fontSize: smallFont),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  controller.searchQuery.value = value;
                  controller.changeTab(HomePageTabs.home);
                  pageController.jumpToPage(HomePageTabs.home);
                },
              )
                  : Text("Suvarnraj Group",
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
          ],
        ),
        actions: [
          if (controller.isSearching.value)
            IconButton(
              icon: Icon(Icons.close,
                  color: Colors.black, size: iconSize),
              onPressed: () {
                controller.isSearching.value = false;
                controller.searchQuery.value = "";
              },
            )
          else ...[
            IconButton(
              onPressed: () => controller.isSearching.value = true,
              icon: Icon(Icons.search,
                  color: Colors.black, size: iconSize),
            ),

            // 🔔 Notifications
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => Get.to(() => NotificationsPage()),
                  icon: Icon(Icons.notifications_none,
                      color: Colors.black, size: iconSize),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Obx(() => notifCtrl.notifications.isNotEmpty
                      ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      "${notifCtrl.notifications.length}",
                      style: TextStyle(
                          color: Colors.white, fontSize: smallFont),
                    ),
                  )
                      : const SizedBox()),
                ),
              ],
            ),

            // 🛒 Cart
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () =>
                      controller.changeTab(HomePageTabs.cart),
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: Colors.black, size: iconSize),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Obx(() => cartController.totalItems > 0
                      ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      "${cartController.totalItems}",
                      style: TextStyle(
                          color: Colors.white, fontSize: smallFont),
                    ),
                  )
                      : const SizedBox()),
                ),
              ],
            ),

            Obx(() => userCtrl.isLoggedIn.value
                ? const SizedBox()
                : TextButton(
              onPressed: () => Get.to(() => const LoginPage()),
              child: Text("Login",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize)),
            )),
          ],
        ],
      ),

      // 🔹 Body
      body: Obx(() {
        switch (controller.currentIndex.value) {
          case HomePageTabs.billing:
            final data = controller.billingData.value;
            return data.isEmpty
                ? Center(
                child: Text("⚠ No billing details available",
                    style: TextStyle(fontSize: fontSize)))
                : BillingDetailsPage(billingData: data);

          case HomePageTabs.cart:
            return const CartPage();
          case HomePageTabs.flatDetails:
            return const FlatDetailsPage();
          case HomePageTabs.furnishedFlat:
            return const FurnishedFlatPage();
          case HomePageTabs.unfurnishedFlat:
            return const UnfurnishedFlatPage();
          case HomePageTabs.enquiry:
            return EnquiryFormPage(serviceName: "Choose Service");
          default:
            return PageView(
              controller: pageController,
              onPageChanged: (index) {
                controller.currentIndex.value = index;
              },
              children: swipePages,
            );
        }
      }),

      // 🔹 Bottom Navigation
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentIndex.value > 3
            ? HomePageTabs.home
            : controller.currentIndex.value,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: fontSize,
        unselectedFontSize: smallFont,
        iconSize: iconSize,
        onTap: (index) {
          controller.currentIndex.value = index;
          if (index <= 3 && pageController.hasClients) {
            pageController.jumpToPage(index);
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_repair_service),
              label: "Services"),
          BottomNavigationBarItem(
              icon: Icon(Icons.book), label: "Bookings"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      )),
    ));
  }
}
