import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class DoctorController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  var isLoading = false.obs;
  var appointments = <AppointmentModel>[].obs;
  var availableTimeSlots = <String>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Listen for changes to the current user
    ever(_authController.currentUser, (_) {
      if (_authController.currentUser.value?.role == UserRole.doctor) {
        fetchDoctorAppointments();
        loadAvailability();
      }
    });
  }
  
  // Fetch appointments for the current doctor
  Future<void> fetchDoctorAppointments() async {
    final doctor = _authController.currentUser.value;
    if (doctor == null || doctor.role != UserRole.doctor) {
      return;
    }
    
    isLoading.value = true;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.uid)
          .orderBy('date', descending: false)
          .get();
      
      appointments.value = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch appointments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update appointment status (approve, complete, or cancel)
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) async {
    final doctor = _authController.currentUser.value;
    if (doctor == null || doctor.role != UserRole.doctor) {
      Get.snackbar(
        'Permission Denied',
        'Only doctors can update appointment status.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': newStatus.toString().split('.').last,
      });
      
      // Refresh the appointments list
      await fetchDoctorAppointments();
      
      Get.snackbar(
        'Success',
        'Appointment status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update appointment status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load doctor availability time slots
  Future<void> loadAvailability() async {
    final doctor = _authController.currentUser.value;
    if (doctor == null || doctor.role != UserRole.doctor) {
      return;
    }
    
    isLoading.value = true;
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(doctor.uid)
          .get();
      
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        if (data['availability'] != null) {
          availableTimeSlots.value = List<String>.from(data['availability']);
        } else {
          availableTimeSlots.value = [];
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load availability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update doctor availability time slots
  Future<void> updateAvailability(List<String> newAvailability) async {
    final doctor = _authController.currentUser.value;
    if (doctor == null || doctor.role != UserRole.doctor) {
      Get.snackbar(
        'Permission Denied',
        'Only doctors can update availability.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      await _firestore.collection('users').doc(doctor.uid).update({
        'availability': newAvailability,
      });
      
      // Update local state
      availableTimeSlots.value = newAvailability;
      
      Get.snackbar(
        'Success',
        'Availability updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update availability: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}