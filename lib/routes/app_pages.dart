import 'package:new_suvarnraj_group/binding/home_page_binding.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';
import 'package:new_suvarnraj_group/pages/Splash_screens/splash_page.dart';
import 'package:new_suvarnraj_group/routes/app_routes.dart';
import 'package:get/get.dart';
class AppPages
{
  static String INITIAL_ROUTES = AppRoutes.SPLASH_PAGE_ROUTE;
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH_PAGE_ROUTE,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.HOME_PAGE_ROUTE,
      page: () => HomePage(),
      binding: HomePageBinding(),
    ),
  ];

}