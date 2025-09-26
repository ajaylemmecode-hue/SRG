import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_suvarnraj_group/controller/register_controller.dart';
import 'package:new_suvarnraj_group/pages/login.dart';
import 'package:sizer/sizer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeTerms = false;

  final registerCtrl = Get.put(RegisterController());

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
              Image.asset("assets/images/logo.jpg", height: 8.h),
              SizedBox(height: 3.h),

              Text("Create Account",
                  style:
                  TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 0.5.h),
              Text("Join us for better cleaning services",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp)),

              SizedBox(height: 3.h),

              // Full Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  hintText: "Enter your full name",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              SizedBox(height: 2.h),

              // Email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              SizedBox(height: 2.h),

              // Phone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Enter your phone number",
                  prefixIcon: Icon(Icons.phone_outlined),
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
                  hintText: "Create a password",
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
              SizedBox(height: 2.h),

              // Confirm Password
              TextField(
                controller: confirmPasswordController,
                obscureText: !isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  hintText: "Confirm your password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(() =>
                    isConfirmPasswordVisible = !isConfirmPasswordVisible),
                  ),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),

              SizedBox(height: 1.5.h),

              // Terms & Privacy
              Row(
                children: [
                  Checkbox(
                    value: agreeTerms,
                    onChanged: (value) =>
                        setState(() => agreeTerms = value ?? false),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text("I agree to the ",
                            style: TextStyle(fontSize: 11.sp)),
                        Text("Terms of Service",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp)),
                        Text(" and ",
                            style: TextStyle(fontSize: 11.sp)),
                        Text("Privacy Policy",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 11.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Create Account Button
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registerCtrl.isLoading.value
                      ? null
                      : () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final phone = phoneController.text.trim();
                    final password = passwordController.text.trim();
                    final confirmPassword =
                    confirmPasswordController.text.trim();

                    if (name.isEmpty ||
                        email.isEmpty ||
                        phone.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty) {
                      Get.snackbar("Error", "All fields are required ❌",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade100);
                      return;
                    }

                    if (password != confirmPassword) {
                      Get.snackbar("Error", "Passwords do not match ❌",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade100);
                      return;
                    }

                    if (!agreeTerms) {
                      Get.snackbar("Error",
                          "Please accept Terms & Privacy Policy ❌",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.shade100);
                      return;
                    }

                    final success = await registerCtrl.register(
                      name: name,
                      email: email,
                      phone: phone,
                      password: password,
                      confirmPassword: confirmPassword,
                    );

                    if (success) Get.off(() => const LoginPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: registerCtrl.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text("Create Account",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp)),
                ),
              )),

              SizedBox(height: 3.h),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style: TextStyle(fontSize: 12.sp)),
                  GestureDetector(
                    onTap: () {
                      Get.off(() => const LoginPage());
                    },
                    child: Text(" Sign In",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp)),
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
