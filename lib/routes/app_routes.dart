import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/main_container_screen.dart';
import '../screens/doctor_list_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/main',
      page: () => const MainContainerScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/doctors',
      page: () => const DoctorListScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
