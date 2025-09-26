import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controller/forgot_password_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final forgotCtrl = Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5.h),

            Image.asset("assets/images/logo.jpg", height: 15.h),
            SizedBox(height: 3.h),

            Text("Forgot Your Password?",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Text(
              "Enter your registered email. We will send a password reset link to your inbox.",
              style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email Address",
                hintText: "Enter your registered email",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            Obx(() {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: forgotCtrl.isLoading.value
                      ? null
                      : () async {
                    final res = await forgotCtrl
                        .sendForgotPassword(emailController.text.trim());

                    if (res["status"]) {
                      Get.snackbar(
                        "Success",
                        "Password reset link has been sent to your email. Please check inbox/spam.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.shade100,
                      );
                    } else {
                      Get.snackbar(
                        "Error",
                        res["message"],
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.shade100,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: forgotCtrl.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Send Reset Link",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
