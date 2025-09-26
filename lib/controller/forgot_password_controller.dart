import 'package:get/get.dart';
import '../api/api_forgot_password.dart';


class ForgotPasswordController extends GetxController {
  var isLoading = false.obs;

  Future<Map<String, dynamic>> sendForgotPassword(String email) async {
    if (email.isEmpty) {
      return {"status": false, "message": "Email is required"};
    }

    isLoading.value = true;
    final res = await ForgotPasswordApi.sendResetLink(email);
    isLoading.value = false;
    return res;
  }
}
