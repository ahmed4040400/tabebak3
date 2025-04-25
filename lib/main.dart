import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:tabebak/controllers/chatbot_controller.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/doctor_list_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/patient_controller.dart';
import 'controllers/doctor_controller.dart';
import 'screens/chatbot_screen.dart';
import 'utils/firebase_seeder.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
    
    // Initialize seeder and check if we need to seed the database
    final seeder = FirebaseSeeder();
    if (await seeder.needsSeeding()) {
      print("Database needs seeding, starting seed process...");
      await seeder.seedDatabase();
    }
    
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Continue without Firebase if it fails to initialize
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(DoctorListController());
    Get.put(ChatbotController());
    
    // These controllers depend on Firebase, so wrap in try-catch
    try {
      Get.put(AdminController());
      Get.put(PatientController());
      Get.put(DoctorController());
    } catch (e) {
      print("Error initializing Firebase-dependent controllers: $e");
    }
    
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
