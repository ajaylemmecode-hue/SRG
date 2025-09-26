import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart'; // <--- add this

import 'package:new_suvarnraj_group/controller/booking_controller.dart';
import 'package:new_suvarnraj_group/controller/cart_controller.dart';
import 'package:new_suvarnraj_group/controller/home_page_controller.dart';
import 'package:new_suvarnraj_group/controller/notification_controller.dart';
import 'package:new_suvarnraj_group/controller/user_controller.dart';
import 'package:new_suvarnraj_group/routes/app_pages.dart';
import 'package:new_suvarnraj_group/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init notifications
  await NotificationService.init();

  // register controllers globally
  Get.put(NotificationController());
  Get.put(HomePageController());
  Get.put(CartController());
  Get.put(BookingController());

  final userCtrl = Get.put(UserController());
  await userCtrl.loadSession();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap your app with Sizer
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          initialRoute: AppPages.INITIAL_ROUTES,
          getPages: AppPages.pages,
        );
      },
    );
  }
}