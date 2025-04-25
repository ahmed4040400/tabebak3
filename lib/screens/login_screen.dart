import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Stack(
      children: [
        FlutterLogin(
          title: 'Tabebak',
          logo: const AssetImage('assets/logo.png'),
          onLogin: authController.authUser,
          onSignup: authController.signupUser,
          hideForgotPasswordButton: true,
          onSubmitAnimationCompleted: () {
            Get.offAllNamed('/main');
          },
          onRecoverPassword: authController.recoverPassword,
          theme: LoginTheme(
            primaryColor: Colors.teal,
            accentColor: Colors.tealAccent,

            cardTheme: CardTheme(
              color: Colors.white,
              elevation: 5,
              margin: const EdgeInsets.only(top: 15),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
          messages: LoginMessages(
            userHint: 'Email',
            passwordHint: 'Password',
            loginButton: 'LOG IN',
            signupButton: 'REGISTER',
            recoverPasswordButton: 'RECOVER',
            goBackButton: 'GO BACK',
          ),
        ),
      ],
    );
  }
}
