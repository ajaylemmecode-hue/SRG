import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_suvarnraj_group/controller/login_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';
import 'package:new_suvarnraj_group/pages/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isPasswordVisible = false;

  final userCtrl = Get.put(UserController());
  final loginCtrl = Get.put(LoginController());

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool("isLoggedIn");
    if (loggedIn == true) {
      await userCtrl.loadSession();
      Get.offAll(() => HomePage());
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
      }
      Get.snackbar("Success", "Signed in with Google 🎉",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100);
      Get.offAll(() => HomePage());
    } catch (error) {
      Get.snackbar("Error", "Google Sign-In Failed ❌",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
    }
  }

  // lib/pages/login.dart

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Please enter Email & Password");
      return;
    }
    await loginCtrl.login(email, password); // ✅ Navigation handled inside
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.jpg", height: 20.h),
              SizedBox(height: 3.h),
              Text("Welcome Back",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 1.h),
              Text("Sign in to your account",
                  style: TextStyle(color: Colors.grey, fontSize: 13.sp)),

              SizedBox(height: 4.h),

              // Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  hintText: "Enter your email",
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              SizedBox(height: 2.h),

              // Password
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  hintText: "Enter your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),

              SizedBox(height: 1.5.h),

              // Remember Me + Forgot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (value) =>
                            setState(() => rememberMe = value ?? false),
                      ),
                      Text("Remember me", style: TextStyle(fontSize: 12.sp)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const ForgotPasswordPage());
                    },
                    child: Text("Forgot Password?",
                        style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Sign In Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                  loginCtrl.isLoading.value ? null : () => _login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: loginCtrl.isLoading.value
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : Text("Sign In",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp)),
                ),
              )),

              SizedBox(height: 2.h),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Text("or", style: TextStyle(fontSize: 12.sp)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              SizedBox(height: 2.h),

              // Google Sign-In
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleGoogleSignIn,
                  icon: Image.network(
                    "https://cdn-icons-png.flaticon.com/512/300/300221.png",
                    height: 2.5.h,
                  ),
                  label: Text("Continue with Google",
                      style: TextStyle(fontSize: 13.sp)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Signup
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don’t have an account? ",
                      style: TextStyle(fontSize: 12.sp)),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const RegisterPage());
                    },
                    child: Text(
                      "Sign up now",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
