import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';

class FirebaseSeeder {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isSeeding = false;
  final RxBool isLoading = false.obs;

  // Check if seeding is necessary by looking for admin user
  Future<bool> needsSeeding() async {
    try {
      final QuerySnapshot adminSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      
      return adminSnapshot.docs.isEmpty;
    } catch (e) {
      debugPrint('Error checking if seeding is needed: $e');
      return true;
    }
  }

  // Main seeding method
  Future<void> seedDatabase() async {
    if (_isSeeding) return;
    
    _isSeeding = true;
    isLoading.value = true;
    
    try {
      // Only proceed with seeding if needed
      if (await needsSeeding()) {
        debugPrint('Starting database seeding...');
        
        // Seed in sequence to avoid race conditions
        await _seedAdmin();
        await _seedSpecialties();
        await _seedDoctors();
        await _seedHospitals();
        await _seedPharmacies();
        
        debugPrint('Database seeding completed successfully!');
      } else {
        debugPrint('Database already seeded. Skipping.');
      }
    } catch (e) {
      debugPrint('Error seeding database: $e');
    } finally {
      _isSeeding = false;
      isLoading.value = false;
    }
  }

  // Seed default admin user
  Future<void> _seedAdmin() async {
    try {
      debugPrint('Seeding admin user...');
      
      // Check if admin already exists
      final QuerySnapshot adminSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@tabebak.com')
          .limit(1)
          .get();
      
      if (adminSnapshot.docs.isNotEmpty) {
        debugPrint('Admin user already exists. Skipping.');
        return;
      }
      
      // Create admin user in Firebase Authentication
      final UserCredential adminCredential = await _auth.createUserWithEmailAndPassword(
        email: 'admin@tabebak.com',
        password: 'admin123456', // Should be changed after first login
      );
      
      // Add admin user document to Firestore
      await _firestore.collection('users').doc(adminCredential.user!.uid).set({
        'email': 'admin@tabebak.com',
        'name': 'System Admin',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('Admin user created successfully.');
    } catch (e) {
      debugPrint('Error seeding admin user: $e');
      // If admin user creation fails, we should still try to create other data
    }
  }

  // Seed medical specialties
  Future<void> _seedSpecialties() async {
    try {
      debugPrint('Seeding specialties...');
      
      // Check if specialties collection exists and has data
      final QuerySnapshot specialtySnapshot = await _firestore
          .collection('specialties')
          .limit(1)
          .get();
      
      if (specialtySnapshot.docs.isNotEmpty) {
        debugPrint('Specialties already exist. Skipping.');
        return;
      }
      
      // List of common medical specialties
      final List<Map<String, dynamic>> specialties = [
        {'name': 'Cardiology', 'icon': 'heart', 'description': 'Heart and cardiovascular system'},
        {'name': 'Dermatology', 'icon': 'skin', 'description': 'Skin conditions'},
        {'name': 'Neurology', 'icon': 'brain', 'description': 'Nervous system disorders'},
        {'name': 'Orthopedics', 'icon': 'bone', 'description': 'Musculoskeletal system'},
        {'name': 'Pediatrics', 'icon': 'child', 'description': 'Children\'s health'},
        {'name': 'Psychiatry', 'icon': 'psychology', 'description': 'Mental health'},
        {'name': 'Ophthalmology', 'icon': 'eye', 'description': 'Eye care'},
        {'name': 'Gynecology', 'icon': 'female', 'description': 'Women\'s health'},
        {'name': 'Urology', 'icon': 'male', 'description': 'Urinary tract and male reproductive system'},
        {'name': 'ENT', 'icon': 'ear', 'description': 'Ear, nose, and throat'},
        {'name': 'Dentistry', 'icon': 'tooth', 'description': 'Dental care'},
        {'name': 'Family Medicine', 'icon': 'family', 'description': 'General health care for all ages'},
      ];
      
      // Add specialties to Firestore
      final batch = _firestore.batch();
      for (final specialty in specialties) {
        final docRef = _firestore.collection('specialties').doc();
        batch.set(docRef, {
          ...specialty,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Specialties seeded successfully.');
    } catch (e) {
      debugPrint('Error seeding specialties: $e');
    }
  }

  // Seed sample doctors
  Future<void> _seedDoctors() async {
    try {
      debugPrint('Seeding doctors...');
      
      // Check if any doctors already exist
      final QuerySnapshot doctorSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .limit(1)
          .get();
      
      if (doctorSnapshot.docs.isNotEmpty) {
        debugPrint('Doctors already exist. Skipping.');
        return;
      }
      
      // Get specialties to assign to doctors
      QuerySnapshot specialtySnapshot = await _firestore
          .collection('specialties')
          .get();
      
      final specialties = specialtySnapshot.docs.map((doc) => {
        'id': doc.id,
        'name': (doc.data() as Map<String, dynamic>)['name'],
      }).toList();
      
      // Sample doctors data
      final List<Map<String, dynamic>> doctors = [
        {
          'email': 'ahmed.ibrahim@tabebak.com',
          'password': 'doctor123456',
          'name': 'Dr. Ahmed Ibrahim',
          'specialty': 'Cardiology',
          'bio': 'Experienced cardiologist with 15 years of practice in treating heart conditions.',
          'rating': 4.8,
          'availability': ['Monday: 9:00 AM - 5:00 PM', 'Wednesday: 10:00 AM - 6:00 PM', 'Friday: 9:00 AM - 3:00 PM'],
        },
        {
          'email': 'nour.hassan@tabebak.com',
          'password': 'doctor123456',
          'name': 'Dr. Nour Hassan',
          'specialty': 'Dermatology',
          'bio': 'Specialized in treating various skin conditions with the latest techniques.',
          'rating': 4.7,
          'availability': ['Tuesday: 10:00 AM - 7:00 PM', 'Thursday: 9:00 AM - 5:00 PM', 'Saturday: 10:00 AM - 2:00 PM'],
        },
        {
          'email': 'khaled.mahmoud@tabebak.com',
          'password': 'doctor123456',
          'name': 'Dr. Khaled Mahmoud',
          'specialty': 'Neurology',
          'bio': 'Neurologist focusing on headaches, epilepsy, and movement disorders.',
          'rating': 4.9,
          'availability': ['Monday: 11:00 AM - 7:00 PM', 'Wednesday: 9:00 AM - 5:00 PM', 'Thursday: 10:00 AM - 6:00 PM'],
        },
        {
          'email': 'fatma.ali@tabebak.com',
          'password': 'doctor123456',
          'name': 'Dr. Fatma Ali',
          'specialty': 'Pediatrics',
          'bio': 'Dedicated to providing comprehensive healthcare for children of all ages.',
          'rating': 4.9,
          'availability': ['Sunday: 10:00 AM - 6:00 PM', 'Tuesday: 9:00 AM - 5:00 PM', 'Thursday: 9:00 AM - 3:00 PM'],
        },
        {
          'email': 'omar.sayed@tabebak.com',
          'password': 'doctor123456',
          'name': 'Dr. Omar El-Sayed',
          'specialty': 'Orthopedics',
          'bio': 'Specializing in sports injuries and joint replacements with minimally invasive approaches.',
          'rating': 4.6,
          'availability': ['Monday: 10:00 AM - 6:00 PM', 'Wednesday: 11:00 AM - 7:00 PM', 'Saturday: 9:00 AM - 3:00 PM'],
        },
      ];
      
      // Add doctors to Firebase Auth and Firestore
      for (final doctorData in doctors) {
        try {
          // Create auth user
          final UserCredential doctorCredential = await _auth.createUserWithEmailAndPassword(
            email: doctorData['email'],
            password: doctorData['password'],
          );
          
          // Add doctor data to Firestore
          await _firestore.collection('users').doc(doctorCredential.user!.uid).set({
            'email': doctorData['email'],
            'name': doctorData['name'],
            'role': 'doctor',
            'specialty': doctorData['specialty'],
            'bio': doctorData['bio'],
            'rating': doctorData['rating'],
            'availability': doctorData['availability'],
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          debugPrint('Doctor created: ${doctorData['name']}');
        } catch (e) {
          debugPrint('Error creating doctor ${doctorData['name']}: $e');
        }
      }
      
      debugPrint('Doctors seeded successfully.');
    } catch (e) {
      debugPrint('Error seeding doctors: $e');
    }
  }

  // Seed sample hospitals
  Future<void> _seedHospitals() async {
    try {
      debugPrint('Seeding hospitals...');
      
      // Check if any hospitals already exist
      final QuerySnapshot hospitalSnapshot = await _firestore
          .collection('hospitals')
          .limit(1)
          .get();
      
      if (hospitalSnapshot.docs.isNotEmpty) {
        debugPrint('Hospitals already exist. Skipping.');
        return;
      }
      
      // Sample hospital data
      final List<Map<String, dynamic>> hospitals = [
        {
          'name': 'Cairo University Hospital',
          'address': '1 Kasr Al Ainy St, Cairo Governorate',
          'phone': '+20 2 23654371',
          'location': GeoPoint(30.0258, 31.2329),
          'services': ['Emergency', 'Surgery', 'Radiology', 'Laboratory', 'Outpatient'],
          'rating': 4.2,
          'image': 'assets/hospital1.png',
        },
        {
          'name': 'Al Salam International Hospital',
          'address': 'Corniche El Nil, Maadi, Cairo',
          'phone': '+20 2 25240250',
          'location': GeoPoint(29.9626, 31.2497),
          'services': ['Emergency', 'Surgery', 'Cardiology', 'Oncology', 'Pediatrics'],
          'rating': 4.5,
          'image': 'assets/hospital2.png',
        },
        {
          'name': 'Dar Al Fouad Hospital',
          'address': 'Nasr City, Cairo Governorate',
          'phone': '+20 2 26908000',
          'location': GeoPoint(30.0561, 31.3481),
          'services': ['Cardiology', 'Neurology', 'Orthopedics', 'Oncology', 'Transplant'],
          'rating': 4.8,
          'image': 'assets/hospital3.png',
        },
        {
          'name': 'Alexandria International Hospital',
          'address': 'Smouha, Alexandria Governorate',
          'phone': '+20 3 4253535',
          'location': GeoPoint(31.2001, 29.9187),
          'services': ['Emergency', 'Surgery', 'Maternity', 'ICU', 'Physiotherapy'],
          'rating': 4.3,
          'image': 'assets/hospital1.png',
        },
      ];
      
      // Add hospitals to Firestore
      final batch = _firestore.batch();
      for (final hospital in hospitals) {
        final docRef = _firestore.collection('hospitals').doc();
        batch.set(docRef, {
          ...hospital,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Hospitals seeded successfully.');
    } catch (e) {
      debugPrint('Error seeding hospitals: $e');
    }
  }

  // Seed sample pharmacies
  Future<void> _seedPharmacies() async {
    try {
      debugPrint('Seeding pharmacies...');
      
      // Check if any pharmacies already exist
      final QuerySnapshot pharmacySnapshot = await _firestore
          .collection('pharmacies')
          .limit(1)
          .get();
      
      if (pharmacySnapshot.docs.isNotEmpty) {
        debugPrint('Pharmacies already exist. Skipping.');
        return;
      }
      
      // Sample pharmacy data
      final List<Map<String, dynamic>> pharmacies = [
        {
          'name': 'El Ezaby Pharmacy',
          'address': 'Tahrir Square, Cairo Governorate',
          'phone': '+20 2 27957559',
          'location': GeoPoint(30.0444, 31.2357),
          'hours': '24 hours',
          'delivery': true,
          'rating': 4.6,
          'image': 'assets/pharmacy1.png',
        },
        {
          'name': 'Seif Pharmacy',
          'address': 'Heliopolis, Cairo Governorate',
          'phone': '+20 2 26908000',
          'location': GeoPoint(30.0911, 31.3425),
          'hours': '9:00 AM - 11:00 PM',
          'delivery': true,
          'rating': 4.3,
          'image': 'assets/pharmacy2.png',
        },
        {
          'name': '19011 Pharmacy',
          'address': 'Maadi, Cairo Governorate',
          'phone': '+20 19011',
          'location': GeoPoint(29.9502, 31.2564),
          'hours': '24 hours',
          'delivery': true,
          'rating': 4.5,
          'image': 'assets/pharmacy3.png',
        },
        {
          'name': 'Roshdy Pharmacy',
          'address': 'Alexandria, Alexandria Governorate',
          'phone': '+20 3 5920800',
          'location': GeoPoint(31.2001, 29.9187),
          'hours': '8:00 AM - 12:00 AM',
          'delivery': false,
          'rating': 4.1,
          'image': 'assets/pharmacy1.png',
        },
      ];
      
      // Add pharmacies to Firestore
      final batch = _firestore.batch();
      for (final pharmacy in pharmacies) {
        final docRef = _firestore.collection('pharmacies').doc();
        batch.set(docRef, {
          ...pharmacy,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      debugPrint('Pharmacies seeded successfully.');
    } catch (e) {
      debugPrint('Error seeding pharmacies: $e');
    }
  }
}
