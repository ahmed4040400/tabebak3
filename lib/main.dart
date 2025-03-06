import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/doctor_list_controller.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(DoctorListController());
    Get.put(
      ChatbotController(),
    ); // Add this line to initialize ChatbotController

    return GetMaterialApp(
      title: 'Tabebak',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
