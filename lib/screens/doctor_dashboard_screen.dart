import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/doctor_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../models/appointment_model.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final doctorController = Get.find<DoctorController>();
    final authController = Get.find<AuthController>();
    
    // Check if the user is a doctor
    if (authController.currentUser.value?.role != UserRole.doctor) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You do not have doctor access.'),
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Dashboard'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                doctorController.fetchDoctorAppointments();
                doctorController.loadAvailability();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authController.logout(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.schedule),
                text: 'Appointments',
              ),
              Tab(
                icon: Icon(Icons.access_time),
                text: 'Availability',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildAppointmentsTab(context, doctorController),
            _buildAvailabilityTab(context, doctorController),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab(BuildContext context, DoctorController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.appointments.isEmpty) {
        return const Center(child: Text('No appointments yet.'));
      }
      
      return ListView.builder(
        itemCount: controller.appointments.length,
        itemBuilder: (context, index) {
          final appointment = controller.appointments[index];
          return _buildAppointmentCard(context, appointment, controller);
        },
      );
    });
  }

  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appointment, DoctorController controller) {
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(appointment.date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildStatusChip(appointment.status),
              ],
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(appointment.patientName),
              subtitle: Text('Time: ${appointment.timeSlot}'),
              trailing: appointment.status == AppointmentStatus.pending
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => controller.updateAppointmentStatus(
                            appointment.id!,
                            AppointmentStatus.approved,
                          ),
                          tooltip: 'Approve',
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => controller.updateAppointmentStatus(
                            appointment.id!,
                            AppointmentStatus.cancelled,
                          ),
                          tooltip: 'Cancel',
                        ),
                      ],
                    )
                  : appointment.status == AppointmentStatus.approved
                      ? IconButton(
                          icon: const Icon(Icons.done_all, color: Colors.blue),
                          onPressed: () => controller.updateAppointmentStatus(
                            appointment.id!,
                            AppointmentStatus.completed,
                          ),
                          tooltip: 'Mark as Completed',
                        )
                      : null,
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Notes: ${appointment.notes}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
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

  Widget _buildAvailabilityTab(BuildContext context, DoctorController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Your Available Time Slots',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            const Text(
              'Add time slots when you are available for appointments',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildTimeSlotSection('Morning', ['8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM'], controller),
                  _buildTimeSlotSection('Afternoon', ['12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM'], controller),
                  _buildTimeSlotSection('Evening', ['4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM'], controller),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await controller.fetchDoctorAppointments();
                  Get.snackbar(
                    'Success',
                    'Your availability has been updated',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                },
                child: const Text('Update Availability'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTimeSlotSection(String title, List<String> timeSlots, DoctorController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeSlots.map((slot) {
            bool isSelected = controller.availableTimeSlots.contains(slot);
            return FilterChip(
              label: Text(slot),
              selected: isSelected,
              onSelected: (selected) {
                final updatedSlots = List<String>.from(controller.availableTimeSlots);
                if (selected) {
                  if (!updatedSlots.contains(slot)) {
                    updatedSlots.add(slot);
                  }
                } else {
                  updatedSlots.remove(slot);
                }
                controller.updateAvailability(updatedSlots);
              },
            );
          }).toList(),
        ),
        const Divider(height: 32),
      ],
    );
  }
}