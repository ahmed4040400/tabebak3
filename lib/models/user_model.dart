import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, doctor, patient }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final String? phoneNumber;
  
  // Doctor specific fields
  final String? specialty;
  final String? bio;
  final double? rating;
  final List<String>? availability;
  
  // Patient specific fields
  final String? medicalHistory;
  final String? address;
  final int? age;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.photoUrl,
    this.phoneNumber,
    this.specialty,
    this.bio,
    this.rating,
    this.availability,
    this.medicalHistory,
    this.address,
    this.age,
  });
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.patient
      ),
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      specialty: data['specialty'],
      bio: data['bio'],
      rating: data['rating']?.toDouble(),
      availability: data['availability'] != null 
          ? List<String>.from(data['availability']) 
          : null,
      medicalHistory: data['medicalHistory'],
      address: data['address'],
      age: data['age'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      if (role == UserRole.doctor) ...{
        'specialty': specialty,
        'bio': bio,
        'rating': rating,
        'availability': availability,
      },
      if (role == UserRole.patient) ...{
        'medicalHistory': medicalHistory,
        'address': address,
        'age': age,
      },
    };
  }
}