import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the auth controller instance
    final AuthController authController = Get.find<AuthController>();

    // Get current user directly from Firebase Auth
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:
          currentUser == null
              ? const Center(child: Text('Please login to view your profile'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          currentUser.photoURL != null
                              ? NetworkImage(currentUser.photoURL!)
                              : const AssetImage(
                                    'assets/profile_placeholder.png',
                                  )
                                  as ImageProvider,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser.email ?? 'No email available',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    _buildProfileItem(
                      Icons.medical_information,
                      'Doctors',
                      onTap: () => Get.toNamed('/doctors'),
                    ),
                    _buildProfileItem(Icons.history, 'Medical History'),
                    _buildProfileItem(Icons.payment, 'Payment Methods'),
                    _buildProfileItem(Icons.settings, 'Settings'),
                    _buildProfileItem(Icons.help, 'Help & Support'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        authController.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap:
          onTap ??
          () {
            // Handle navigation to specific profile sections
          },
    );
  }
}
