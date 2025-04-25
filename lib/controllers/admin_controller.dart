import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  var isLoading = false.obs;
  var doctors = <UserModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Fetch doctors when controller initializes
    fetchDoctors();
  }
  
  // Fetch all doctors from Firestore
  Future<void> fetchDoctors() async {
    isLoading.value = true;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      
      doctors.value = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch doctors: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Add a new doctor account
  Future<void> addDoctor({
    required String email,
    required String password,
    required String name,
    required String specialty,
    String? bio,
  }) async {
    if (_authController.currentUser.value?.role != UserRole.admin) {
      Get.snackbar(
        'Permission Denied',
        'Only admins can add doctors.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      await _authController.createDoctorAccount(
        email: email,
        password: password,
        name: name,
        specialty: specialty,
        bio: bio,
      );
      
      // Refresh the doctors list
      await fetchDoctors();
      
      Get.snackbar(
        'Success',
        'Doctor added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add doctor: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update doctor details
  Future<void> updateDoctorDetails({
    required String doctorId,
    String? name,
    String? specialty,
    String? bio,
    List<String>? availability,
  }) async {
    if (_authController.currentUser.value?.role != UserRole.admin) {
      Get.snackbar(
        'Permission Denied',
        'Only admins can update doctor details.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (specialty != null) updateData['specialty'] = specialty;
      if (bio != null) updateData['bio'] = bio;
      if (availability != null) updateData['availability'] = availability;
      
      await _firestore.collection('users').doc(doctorId).update(updateData);
      
      // Refresh the doctors list
      await fetchDoctors();
      
      Get.snackbar(
        'Success',
        'Doctor details updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update doctor details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Remove a doctor account
  Future<void> removeDoctor(String doctorId) async {
    if (_authController.currentUser.value?.role != UserRole.admin) {
      Get.snackbar(
        'Permission Denied',
        'Only admins can remove doctors.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      // Delete the doctor from Firestore
      await _firestore.collection('users').doc(doctorId).delete();
      
      // Note: This doesn't delete the Firebase Auth account, only the Firestore record
      // For a complete solution, use Firebase Admin SDK or Cloud Functions
      
      // Refresh the doctors list
      await fetchDoctors();
      
      Get.snackbar(
        'Success',
        'Doctor removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove doctor: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}