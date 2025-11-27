import 'package:get/get.dart';
import 'package:new_suvarnraj_group/pages/Splash_screens/splash_page.dart';
import 'package:new_suvarnraj_group/pages/home_page.dart';
import 'package:new_suvarnraj_group/binding/home_page_binding.dart';

class AppRoutes {
  static const String SPLASH_PAGE_ROUTE = '/splash_page_route';
  static const String HOME_PAGE_ROUTE = '/home_page_route';
}

class AppPages {
  static const String INITIAL_ROUTE = AppRoutes.SPLASH_PAGE_ROUTE;

  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH_PAGE_ROUTE,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.HOME_PAGE_ROUTE,
      page: () => const HomePage(),
      binding: HomePageBinding(),
    ),
  ];
}
