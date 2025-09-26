import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var isLoggedIn = false.obs;
  var name = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var token = "".obs;

  String get userEmail => email.value;

  /// Save session
  Future<void> login({
    required String userName,
    required String userEmail,
    required String userPhone,
    String? userToken,
  }) async {
    name.value = userName;
    email.value = userEmail;
    phone.value = userPhone;
    if (userToken != null) token.value = userToken;
    isLoggedIn.value = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("name", userName);
    await prefs.setString("email", userEmail);
    await prefs.setString("phone", userPhone);
    if (userToken != null) await prefs.setString("token", userToken);
  }

  /// Clear session
  Future<void> logout() async {
    name.value = "";
    email.value = "";
    phone.value = "";
    token.value = "";
    isLoggedIn.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Load session
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool("isLoggedIn");
    if (loggedIn == true) {
      name.value = prefs.getString("name") ?? "";
      email.value = prefs.getString("email") ?? "";
      phone.value = prefs.getString("phone") ?? "";
      token.value = prefs.getString("token") ?? "";
      isLoggedIn.value = true;
    }
  }
}
