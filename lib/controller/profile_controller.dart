// lib/controller/profile_controller.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_profile.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var name = "".obs;
  var email = "".obs;
  var phone = "".obs;

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      if (token.isEmpty) return;

      final data = await ApiProfile.getProfile(token);

      if (data != null && data['data'] != null) {
        final user = data['data'];
        name.value = user['name'] ?? "";
        email.value = user['email'] ?? "";
        phone.value = user['phone'] ?? "";
      }
    } catch (e) {
      print("Error in ProfileController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
