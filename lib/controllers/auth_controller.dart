import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../screens/main_container_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  var isLoading = false.obs;

  // Add a flag to control automatic navigation
  var shouldAutoNavigate = false.obs;

  // Flag to show registration form
  var shouldShowRegistrationForm = false.obs;

  get user => null;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.value = _auth.currentUser;

    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
      if (user != null) {
        _fetchUserData(user.uid);
        // No automatic navigation - navigation must be explicitly called
      } else {
        currentUser.value = null;
      }
    });

    // Intercept navigation to patient-profile route
    ever(currentUser, (user) {
      // If navigation to patient profile is detected and we don't want auto-navigation
      if (Get.currentRoute == '/patient-profile' && !shouldAutoNavigate.value) {
        // Navigate back or to a safe route
        Get.back();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    isLoading.value = true;
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch user data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Used by flutter_login widget
  Future<String?> authUser(LoginData data) async {
    // Disable auto-navigation before authentication
    shouldAutoNavigate.value = false;

    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );

      // Check if user is logged in
      if (firebaseUser.value != null) {
        await _fetchUserData(firebaseUser.value!.uid);

        // If we are being redirected to /patient-profile, interrupt it
        Future.delayed(Duration.zero, () {
          if (Get.currentRoute == '/patient-profile') {
            Get.back();
          }
        });
      }

      return null; // No error means success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Updated method to navigate to the main container screen
  void _navigateToMainScreen() {
    // Navigate to main container screen and replace all previous screens
    Get.offAll(
      () => const MainContainerScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Explicit navigation method that can be called when desired
  void navigateToPatientProfile() {
    shouldAutoNavigate.value = true;
    Get.toNamed('/patient-profile');
  }

  // Used by flutter_login widget
  Future<String?> signupUser(SignupData data) async {
    if (data.name == null || data.password == null) {
      return "Email and password are required";
    }

    isLoading.value = true;
    try {
      // Create auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );

      // Add additional user data to Firestore
      // Default to patient role for sign-ups through the app
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': data.name,
        'name':
            data.additionalSignupData?['fullName'] ?? data.name!.split('@')[0],
        'role': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // No error means success
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Used by flutter_login widget
  Future<String> recoverPassword(String email) async {
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset link has been sent to $email';
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e) ?? 'Failed to send password reset email';
    } finally {
      isLoading.value = false;
    }
  }

  String? _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return e.message;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }

  // Create admin account (can only be called by existing admins)
  Future<void> createAdminAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    // Check if the current user is an admin
    if (currentUser.value?.role != UserRole.admin) {
      throw 'Only admins can create other admin accounts';
    }

    try {
      // Create auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add admin data to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'name': name,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Create doctor account (can only be called by admins)
  Future<void> createDoctorAccount({
    required String email,
    required String password,
    required String name,
    required String specialty,
    String? bio,
  }) async {
    // Check if the current user is an admin
    if (currentUser.value?.role != UserRole.admin) {
      throw 'Only admins can create doctor accounts';
    }

    try {
      // Create auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add doctor data to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'name': name,
        'role': 'doctor',
        'specialty': specialty,
        'bio': bio,
        'rating': 0.0,
        'availability': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Register a request to become a doctor (pending approval)
  Future<void> registerDoctorRequest({
    required String email,
    required String password,
    required String name,
    required String specialty,
    String? bio,
  }) async {
    try {
      // Create auth user
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add doctor data to Firestore with pending status
      await _firestore.collection('users').doc(result.user!.uid).set({
        'email': email,
        'name': name,
        'role': 'doctor',
        'approvalStatus': 'pending', // Requires admin approval
        'specialty': specialty,
        'bio': bio ?? '',
        'rating': 0.0,
        'availability': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Also create a doctor registration request
      await _firestore.collection('doctorRequests').doc(result.user!.uid).set({
        'email': email,
        'name': name,
        'specialty': specialty,
        'bio': bio ?? '',
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });

      // Sign out the user after registration - they need to wait for approval
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
