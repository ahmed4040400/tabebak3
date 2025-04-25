import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final adminController = Get.find<AdminController>();
    final authController = Get.find<AuthController>();
    
    // Check if the user is an admin
    if (authController.currentUser.value?.role != UserRole.admin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You do not have admin access.'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => adminController.fetchDoctors(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Obx(() {
        if (adminController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Manage Doctors',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const Divider(),
            Expanded(
              child: adminController.doctors.isEmpty
                ? const Center(child: Text('No doctors yet. Add a new doctor.'))
                : ListView.builder(
                    itemCount: adminController.doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = adminController.doctors[index];
                      return _buildDoctorCard(context, doctor, adminController);
                    },
                  ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDoctorDialog(context, adminController),
        child: const Icon(Icons.add),
        tooltip: 'Add New Doctor',
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, UserModel doctor, AdminController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(doctor.name[0]),
        ),
        title: Text(doctor.name),
        subtitle: Text(doctor.specialty ?? 'No specialty set'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDoctorDialog(context, doctor, controller),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmDialog(context, doctor, controller),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDoctorDialog(BuildContext context, AdminController controller) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();
    final bioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Doctor'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: specialtyController,
                    decoration: const InputDecoration(labelText: 'Specialty'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter specialty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio (Optional)'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  controller.addDoctor(
                    email: emailController.text,
                    password: passwordController.text,
                    name: nameController.text,
                    specialty: specialtyController.text,
                    bio: bioController.text.isEmpty ? null : bioController.text,
                  );
                  Get.back();
                }
              },
              child: const Text('Add Doctor'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDoctorDialog(BuildContext context, UserModel doctor, AdminController controller) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: doctor.name);
    final specialtyController = TextEditingController(text: doctor.specialty);
    final bioController = TextEditingController(text: doctor.bio);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Doctor Details'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: specialtyController,
                    decoration: const InputDecoration(labelText: 'Specialty'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter specialty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: bioController,
                    decoration: const InputDecoration(labelText: 'Bio (Optional)'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  controller.updateDoctorDetails(
                    doctorId: doctor.uid,
                    name: nameController.text,
                    specialty: specialtyController.text,
                    bio: bioController.text.isEmpty ? null : bioController.text,
                  );
                  Get.back();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, UserModel doctor, AdminController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Doctor'),
          content: Text('Are you sure you want to remove Dr. ${doctor.name}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.removeDoctor(doctor.uid);
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}