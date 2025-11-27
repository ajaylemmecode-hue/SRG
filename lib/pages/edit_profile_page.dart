import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controller/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  final _formKey = GlobalKey<FormState>();
  bool hasChanges = false;

  final ProfileController profileCtrl = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();

    // Initialize from ProfileController
    nameController = TextEditingController(text: profileCtrl.name.value);
    emailController = TextEditingController(text: profileCtrl.email.value);
    phoneController = TextEditingController(text: profileCtrl.phone.value);

    // Listen for changes
    nameController.addListener(_checkChanges);
    emailController.addListener(_checkChanges);
    phoneController.addListener(_checkChanges);
  }

  void _checkChanges() {
    setState(() {
      hasChanges = nameController.text.trim() != profileCtrl.name.value.trim() ||
          emailController.text.trim() != profileCtrl.email.value.trim() ||
          phoneController.text.trim() != profileCtrl.phone.value.trim();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (!hasChanges) {
      Get.snackbar(
        "No Changes",
        "No changes were made to save",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    final success = await profileCtrl.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
    );

    if (success) {
      // Return to previous page with success indicator
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          children: [
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final displayName = nameController.text.isNotEmpty
                        ? nameController.text
                        : profileCtrl.name.value;
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'G',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Center(
              child: Text(
                "Tap to change photo",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Personal Info Section
            _buildSectionTitle("Personal Information"),
            SizedBox(height: 1.h),

            _buildTextField(
              controller: nameController,
              label: "Full Name",
              hint: "Enter your full name",
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Name is required";
                }
                if (value.trim().length < 3) {
                  return "Name must be at least 3 characters";
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            _buildTextField(
              controller: emailController,
              label: "Email Address",
              hint: "Enter your email",
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email is required";
                }
                if (!GetUtils.isEmail(value.trim())) {
                  return "Enter a valid email";
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),

            _buildTextField(
              controller: phoneController,
              label: "Phone Number",
              hint: "Enter your phone number",
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Phone number is required";
                }
                if (value.trim().length < 10) {
                  return "Enter a valid 10+ digit phone number";
                }
                return null;
              },
            ),
            SizedBox(height: 4.h),

            // Save Button
            Obx(() {
              return ElevatedButton(
                onPressed: profileCtrl.isLoading.value || !hasChanges
                    ? null
                    : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasChanges ? Colors.blue : Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: profileCtrl.isLoading.value
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            SizedBox(height: 2.h),

            // Cancel Button
            OutlinedButton(
              onPressed: () => Get.back(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue, size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.8.h,
          ),
          labelStyle: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
          hintStyle: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade400,
          ),
        ),
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.black87,
        ),
      ),
    );
  }
}