import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';
import 'auth_controller.dart';

class PatientController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  var isLoading = false.obs;
  var myAppointments = <AppointmentModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    // Listen for changes to the current user
    ever(_authController.currentUser, (_) {
      if (_authController.currentUser.value?.role == UserRole.patient) {
        fetchPatientAppointments();
      }
    });
  }
  
  // Fetch appointments for the current patient
  Future<void> fetchPatientAppointments() async {
    final patient = _authController.currentUser.value;
    if (patient == null || patient.role != UserRole.patient) {
      return;
    }
    
    isLoading.value = true;
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patient.uid)
          .orderBy('date', descending: false)
          .get();
      
      myAppointments.value = snapshot.docs
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
  
  // Book an appointment with a doctor
  Future<void> bookAppointment({
    required String doctorId,
    required String doctorName,
    required DateTime appointmentDate,
    required String timeSlot,
    String? notes,
  }) async {
    final patient = _authController.currentUser.value;
    if (patient == null || patient.role != UserRole.patient) {
      Get.snackbar(
        'Permission Denied',
        'Only patients can book appointments.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      // First check if the doctor has this time slot available
      DocumentSnapshot doctorDoc = await _firestore
          .collection('users')
          .doc(doctorId)
          .get();
          
      if (!doctorDoc.exists) {
        throw 'Doctor not found';
      }
      
      // Check if the time slot is already booked
      QuerySnapshot existingAppointments = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: Timestamp.fromDate(appointmentDate))
          .where('timeSlot', isEqualTo: timeSlot)
          .where('status', whereIn: ['pending', 'approved']) // Check only active appointments
          .get();
          
      if (existingAppointments.docs.isNotEmpty) {
        throw 'This time slot is already booked';
      }
      
      // Create the appointment
      AppointmentModel appointment = AppointmentModel(
        doctorId: doctorId,
        patientId: patient.uid,
        patientName: patient.name,
        doctorName: doctorName,
        date: appointmentDate,
        timeSlot: timeSlot,
        notes: notes,
        status: AppointmentStatus.pending,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('appointments').add(appointment.toFirestore());
      
      // Refresh the appointments list
      await fetchPatientAppointments();
      
      Get.snackbar(
        'Success',
        'Appointment booked successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to book appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Cancel an appointment
  Future<void> cancelAppointment(String appointmentId) async {
    final patient = _authController.currentUser.value;
    if (patient == null || patient.role != UserRole.patient) {
      Get.snackbar(
        'Permission Denied',
        'Only patients can cancel their appointments.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    isLoading.value = true;
    try {
      // Get the appointment first to verify it belongs to this patient
      DocumentSnapshot appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
          
      if (!appointmentDoc.exists) {
        throw 'Appointment not found';
      }
      
      Map<String, dynamic> data = appointmentDoc.data() as Map<String, dynamic>;
      if (data['patientId'] != patient.uid) {
        throw 'You can only cancel your own appointments';
      }
      
      // Update the appointment status to cancelled
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.toString().split('.').last,
      });
      
      // Refresh the appointments list
      await fetchPatientAppointments();
      
      Get.snackbar(
        'Success',
        'Appointment cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}