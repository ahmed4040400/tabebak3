import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Text(
                'U',
                style: TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('user@example.com'),
            const SizedBox(height: 40),

            // Profile Options
            _buildProfileOption(
              context,
              icon: Icons.person,
              title: 'Personal Information',
              onTap: () {},
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.history,
              title: 'Medical History',
              onTap: () {},
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.calendar_today,
              title: 'My Appointments',
              onTap: () {},
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.favorite,
              title: 'Favorite Doctors',
              onTap: () {},
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {},
            ),
            _buildDivider(),
            _buildProfileOption(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: authController.logout,
              textColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function() onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1);
  }
}
