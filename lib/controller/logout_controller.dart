import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../api/api_logout.dart';
import 'user_controller.dart';

class LogoutController extends GetxController {
  var isLoading = false.obs;

  final UserController userCtrl =
  Get.isRegistered<UserController>() ? Get.find<UserController>() : Get.put(UserController());

  /// Logout user
  Future<bool> logoutUser() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      bool success = true;

      if (token.isNotEmpty) {
        success = await ApiLogout.logout(token);
        if (!success) {
          Get.snackbar("Warning", "Server logout failed, clearing local session",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade100);
        }
      }

      await prefs.clear();
      await userCtrl.logout();

      Get.snackbar("Success", "Logged out successfully ✅",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100);

      return success;
    } finally {
      isLoading.value = false;
    }
  }
}
