// ✅ lib/controller/login_controller.dart - FINAL FIXED VERSION

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/api/api_service.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/controller/wishlist_controller.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();
  }

  /// ✅ LOGIN WITH EMAIL & PASSWORD - FINAL FIXED
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar("Please enter email and password");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (kDebugMode) {
        print("🔐 LoginController: Attempting login for $email");
      }

      final response = await ApiService.login(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print("📡 API Response: ${response['status']}");
        print("🔑 Token: ${response['data']?['token']}");
      }

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        final token = data['token']?.toString() ?? '';
        final userName = data['user']?['name'] ?? data['name'] ?? 'User';
        final userEmail = data['user']?['email'] ?? data['email'] ?? email;
        final userPhone = data['user']?['phone'] ?? data['phone'] ?? '';

        if (kDebugMode) {
          print("✅ Login successful!");
          print("   Token: $token");
          print("   Name: $userName");
          print("   Email: $userEmail");
        }

        await userCtrl.login(
          userName: userName,
          userEmail: userEmail,
          userPhone: userPhone,
          userToken: token,
        );

        // ✅ NAVIGATE FIRST - This ensures Overlay is available
        Get.offAll(() => const HomePage());

        // ✅ SHOW SUCCESS AFTER NAVIGATION COMPLETES
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _showSuccessSnackbar("Welcome $userName!");
            _loadUserData();
          });
        });

      } else {
        final errorMsg = response['message'] ?? 'Login failed. Please try again.';
        errorMessage.value = errorMsg;
        if (kDebugMode) print("❌ Login failed: $errorMsg");
        _showErrorSnackbar(errorMsg);
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = errorMsg;
      if (kDebugMode) print("❌ Login error: $e");
      _showErrorSnackbar(errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (Get.isRegistered<CartController>()) {
        final cartCtrl = Get.find<CartController>();
        await cartCtrl.loadCart();
        if (kDebugMode) print("✅ Cart loaded after login: ${cartCtrl.cartItems.length} items");
      }

      if (Get.isRegistered<WishlistController>()) {
        final wishlistCtrl = Get.find<WishlistController>();
        await wishlistCtrl.updateWishlistCount();
        if (kDebugMode) print("✅ Wishlist loaded after login");
      }
    } catch (e) {
      if (kDebugMode) print("⚠️ Error loading user data: $e");
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final token = userCtrl.token.value;

      if (token.isNotEmpty) {
        try {
          await ApiService.logout(token);
        } catch (e) {
          if (kDebugMode) print("⚠️ Logout API error (ignoring): $e");
        }
      }

      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearLocalCart();
      }

      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().clearLocalWishlist();
      }

      await userCtrl.logout();

      Get.offAll(() => const HomePage());

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showInfoSnackbar("You have been logged out");
        });
      });

      if (kDebugMode) print("✅ User logged out");
    } catch (e) {
      if (kDebugMode) print("❌ Logout error: $e");
      _showErrorSnackbar("Failed to logout");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? phone,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorSnackbar("Please fill all required fields");
      return;
    }

    if (password != confirmPassword) {
      _showErrorSnackbar("Passwords do not match");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (kDebugMode) print("📝 Registering user: $email");

      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
        phone: phone,
      );

      if (response['status'] == true) {
        _showSuccessSnackbar("Account created! Please login.");
        if (kDebugMode) print("✅ Registration successful for $email");

        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      } else {
        final errorMsg = response['message'] ?? 'Registration failed';
        errorMessage.value = errorMsg;
        _showErrorSnackbar(errorMsg);
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = errorMsg;
      _showErrorSnackbar(errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendPasswordResetLink(String email) async {
    if (email.isEmpty) {
      _showErrorSnackbar("Please enter your email");
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiService.sendPasswordResetLink(email);

      if (response['status'] == true) {
        _showSuccessSnackbar("Password reset link sent to $email");
        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      } else {
        final errorMsg = response['message'] ?? 'Failed to send reset link';
        errorMessage.value = errorMsg;
        _showErrorSnackbar(errorMsg);
      }
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = errorMsg;
      _showErrorSnackbar(errorMsg);
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================
  // ✅ HELPER METHODS - Using ScaffoldMessenger (No Overlay issues)
  // ============================================

  void _showSuccessSnackbar(String message) {
    _showSnackbar(message, Colors.green[600]!, Icons.check_circle);
  }

  void _showErrorSnackbar(String message) {
    _showSnackbar(message, Colors.red[600]!, Icons.error);
  }

  void _showInfoSnackbar(String message) {
    _showSnackbar(message, Colors.blue[600]!, Icons.info);
  }

  void _showSnackbar(String message, Color color, IconData icon) {
    try {
      if (Get.context != null) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
              ],
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) print("⚠️ Could not show snackbar: $e");
    }
  }
}