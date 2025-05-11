import 'package:cloud_firestore/cloud_firestore.dart';

class PharmacyModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final String? facebookUrl;
  final String? imageUrl;
  
  PharmacyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.facebookUrl,
    this.imageUrl,
  });
  
  factory PharmacyModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PharmacyModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      phoneNumber: data['phoneNumber'],
      facebookUrl: data['facebookUrl'],
      imageUrl: data['imageUrl'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'facebookUrl': facebookUrl,
      'imageUrl': imageUrl,
    };
  }
}
