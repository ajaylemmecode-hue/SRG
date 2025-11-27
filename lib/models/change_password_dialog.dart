import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import '../controller/profile_controller.dart';

void showChangePasswordDialog(BuildContext context) {
  final profileCtrl = Get.find<ProfileController>();
  final currentPasswordCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool isCurrentVisible = false;
  bool isNewVisible = false;
  bool isConfirmVisible = false;

  Get.dialog(
    StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.lock_reset, color: Colors.blue, size: 28),
                    SizedBox(width: 2.w),
                    Text(
                      "Change Password",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),

                // Current Password
                TextField(
                  controller: currentPasswordCtrl,
                  obscureText: !isCurrentVisible,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    hintText: "Enter current password",
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(isCurrentVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => isCurrentVisible = !isCurrentVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 2.h),

                // New Password
                TextField(
                  controller: newPasswordCtrl,
                  obscureText: !isNewVisible,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    hintText: "Enter new password (min 6 chars)",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(isNewVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => isNewVisible = !isNewVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 2.h),

                // Confirm Password
                TextField(
                  controller: confirmPasswordCtrl,
                  obscureText: !isConfirmVisible,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    hintText: "Confirm new password",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(isConfirmVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => isConfirmVisible = !isConfirmVisible),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 3.h),

                // Buttons
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: profileCtrl.isLoading.value
                            ? null
                            : () {
                          currentPasswordCtrl.dispose();
                          newPasswordCtrl.dispose();
                          confirmPasswordCtrl.dispose();
                          Get.back();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Cancel", style: TextStyle(fontSize: 12.sp)),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: profileCtrl.isLoading.value
                            ? null
                            : () async {
                          final success = await profileCtrl.updatePassword(
                            currentPassword: currentPasswordCtrl.text.trim(),
                            newPassword: newPasswordCtrl.text.trim(),
                            confirmPassword: confirmPasswordCtrl.text.trim(),
                          );

                          if (success) {
                            currentPasswordCtrl.dispose();
                            newPasswordCtrl.dispose();
                            confirmPasswordCtrl.dispose();
                            Get.back();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: profileCtrl.isLoading.value
                            ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          "Update",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        );
      },
    ),
  );
}