// ✅ lib/controller/user_controller.dart - FIXED WITH userData

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  var isLoggedIn = false.obs;
  var name = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var token = "".obs;

  // ✅ NEW: userData Map to store complete user info
  var userData = <String, dynamic>{}.obs;

  String get userEmail => email.value;
  String get userName => name.value;
  String get userPhone => phone.value;
  String get userToken => token.value;

  @override
  void onInit() {
    super.onInit();
    loadSession(); // Auto-load session on init
  }

  /// ✅ Save session (called after login)
  Future<void> login({
    required String userName,
    required String userEmail,
    required String userPhone,
    String? userToken,
    Map<String, dynamic>? userInfo,
  }) async {
    try {
      name.value = userName;
      email.value = userEmail;
      phone.value = userPhone;
      if (userToken != null) token.value = userToken;
      isLoggedIn.value = true;

      // ✅ Store complete user data
      userData.assignAll({
        'name': userName,
        'email': userEmail,
        'phone': userPhone,
        'first_name': userInfo?['first_name'] ?? '',
        'last_name': userInfo?['last_name'] ?? '',
        ...?userInfo,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", true);
      await prefs.setString("name", userName);
      await prefs.setString("email", userEmail);
      await prefs.setString("phone", userPhone);
      if (userToken != null) await prefs.setString("token", userToken);

      print("✅ UserController: Session saved for $userName");
    } catch (e) {
      print("❌ UserController login error: $e");
    }
  }

  /// ✅ Clear session (called after logout)
  Future<void> logout() async {
    try {
      name.value = "";
      email.value = "";
      phone.value = "";
      token.value = "";
      isLoggedIn.value = false;
      userData.clear();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print("✅ UserController: Session cleared");
    } catch (e) {
      print("❌ UserController logout error: $e");
    }
  }

  /// ✅ Load session from SharedPreferences
  Future<void> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool? loggedIn = prefs.getBool("isLoggedIn");

      if (loggedIn == true) {
        final loadedName = prefs.getString("name") ?? "";
        final loadedEmail = prefs.getString("email") ?? "";
        final loadedPhone = prefs.getString("phone") ?? "";
        final loadedToken = prefs.getString("token") ?? "";

        name.value = loadedName;
        email.value = loadedEmail;
        phone.value = loadedPhone;
        token.value = loadedToken;
        isLoggedIn.value = true;

        // ✅ Populate userData
        userData.assignAll({
          'name': loadedName,
          'email': loadedEmail,
          'phone': loadedPhone,
          'first_name': loadedName.split(' ').first,
          'last_name': loadedName.split(' ').length > 1
              ? loadedName.split(' ').sublist(1).join(' ')
              : '',
        });

        print("✅ UserController: Session loaded - $loadedName");
      } else {
        print("ℹ️ UserController: No active session found");
      }
    } catch (e) {
      print("❌ UserController loadSession error: $e");
    }
  }

  /// ✅ Update user data (called after profile update or API fetch)
  Future<void> updateUserData({
    String? userName,
    String? userEmail,
    String? userPhone,
    Map<String, dynamic>? userInfo,
  }) async {
    try {
      if (userName != null) name.value = userName;
      if (userEmail != null) email.value = userEmail;
      if (userPhone != null) phone.value = userPhone;

      // ✅ Update userData map
      userData.assignAll({
        if (userName != null) 'name': userName,
        if (userEmail != null) 'email': userEmail,
        if (userPhone != null) 'phone': userPhone,
        if (userName != null) 'first_name': userName.split(' ').first,
        if (userName != null && userName.split(' ').length > 1)
          'last_name': userName.split(' ').sublist(1).join(' '),
        ...?userInfo,
      });

      final prefs = await SharedPreferences.getInstance();
      if (userName != null) await prefs.setString('name', userName);
      if (userEmail != null) await prefs.setString('email', userEmail);
      if (userPhone != null) await prefs.setString('phone', userPhone);

      print("✅ UserController: User data updated");
    } catch (e) {
      print("❌ UserController updateUserData error: $e");
    }
  }

  /// ✅ Update userData from API response
  void setUserDataFromApi(Map<String, dynamic> apiData) {
    userData.assignAll({
      'name': apiData['name'] ?? apiData['full_name'] ?? '',
      'email': apiData['email'] ?? '',
      'phone': apiData['phone'] ?? apiData['mobile'] ?? '',
      'first_name': apiData['first_name'] ??
          (apiData['name']?.toString().split(' ').first ?? ''),
      'last_name': apiData['last_name'] ??
          (apiData['name']?.toString().split(' ').length ?? 0) > 1
          ? (apiData['name']?.toString().split(' ').sublist(1).join(' ') ?? '')
          : '',
      ...apiData,
    });
    print("✅ UserController: User data set from API");
  }

  /// ✅ Check if user has valid session
  bool hasValidSession() {
    return isLoggedIn.value && token.value.isNotEmpty;
  }

  /// ✅ Get user first name
  String getFirstName() {
    return userData['first_name']?.toString() ??
        name.value.split(' ').first ?? '';
  }

  /// ✅ Get user last name
  String getLastName() {
    return userData['last_name']?.toString() ??
        (name.value.split(' ').length > 1
            ? name.value.split(' ').sublist(1).join(' ')
            : '');
  }
}