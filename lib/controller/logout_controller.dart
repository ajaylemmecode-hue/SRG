// lib/controller/logout_controller.dart - COMPLETE FIXED

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_suvarnraj_group/api/api_service.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/login.dart';

class LogoutController extends GetxController {
  var isLoading = false.obs;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();
  }

  /// ✅ LOGOUT USER - COMPLETE FIX
  Future<bool> logoutUser() async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print("🚪 LogoutController: Starting logout");
        print("   Token: ${userCtrl.token.value.isEmpty ? 'EMPTY' : 'Present'}");
      }

      final prefs = await SharedPreferences.getInstance();
      final token = userCtrl.token.value;

      // 🔥 Call API logout if token exists
      if (token.isNotEmpty) {
        try {
          if (kDebugMode) print("📡 Calling API logout endpoint");

          final response = await ApiService.logout(token);

          if (kDebugMode) {
            print("✅ API Response: ${response['status']}");
            print("   Message: ${response['message']}");
          }

          if (response['status'] != true) {
            Get.snackbar(
              "⚠️ Warning",
              "Server logout had issues, clearing local session",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange[100],
              colorText: Colors.orange[900],
              duration: const Duration(seconds: 2),
            );
          }
        } catch (e) {
          if (kDebugMode) print("⚠️ API logout error: $e");
          Get.snackbar(
            "⚠️ Warning",
            "Could not reach server, clearing local session",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange[100],
            colorText: Colors.orange[900],
            duration: const Duration(seconds: 2),
          );
        }
      }

      // ✅ CLEAR LOCAL DATA (ALWAYS)
      if (kDebugMode) print("🗑️ Clearing local data");

      // Clear SharedPreferences
      await prefs.clear();

      // Clear UserController
      await userCtrl.logout();

      if (kDebugMode) print("✅ Local data cleared");

      // ✅ SHOW SUCCESS MESSAGE
      Get.snackbar(
        "✅ Success",
        "Logged out successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
        duration: const Duration(seconds: 2),
      );

      if (kDebugMode) print("✅ Logout completed, navigating to login");

      // ⏱️ Wait for snackbar to show, then navigate
      await Future.delayed(const Duration(milliseconds: 500));

      // ✅ NAVIGATE TO LOGIN (MOST IMPORTANT!)
      Get.offAll(
            () => const LoginPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );

      return true;
    } catch (e) {
      if (kDebugMode) print("❌ Logout error: $e");

      Get.snackbar(
        "❌ Error",
        "Logout failed: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ LOGOUT FROM PROFILE PAGE - DIRECT METHOD
  Future<void> logoutFromProfile() async {
    if (isLoading.value) return;
    await logoutUser();
  }
}