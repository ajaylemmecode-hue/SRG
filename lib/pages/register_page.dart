import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeTerms = false;

  final registerCtrl = Get.put(RegisterController());

  // Validation Methods
  String? validateName(String value) {
    if (value.isEmpty) return "Name is required";
    if (value.length < 3) return "Name must be at least 3 characters";
    // Only letters and spaces allowed
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Name can only contain letters";
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) return "Email is required";
    // Email regex pattern
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Enter a valid email address";
    }
    return null;
  }

  String? validatePhone(String value) {
    if (value.isEmpty) return "Phone number is required";
    // Must be exactly 10 digits
    if (value.length != 10) return "Phone number must be 10 digits";
    // Must start with 6, 7, 8, or 9
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
      return "Invalid phone number format";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return "Password is required";
    if (value.length < 6) return "Password must be at least 6 characters";
    // Optional: Add more password strength requirements
    // if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
    //   return "Password must contain letters and numbers";
    // }
    return null;
  }

  String? validateConfirmPassword(String value, String password) {
    if (value.isEmpty) return "Confirm password is required";
    if (value != password) return "Passwords do not match";
    return null;
  }

  void handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validate Name
    final nameError = validateName(name);
    if (nameError != null) {
      Get.snackbar("Validation Error", nameError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          icon: Icon(Icons.error_outline, color: Colors.red));
      return;
    }

    // Validate Email
    final emailError = validateEmail(email);
    if (emailError != null) {
      Get.snackbar("Validation Error", emailError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          icon: Icon(Icons.error_outline, color: Colors.red));
      return;
    }

    // Validate Phone
    final phoneError = validatePhone(phone);
    if (phoneError != null) {
      Get.snackbar("Validation Error", phoneError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          icon: Icon(Icons.error_outline, color: Colors.red));
      return;
    }

    // Validate Password
    final passwordError = validatePassword(password);
    if (passwordError != null) {
      Get.snackbar("Validation Error", passwordError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          icon: Icon(Icons.error_outline, color: Colors.red));
      return;
    }

    // Validate Confirm Password
    final confirmPasswordError = validateConfirmPassword(confirmPassword, password);
    if (confirmPasswordError != null) {
      Get.snackbar("Validation Error", confirmPasswordError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          icon: Icon(Icons.error_outline, color: Colors.red));
      return;
    }

    // Check Terms Agreement
    if (!agreeTerms) {
      Get.snackbar("Terms Required", "Please accept Terms & Privacy Policy",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
          icon: Icon(Icons.warning_amber, color: Colors.orange));
      return;
    }

    // All validations passed - proceed with registration
    final success = await registerCtrl.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (success) Get.off(() => const LoginPage());
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
              Image.asset("assets/images/logo.jpg", height: 8.h),
              SizedBox(height: 3.h),

              Text("Create Account",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 0.5.h),
              Text("Join us for better cleaning services",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp)),

              SizedBox(height: 3.h),

              // Full Name - Only Letters
              TextField(
                controller: nameController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                ],
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
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  hintText: "Enter your email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              SizedBox(height: 2.h),

              // Phone - Only Numbers, Max 10 digits
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  hintText: "Enter 10-digit mobile number",
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: "", // Hide character counter
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
                  hintText: "Create a password (min 6 characters)",
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
                        Text(" and ", style: TextStyle(fontSize: 11.sp)),
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
                  onPressed: registerCtrl.isLoading.value ? null : handleRegister,
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