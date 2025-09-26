import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:new_suvarnraj_group/controller/login_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/pages/aboutus_page.dart';
import 'package:new_suvarnraj_group/pages/login.dart';
import '../edit_profile_page.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();
    final loginCtrl = Get.put(LoginController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              // 🔹 Profile Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white, size: 35),
                  ),
                  SizedBox(width: 4.w),
                  Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userCtrl.name.value.isNotEmpty
                            ? userCtrl.name.value
                            : "Guest User",
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userCtrl.email.value.isNotEmpty
                            ? userCtrl.email.value
                            : "No email",
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  )),
                ],
              ),
              SizedBox(height: 3.h),

              // 🔹 Contact Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Contact Information",
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    SizedBox(height: 1.h),
                    _contactItem(Icons.phone, userCtrl.phone.value),
                    _contactItem(Icons.location_on, "123 Main Street, Mumbai"),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // 🔹 Menu Sections
              _ProfileMenuCard(
                children: [
                  _ProfileMenuItem(
                    icon: FontAwesomeIcons.userPen,
                    text: "Edit Profile",
                    bgColor: Colors.blue,
                    onTap: () async {
                      final updatedData = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilePage(
                            name: userCtrl.name.value,
                            email: userCtrl.email.value,
                            phone: userCtrl.phone.value,
                            address: "123 Main Street, Mumbai",
                          ),
                        ),
                      );

                      if (updatedData != null) {
                        userCtrl.name.value = updatedData['name'];
                        userCtrl.email.value = updatedData['email'];
                        userCtrl.phone.value = updatedData['phone'];
                      }
                    },
                  ),
                  _ProfileMenuItem(
                    icon: FontAwesomeIcons.bookOpen,
                    text: "My Bookings",
                    bgColor: Colors.green,
                  ),
                  _ProfileMenuItem(
                    icon: FontAwesomeIcons.heart,
                    text: "Favorites",
                    bgColor: Colors.pink,
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              _ProfileMenuCard(
                children: [
                  _ProfileMenuItem(
                    icon: FontAwesomeIcons.bell,
                    text: "Notifications",
                    bgColor: Colors.orange,
                  ),
                  _ProfileMenuItem(
                    icon: FontAwesomeIcons.headset,
                    text: "Support",
                    bgColor: Colors.purple,
                  ),
                  _ProfileMenuItem(
                    icon: FontAwesomeIcons.circleInfo,
                    text: "About Us",
                    bgColor: Colors.indigo,
                    onTap: () => Get.to(() => const AboutUsPage()),
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
                    onTap: () async {
                      // Show loader
                      Get.dialog(
                        const Center(child: CircularProgressIndicator()),
                        barrierDismissible: false,
                      );

                      await loginCtrl.logout();

                      Get.back(); // close loader
                      Get.offAll(() => const LoginPage());
                    },
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              Text("Version 1.0.0",
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue, size: 16),
          ),
          SizedBox(width: 3.w),
          Expanded(
              child: Text(text,
                  style: TextStyle(fontSize: 12.sp, color: Colors.black87))),
        ],
      ),
    );
  }
}

/// Menu Card Section
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(children: children),
    );
  }
}

/// Reusable Menu Item
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
      leading:
      CircleAvatar(radius: 18, backgroundColor: bgColor.withOpacity(0.15), child: Icon(icon, color: bgColor, size: 18)),
      title: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
