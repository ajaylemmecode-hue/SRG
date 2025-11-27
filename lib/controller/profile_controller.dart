// lib/controller/profile_controller.dart - COMPLETE FIXED

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:new_suvarnraj_group/api/api_profile.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/login.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var name = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var address = "".obs;
  var userId = 0.obs;

  late UserController userCtrl;

  @override
  void onInit() {
    super.onInit();
    userCtrl = Get.find<UserController>();

    // Load profile if user is logged in
    if (userCtrl.isLoggedIn.value && userCtrl.token.value.isNotEmpty) {
      fetchProfile();
    }

    // Listen for login changes
    ever(userCtrl.isLoggedIn, (isLoggedIn) {
      if (isLoggedIn && userCtrl.token.value.isNotEmpty) {
        fetchProfile();
      }
    });
  }

  /// ✅ FETCH PROFILE FROM API
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      if (kDebugMode) {
        print("👤 ProfileController: Fetching profile");
        print("   Token: ${userCtrl.token.value.isEmpty ? 'EMPTY' : 'Present'}");
      }

      if (userCtrl.token.value.isEmpty) {
        _handleUnauthorized();
        return;
      }

      final response = await ApiProfile.getProfile(userCtrl.token.value);

      if (response == null) {
        _handleUnauthorized();
        return;
      }

      // ✅ PARSE RESPONSE
      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        if (kDebugMode) {
          print("✅ Profile API Response received");
          print("   Keys: ${(data as Map?)?.keys.toList() ?? []}");
        }

        // 🔥 Handle nested 'user' object OR direct fields
        if (data is Map) {
          var userData = data;

          // If there's a 'user' wrapper
          if (data.containsKey('user') && data['user'] is Map) {
            userData = data['user'];
          }

          // Extract fields
          userId.value = userData['id'] ?? 0;
          name.value = userData['name'] ?? '';
          email.value = userData['email'] ?? '';
          phone.value = userData['phone'] ?? '';
          address.value = userData['address'] ?? '';

          if (kDebugMode) {
            print("✅ Profile loaded:");
            print("   ID: ${userId.value}");
            print("   Name: ${name.value}");
            print("   Email: ${email.value}");
            print("   Phone: ${phone.value}");
          }

          // Save to cache
          await _saveToCache();
        }
      } else {
        _handleUnauthorized();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Fetch profile error: $e");
      Get.snackbar("Error", "Failed to load profile");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ UPDATE PROFILE
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    try {
      isLoading.value = true;

      if (userCtrl.token.value.isEmpty) {
        _handleUnauthorized();
        return false;
      }

      if (kDebugMode) {
        print("👤 Updating profile:");
        print("   Name: $name");
        print("   Email: $email");
        print("   Phone: $phone");
      }

      final response = await ApiProfile.updateProfile(
        token: userCtrl.token.value,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

      if (response == null) {
        _handleUnauthorized();
        return false;
      }

      if (response['status'] == true) {
        // Update local state
        if (name != null && name.isNotEmpty) this.name.value = name;
        if (email != null && email.isNotEmpty) this.email.value = email;
        if (phone != null && phone.isNotEmpty) this.phone.value = phone;
        if (address != null && address.isNotEmpty) this.address.value = address;

        await _saveToCache();

        if (kDebugMode) print("✅ Profile updated successfully");

        Get.snackbar(
          "✅ Success",
          "Profile updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        Get.snackbar(
          "❌ Error",
          response['message'] ?? 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("❌ Update error: $e");
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ UPDATE PASSWORD
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // 🔹 Validation
    if (currentPassword.isEmpty) {
      Get.snackbar("Error", "Current password is required");
      return false;
    }
    if (newPassword.length < 6) {
      Get.snackbar("Error", "New password must be at least 6 characters");
      return false;
    }
    if (newPassword != confirmPassword) {
      Get.snackbar("Error", "Passwords do not match");
      return false;
    }

    try {
      isLoading.value = true;

      if (userCtrl.token.value.isEmpty) {
        _handleUnauthorized();
        return false;
      }

      if (kDebugMode) print("🔑 Updating password...");

      final response = await ApiProfile.updatePassword(
        token: userCtrl.token.value,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response == null) {
        _handleUnauthorized();
        return false;
      }

      if (response['status'] == true) {
        if (kDebugMode) print("✅ Password updated successfully");

        Get.snackbar(
          "✅ Success",
          "Password updated successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          duration: const Duration(seconds: 2),
        );

        return true;
      } else {
        Get.snackbar(
          "❌ Error",
          response['message'] ?? 'Failed to update password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) print("❌ Password update error: $e");
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ SAVE TO CACHE
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', name.value);
      await prefs.setString('profile_email', email.value);
      await prefs.setString('profile_phone', phone.value);
      await prefs.setString('profile_address', address.value);
      await prefs.setInt('profile_id', userId.value);

      if (kDebugMode) print("✅ Profile saved to cache");
    } catch (e) {
      if (kDebugMode) print("⚠️ Cache save error: $e");
    }
  }

  /// ✅ LOAD FROM CACHE
  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name.value = prefs.getString('profile_name') ?? '';
      email.value = prefs.getString('profile_email') ?? '';
      phone.value = prefs.getString('profile_phone') ?? '';
      address.value = prefs.getString('profile_address') ?? '';
      userId.value = prefs.getInt('profile_id') ?? 0;

      if (kDebugMode) print("✅ Profile loaded from cache");
    } catch (e) {
      if (kDebugMode) print("⚠️ Cache load error: $e");
    }
  }

  /// ✅ HANDLE UNAUTHORIZED
  void _handleUnauthorized() {
    Get.snackbar(
      "⚠️ Session Expired",
      "Please login again",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[900],
    );
    Get.offAll(() => const LoginPage());
  }

  /// ✅ CLEAR PROFILE
  Future<void> clearProfile() async {
    name.value = '';
    email.value = '';
    phone.value = '';
    address.value = '';
    userId.value = 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_name');
      await prefs.remove('profile_email');
      await prefs.remove('profile_phone');
      await prefs.remove('profile_address');
      await prefs.remove('profile_id');
    } catch (e) {
      if (kDebugMode) print("⚠️ Clear cache error: $e");
    }
  }
}