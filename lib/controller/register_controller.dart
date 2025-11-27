// lib/controller/register_controller.dart - COMPLETE FIXED

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_suvarnraj_group/api/api_service.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';

class RegisterController extends GetxController {
  var isLoading = false.obs;
  var errorMsg = ''.obs;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();
  }

  /// ✅ REGISTER USER - COMPLETE FIX
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    // 🔹 CLIENT-SIDE VALIDATION
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      errorMsg.value = 'All fields are required';
      Get.snackbar(
        "❌ Error",
        "Please fill all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    if (password != confirmPassword) {
      errorMsg.value = 'Passwords do not match';
      Get.snackbar(
        "❌ Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    if (password.length < 6) {
      errorMsg.value = 'Password must be at least 6 characters';
      Get.snackbar(
        "❌ Error",
        "Password must be at least 6 characters",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    if (!email.contains('@')) {
      errorMsg.value = 'Invalid email address';
      Get.snackbar(
        "❌ Error",
        "Invalid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return false;
    }

    isLoading.value = true;
    errorMsg.value = '';

    try {
      if (kDebugMode) {
        print("📝 RegisterController: Registering user");
        print("   Email: $email");
        print("   Phone: $phone");
      }

      // ✅ CALL API
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
        phone: phone,
      );

      if (kDebugMode) {
        print("✅ API Response:");
        print("   Status: ${response['status']}");
        print("   Message: ${response['message']}");
      }

      // ✅ CHECK RESPONSE
      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        // 🔥 Extract token and user data
        final token = data['token']?.toString() ?? '';
        final userName = data['user']?['name'] ?? data['name'] ?? name;
        final userEmail = data['user']?['email'] ?? data['email'] ?? email;
        final userPhone = data['user']?['phone'] ?? data['phone'] ?? phone;

        if (kDebugMode) {
          print("✅ Registration successful!");
          print("   Token: ${token.substring(0, 20)}...");
          print("   Name: $userName");
        }

        // ✅ SAVE TO USERCONTROLLER (MOST IMPORTANT!)
        await userCtrl.login(
          userName: userName,
          userEmail: userEmail,
          userPhone: userPhone,
          userToken: token,
        );

        // ✅ ALSO SAVE TO CACHE
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', token);
        await prefs.setString('name', userName);
        await prefs.setString('email', userEmail);
        await prefs.setString('phone', userPhone);

        if (kDebugMode) print("✅ Data saved to cache and UserController");

        // ✅ SHOW SUCCESS
        Get.snackbar(
          "✅ Registration Successful",
          "Welcome $userName! Redirecting...",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );

        // ✅ NAVIGATE TO HOME
        await Future.delayed(const Duration(seconds: 1));
        Get.offAll(() => const HomePage());

        return true;
      } else {
        final errorMessage = response['message'] ?? 'Registration failed';
        errorMsg.value = errorMessage;

        if (kDebugMode) print("❌ Registration failed: $errorMessage");

        Get.snackbar(
          "❌ Registration Failed",
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          duration: const Duration(seconds: 3),
        );

        return false;
      }
    } catch (e) {
      final error = e.toString().replaceAll('Exception: ', '');
      errorMsg.value = error;

      if (kDebugMode) print("❌ Registration error: $e");

      Get.snackbar(
        "❌ Error",
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }
}