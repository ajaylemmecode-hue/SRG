import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../api/api_login.dart';
import '../api/api_logout.dart';
import '../models/login_model.dart';
import 'user_controller.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  final UserController userCtrl =
  Get.isRegistered<UserController>() ? Get.find<UserController>() : Get.put(UserController());

  /// Login user
  Future<bool> login(String email, String password, {bool rememberMe = true}) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email & Password required",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      return false;
    }

    isLoading.value = true;
    try {
      final resMap = await ApiLogin.loginUser(email: email, password: password);
      final res = LoginResponse.fromJson(resMap);

      if (res.status && res.token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString('token', res.token!);

        // Extract user details from "data.user"
        final userData = res.data?['user'] ?? {};
        final name = (userData['name'] ?? '').toString();
        final userEmail = (userData['email'] ?? email).toString();
        final phone = (userData['phone'] ?? '').toString();

        await prefs.setString('name', name);
        await prefs.setString('email', userEmail);
        await prefs.setString('phone', phone);

        await userCtrl.login(
          userName: name,
          userEmail: userEmail,
          userPhone: phone,
          userToken: res.token,
        );

        Get.snackbar("Success", res.message,
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);

        return true;
      } else {
        Get.snackbar("Error", res.message.isNotEmpty ? res.message : "Login failed ❌",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      bool success = await ApiLogout.logout(token);
      if (!success) {
        Get.snackbar("Warning", "Server logout failed, clearing local session",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade100);
      }
    }

    await prefs.clear();
    await userCtrl.logout();

    Get.snackbar("Success", "Logged out successfully ✅",
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
  }
}
