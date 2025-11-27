// ✅ lib/pages/tabs/profile_tab.dart - PROFESSIONAL & RESPONSIVE

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/profile_controller.dart';
import 'package:new_suvarnraj_group/controller/login_controller.dart';
import 'package:new_suvarnraj_group/controller/logout_controller.dart';
import '../FavoritesPage.dart';
import '../supportpage.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late ProfileController profileCtrl;
  late LoginController loginCtrl;

  @override
  void initState() {
    super.initState();
    profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    loginCtrl = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Obx(() {
          if (profileCtrl.isLoading.value && profileCtrl.name.value.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => profileCtrl.fetchProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                children: [
                  // 🔹 ENHANCED PROFILE HEADER
                  _buildProfileHeader(),

                  SizedBox(height: 3.h),

                  // 🔹 ENHANCED CONTACT INFO CARD
                  _buildContactInfoCard(),

                  SizedBox(height: 2.h),

                  // 🔹 Menu Sections
                  _ProfileMenuCard(
                    children: [
                      _ProfileMenuItem(
                        icon: FontAwesomeIcons.userPen,
                        text: "Edit Profile",
                        bgColor: Colors.blue,
                        onTap: () => _showEditProfileDialog(),
                      ),
                      _ProfileMenuItem(
                        icon: FontAwesomeIcons.key,
                        text: "Change Password",
                        bgColor: Colors.deepOrange,
                        onTap: () => _showChangePasswordDialog(),
                      ),
                      _ProfileMenuItem(
                        icon: FontAwesomeIcons.bookOpen,
                        text: "My Bookings",
                        bgColor: Colors.green,
                        onTap: () {
                          Get.snackbar("Info", "Bookings page coming soon");
                        },
                      ),
                      _ProfileMenuItem(
                        icon: FontAwesomeIcons.heart,
                        text: "Favorites",
                        bgColor: Colors.pink,
                        onTap: () {
                          Get.to(
                                () => const FavoritesPage(),
                            transition: Transition.rightToLeft,
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  _ProfileMenuCard(
                    children: [
                      // _ProfileMenuItem(
                      //   icon: FontAwesomeIcons.bell,
                      //   text: "Notifications",
                      //   bgColor: Colors.orange,
                      //   onTap: () {
                      //     Get.snackbar("Info", "Notifications page coming soon");
                      //   },
                      // ),
                      _ProfileMenuItem(
                        icon: FontAwesomeIcons.headset,
                        text: "Support",
                        bgColor: Colors.purple,
                        onTap: () {
                          // ✅ REPLACE THE OLD onTap WITH THIS:
                          Get.to(
                                () => const SupportPage(),
                            transition: Transition.rightToLeft,
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  _ProfileMenuCard(
                    children: [
                      _ProfileMenuItem(
                        icon: FontAwesomeIcons.arrowRightFromBracket,
                        text: "Logout",
                        color: Colors.red,
                        bgColor: Colors.red.shade50,
                        onTap: () => _showLogoutDialog(),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[400]),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ✅ ENHANCED PROFILE HEADER WITH GRADIENT
  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Text(
                profileCtrl.name.value.isNotEmpty
                    ? profileCtrl.name.value[0].toUpperCase()
                    : 'G',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  profileCtrl.name.value.isNotEmpty
                      ? profileCtrl.name.value
                      : "Guest User",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                // Email - ENHANCED SIZE
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.white.withOpacity(0.9),
                      size: 14.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        profileCtrl.email.value.isNotEmpty
                            ? profileCtrl.email.value
                            : "No email",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ ENHANCED CONTACT INFO CARD
  Widget _buildContactInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.contact_phone,
                  color: Colors.blue[600],
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                "Contact Information",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _contactItem(
            Icons.phone_android,
            profileCtrl.phone.value.isNotEmpty
                ? profileCtrl.phone.value
                : "No phone added",
          ),
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue[600], size: 18.sp),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ EDIT PROFILE DIALOG
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: profileCtrl.name.value);
    final emailCtrl = TextEditingController(text: profileCtrl.email.value);
    final phoneCtrl = TextEditingController(text: profileCtrl.phone.value);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue, size: 28),
                      SizedBox(width: 3.w),
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email is required";
                      }
                      if (!GetUtils.isEmail(value)) {
                        return "Invalid email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone",
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Phone is required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: profileCtrl.isLoading.value
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: profileCtrl.isLoading.value
                              ? null
                              : () async {
                            if (formKey.currentState!.validate()) {
                              final success =
                              await profileCtrl.updateProfile(
                                name: nameCtrl.text.trim(),
                                email: emailCtrl.text.trim(),
                                phone: phoneCtrl.text.trim(),
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
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
                            "Save",
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
          ),
        ),
      ),
    );
  }

  // ✅ CHANGE PASSWORD DIALOG
  void _showChangePasswordDialog() {
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool showCurrent = false;
    bool showNew = false;
    bool showConfirm = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_reset, color: Colors.blue, size: 28),
                      SizedBox(width: 3.w),
                      Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  TextFormField(
                    controller: currentPwdCtrl,
                    obscureText: !showCurrent,
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showCurrent ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => showCurrent = !showCurrent),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Current password required";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: newPwdCtrl,
                    obscureText: !showNew,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showNew ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(() => showNew = !showNew),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Min 6 characters",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "New password required";
                      }
                      if (value.length < 6) {
                        return "Min 6 characters";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: confirmPwdCtrl,
                    obscureText: !showConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showConfirm ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => showConfirm = !showConfirm),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm password";
                      }
                      if (value != newPwdCtrl.text) {
                        return "Passwords don't match";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 3.h),
                  Obx(() => Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: profileCtrl.isLoading.value
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: profileCtrl.isLoading.value
                              ? null
                              : () async {
                            if (formKey.currentState!.validate()) {
                              final success =
                              await profileCtrl.updatePassword(
                                currentPassword:
                                currentPwdCtrl.text.trim(),
                                newPassword: newPwdCtrl.text.trim(),
                                confirmPassword:
                                confirmPwdCtrl.text.trim(),
                              );
                              if (success && context.mounted) {
                                Navigator.pop(context);
                              }
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
          ),
        ),
      ),
    );
  }

  // ✅ LOGOUT DIALOG
  void _showLogoutDialog() {
    final logoutCtrl = Get.isRegistered<LogoutController>()
        ? Get.find<LogoutController>()
        : Get.put(LogoutController());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red, size: 28),
            SizedBox(width: 3.w),
            const Text("Logout"),
          ],
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: logoutCtrl.isLoading.value
                ? null
                : () async {
              Navigator.pop(context);
              await logoutCtrl.logoutUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: logoutCtrl.isLoading.value
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          )),
        ],
      ),
    );
  }
}

// ✅ PROFILE MENU CARD
class _ProfileMenuCard extends StatelessWidget {
  final List<Widget> children;
  const _ProfileMenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ✅ ENHANCED PROFILE MENU ITEM
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.text,
    this.color = Colors.black,
    this.bgColor = Colors.blue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      leading: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: bgColor, size: 20.sp),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
          letterSpacing: 0.2,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}