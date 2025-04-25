import 'package:get/get.dart';
import '../screens/login_screen.dart';
import '../screens/main_container_screen.dart';
import '../screens/doctor_list_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/doctor_dashboard_screen.dart';
import '../screens/patient_profile_screen.dart';
import '../screens/book_appointment_screen.dart';

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
    GetPage(
      name: '/admin',
      page: () => const AdminScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/doctor-dashboard',
      page: () => const DoctorDashboardScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/patient-profile',
      page: () => const PatientProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/book-appointment',
      page: () => const BookAppointmentScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
