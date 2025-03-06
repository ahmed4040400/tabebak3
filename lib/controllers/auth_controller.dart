import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  Future<String?> authUser(LoginData data) {
    // This is a sample authentication - replace with actual authentication
    return Future.delayed(const Duration(seconds: 1)).then((_) {
      if (data.name == 'user@example.com' && data.password == 'password') {
        isLoggedIn.value = true;
        return null;
      }
      return 'Invalid email or password';
    });
  }

  Future<String?> signupUser(SignupData data) {
    // This is a sample signup - replace with actual signup logic
    return Future.delayed(const Duration(seconds: 1)).then((_) {
      isLoggedIn.value = true;
      return null;
    });
  }

  Future<String> recoverPassword(String email) {
    // This is a sample password recovery - replace with actual logic
    return Future.delayed(const Duration(seconds: 1)).then((_) {
      return 'Password recovery link has been sent to $email';
    });
  }

  void logout() {
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
