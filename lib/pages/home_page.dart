import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/notification_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/pages/billing_details_page.dart';
import 'package:new_suvarnraj_group/pages/enquiry_form_page.dart';
import 'package:new_suvarnraj_group/pages/flat_details_page.dart';
import 'package:new_suvarnraj_group/pages/furnished_flat_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';
import 'package:new_suvarnraj_group/pages/notification_page.dart';
import 'package:new_suvarnraj_group/pages/tabs/bookings_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/home_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/profile_tab.dart';
import 'package:new_suvarnraj_group/pages/tabs/services_tab.dart' hide ServicesTab, EnquiryFormPage;
import 'package:new_suvarnraj_group/pages/cart_page.dart';
import 'package:new_suvarnraj_group/pages/unfurnished_flat_page.dart';
import 'package:new_suvarnraj_group/pages/wishlist_page.dart';

class HomePageTabs {
  static const int home = 0;
  static const int services = 1;
  static const int bookings = 2;
  static const int profile = 3;
  static const int cart = 4;
  static const int flatDetails = 5;
  static const int furnishedFlat = 6;
  static const int unfurnishedFlat = 7;
  static const int enquiry = 8;
  static const int billing = 9;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomePageController controller;
  late final CartController cartController;
  late final NotificationController notifCtrl;
  late final UserController userCtrl;
  late final WishlistController wishlistCtrl;

  final PageController pageController = PageController();

  final List<Widget> swipePages = [
    HomeTab(),
    const ServicesTab(),
    const BookingsTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();

    controller = Get.find<HomePageController>();
    cartController = Get.find<CartController>();
    notifCtrl = Get.find<NotificationController>();
    userCtrl = Get.find<UserController>();
    wishlistCtrl = Get.find<WishlistController>();

    print("🏠 HomePage initState:");
    print("   - User logged in: ${userCtrl.isLoggedIn.value}");
    print("   - Token: ${userCtrl.token.value.isEmpty ? 'Empty' : 'Present'}");
    print("   - Cart items: ${cartController.cartItems.length}");

    // 🔥 Load initial data
    wishlistCtrl.updateWishlistCount();

    if (userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty) {
      print("✅ Loading cart on HomePage init");
      cartController.loadCart();
    }

    // 🔥 LISTEN FOR TAB CHANGES - RELOAD CART WHEN OPENING CART TAB
    ever(controller.currentIndex, (index) {
      print("📍 Tab changed to: $index");

      if (index == HomePageTabs.cart) {
        print("🛒 Cart tab opened - reloading cart");
        if (userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty) {
          cartController.loadCart();
        }
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    double iconSize = width < 400 ? 22 : 28;
    double fontSize = width < 400 ? 14 : 16;
    double smallFont = width < 400 ? 12 : 14;

    return Obx(() => Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
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
                  : Text(
                "Suvarnraj Group",
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (controller.isSearching.value)
            IconButton(
              icon: Icon(Icons.close, color: Colors.black, size: iconSize),
              onPressed: () {
                controller.isSearching.value = false;
                controller.searchQuery.value = "";
              },
            )
          else ...[
            IconButton(
              onPressed: () => controller.isSearching.value = true,
              icon: Icon(Icons.search, color: Colors.black, size: iconSize),
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
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${notifCtrl.notifications.length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: smallFont,
                      ),
                    ),
                  )
                      : const SizedBox()),
                ),
              ],
            ),

            // ❤️ Wishlist
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () => Get.to(() => WishlistPage()),
                  icon: Icon(Icons.favorite_outline,
                      color: Colors.black, size: iconSize),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Obx(() => wishlistCtrl.wishlistCount.value > 0
                      ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${wishlistCtrl.wishlistCount.value}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: smallFont,
                      ),
                    ),
                  )
                      : const SizedBox()),
                ),
              ],
            ),

            // 🛒 Cart - FIXED VERSION
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: () {
                    print("🛒 Cart icon clicked");

                    // Check if user is logged in
                    if (!userCtrl.isLoggedIn.value) {
                      Get.snackbar(
                        "Login Required",
                        "Please login to view your cart",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange[600],
                        colorText: Colors.white,
                        icon: const Icon(Icons.login, color: Colors.white),
                        mainButton: TextButton(
                          onPressed: () {
                            Get.back();
                            Get.to(() => const LoginPage());
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    // Navigate to cart
                    controller.changeTab(HomePageTabs.cart);
                  },
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: Colors.black, size: iconSize),
                ),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Obx(() {
                    final itemCount = cartController.totalItems;
                    print("🔢 Cart badge count: $itemCount");

                    return itemCount > 0
                        ? Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$itemCount",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: smallFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : const SizedBox();
                  }),
                ),
              ],
            ),

            Obx(() => userCtrl.isLoggedIn.value
                ? const SizedBox()
                : TextButton(
              onPressed: () => Get.to(() => const LoginPage()),
              child: Text(
                "Login",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            )),
          ],
        ],
      ),

      // 🔥 BODY - FIXED CART RENDERING
      body: Obx(() {
        final currentTab = controller.currentIndex.value;
        print("📱 Rendering tab: $currentTab");

        switch (currentTab) {
          case HomePageTabs.billing:
            final data = controller.billingData.value;
            return data.isEmpty || !data.containsKey('items')
                ? Center(
                child: Text(
                  "⚠ No billing details available",
                  style: TextStyle(fontSize: fontSize),
                ))
                : BillingDetailsPage(billingData: data);

          case HomePageTabs.cart:
            print("🛒 Rendering CartPage");
            print("   Cart items: ${cartController.cartItems.length}");
            print("   Is loading: ${cartController.isLoading.value}");

            // 🔥 FORCE CART RELOAD
            if (userCtrl.isLoggedIn.value &&
                userCtrl.token.value.isNotEmpty &&
                cartController.cartItems.isEmpty &&
                !cartController.isLoading.value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                cartController.loadCart();
              });
            }

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
          // Main tabs (Home, Services, Bookings, Profile)
            if (currentTab >= 0 && currentTab <= 3) {
              return PageView(
                controller: pageController,
                onPageChanged: (index) {
                  controller.currentIndex.value = index;
                },
                children: swipePages,
              );
            }

            // Fallback to home
            return swipePages[0];
        }
      }),

      // Bottom Navigation Bar
      bottomNavigationBar: Obx(() {
        final currentTab = controller.currentIndex.value;
        final selectedIndex = currentTab > 3 ? 0 : currentTab;

        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: fontSize,
          unselectedFontSize: smallFont,
          iconSize: iconSize,
          onTap: (index) {
            print("📍 Bottom nav tapped: $index");
            controller.currentIndex.value = index;

            if (index <= 3 && pageController.hasClients) {
              pageController.jumpToPage(index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_repair_service),
              label: "Services",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: "Bookings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        );
      }),
    ));
  }
}