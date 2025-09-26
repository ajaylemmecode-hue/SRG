import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_suvarnraj_group/models/register_model.dart';
import '../api/api_register.dart';

class RegisterController extends GetxController {
  var isLoading = false.obs;

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    isLoading.value = true;
    try {
      final resMap = await ApiRegister.registerUser(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
      );

      final res = RegisterResponse.fromJson(resMap);

      if (res.status) {
        // save token & basic info
        final prefs = await SharedPreferences.getInstance();
        if (res.token != null) await prefs.setString('token', res.token!);
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        await prefs.setString('phone', phone);

        Get.snackbar("Success", res.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100);
        return true;
      } else {
        Get.snackbar("Error", res.message.isNotEmpty ? res.message : "Registration failed",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
