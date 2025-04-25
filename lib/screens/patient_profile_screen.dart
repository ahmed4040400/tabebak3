import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../controllers/patient_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientController = Get.find<PatientController>();
    final authController = Get.find<AuthController>();
    
    // Check if the user is a patient
    if (authController.currentUser.value?.role != UserRole.patient) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You do not have patient access.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => authController.logout(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    final patient = authController.currentUser.value!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => patientController.fetchPatientAppointments(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(context, patient),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'My Appointments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/doctors'),
                  icon: const Icon(Icons.add),
                  label: const Text('Book New'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildAppointmentsList(context, patientController),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel patient) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.grey[100],
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              patient.name[0],
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  patient.email,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (patient.age != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '${patient.age} years',
                          style: TextStyle(color: Colors.blue[800]),
                        ),
                      ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Patient',
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
              Get.toNamed('/edit-profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(BuildContext context, PatientController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.myAppointments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 60, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'No appointments yet',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                'Book an appointment with a doctor',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Get.toNamed('/doctors'),
                child: const Text('Find Doctors'),
              ),
            ],
          ),
        );
      }

      // Group appointments by status
      final upcoming = controller.myAppointments
          .where((a) => a.status == AppointmentStatus.approved || a.status == AppointmentStatus.pending)
          .toList();
      final past = controller.myAppointments
          .where((a) => a.status == AppointmentStatus.completed || a.status == AppointmentStatus.cancelled)
          .toList();

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (upcoming.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Upcoming Appointments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...upcoming.map((appointment) => _buildAppointmentCard(context, appointment, controller)),
          ],
          if (past.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Past Appointments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ...past.map((appointment) => _buildAppointmentCard(context, appointment, controller)),
          ],
        ],
      );
    });
  }

  Widget _buildAppointmentCard(
      BuildContext context, AppointmentModel appointment, PatientController controller) {
    // Determine card color based on appointment status
    Color? cardColor;
    switch (appointment.status) {
      case AppointmentStatus.pending:
        cardColor = Colors.amber.shade50;
        break;
      case AppointmentStatus.approved:
        cardColor = Colors.green.shade50;
        break;
      case AppointmentStatus.completed:
        cardColor = Colors.blue.shade50;
        break;
      case AppointmentStatus.cancelled:
        cardColor = Colors.red.shade50;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. ${appointment.doctorName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(appointment.date),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(appointment.status),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  appointment.timeSlot,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${appointment.notes}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
            if (appointment.status == AppointmentStatus.pending || appointment.status == AppointmentStatus.approved)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showCancelConfirmDialog(
                      context,
                      appointment,
                      controller,
                    ),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Cancel Appointment'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    String text;
    MaterialColor color;

    switch (status) {
      case AppointmentStatus.pending:
        text = 'Pending';
        color = Colors.amber;
        break;
      case AppointmentStatus.approved:
        text = 'Approved';
        color = Colors.green;
        break;
      case AppointmentStatus.completed:
        text = 'Completed';
        color = Colors.blue;
        break;
      case AppointmentStatus.cancelled:
        text = 'Cancelled';
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        text,
        style: TextStyle(color: color.shade800, fontSize: 12),
      ),
      backgroundColor: color.shade100,
    );
  }

  void _showCancelConfirmDialog(
    BuildContext context,
    AppointmentModel appointment,
    PatientController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No, Keep It'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.cancelAppointment(appointment.id!);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}