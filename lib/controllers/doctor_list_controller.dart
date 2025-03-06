import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart' as faker;

class DoctorListController extends GetxController {
  final isGridView = false.obs;
  final selectedSpecialty = 'All'.obs;
  final TextEditingController searchController = TextEditingController();
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxList<Doctor> filteredDoctors = <Doctor>[].obs;
  final RxList<String> specialties = <String>['All'].obs;

  // Egyptian male first names
  final List<String> egyptianMaleFirstNames = [
    'Ahmed',
    'Mohamed',
    'Mahmoud',
    'Ali',
    'Omar',
    'Mostafa',
    'Khaled',
    'Ibrahim',
    'Amr',
    'Ayman',
    'Tarek',
    'Hossam',
    'Sherif',
    'Karim',
    'Hesham',
    'Youssef',
    'Hassan',
    'Hussein',
    'Abdallah',
    'Samir',
  ];

  // Egyptian female first names
  final List<String> egyptianFemaleFirstNames = [
    'Nour',
    'Mariam',
    'Fatma',
    'Sara',
    'Aya',
    'Heba',
    'Mona',
    'Amira',
    'Dina',
    'Laila',
    'Yasmin',
    'Salma',
    'Hala',
    'Rania',
    'Reem',
    'Mayar',
    'Farah',
    'Eman',
    'Esraa',
    'Noha',
  ];

  // Egyptian last names
  final List<String> egyptianLastNames = [
    'Mohamed',
    'Ahmed',
    'Ibrahim',
    'El-Masry',
    'El-Sayed',
    'Mahmoud',
    'Abdelrahman',
    'El-Sherif',
    'Mostafa',
    'Ali',
    'Hassan',
    'Hussein',
    'El-Din',
    'Salah',
    'Kamal',
    'Osman',
    'Gamal',
    'El-Baz',
    'Farouk',
    'Nasser',
    'Fawzy',
    'Shawky',
    'El-Naggar',
    'Abouzeid',
    'Zaki',
  ];

  @override
  void onInit() {
    super.onInit();
    generateDoctors();
    filteredDoctors.value = doctors;
    updateSpecialties();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void updateSpecialties() {
    final Set<String> uniqueSpecialties = {'All'};
    for (final doctor in doctors) {
      uniqueSpecialties.add(doctor.specialty);
    }
    specialties.value = uniqueSpecialties.toList();
  }

  void generateDoctors() {
    final fakerInstance = faker.Faker();
    final List<Doctor> generatedDoctors = [];

    for (int i = 0; i < 20; i++) {
      final specialtiesList = [
        'Cardiologist',
        'Dermatologist',
        'Pediatrician',
        'Orthopedist',
        'Neurologist',
        'Ophthalmologist',
        'Psychiatrist',
        'Gynecologist',
        'Urologist',
      ];

      final specialty =
          specialtiesList[fakerInstance.randomGenerator.integer(
            specialtiesList.length,
          )];

      // Determine gender and select appropriate Egyptian name
      final gender =
          fakerInstance.randomGenerator.boolean() ? 'male' : 'female';

      String firstName;
      if (gender == 'male') {
        firstName =
            egyptianMaleFirstNames[fakerInstance.randomGenerator.integer(
              egyptianMaleFirstNames.length,
            )];
      } else {
        firstName =
            egyptianFemaleFirstNames[fakerInstance.randomGenerator.integer(
              egyptianFemaleFirstNames.length,
            )];
      }

      final lastName =
          egyptianLastNames[fakerInstance.randomGenerator.integer(
            egyptianLastNames.length,
          )];

      generatedDoctors.add(
        Doctor(
          name: 'Dr. $firstName $lastName',
          specialty: specialty,
          rating: 3.5 + fakerInstance.randomGenerator.decimal() * 1.5,
          reviewCount: fakerInstance.randomGenerator.integer(500) + 20,
          distance: fakerInstance.randomGenerator.integer(5000) + 100,
          experience: fakerInstance.randomGenerator.integer(20) + 1,
          isAvailable: fakerInstance.randomGenerator.boolean(),
          gender: gender,
          price: (fakerInstance.randomGenerator.integer(150) + 50).toDouble(),
        ),
      );
    }

    doctors.value = generatedDoctors;
  }

  void filterDoctors() {
    if (searchController.text.isEmpty && selectedSpecialty.value == 'All') {
      filteredDoctors.value = doctors;
    } else {
      filteredDoctors.value =
          doctors.where((doc) {
            final matchesSearch =
                searchController.text.isEmpty ||
                doc.name.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                ) ||
                doc.specialty.toLowerCase().contains(
                  searchController.text.toLowerCase(),
                );

            final matchesSpecialty =
                selectedSpecialty.value == 'All' ||
                doc.specialty == selectedSpecialty.value;

            return matchesSearch && matchesSpecialty;
          }).toList();
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  void selectSpecialty(String specialty, bool selected) {
    if (selected) {
      selectedSpecialty.value = specialty;
    } else {
      selectedSpecialty.value = 'All';
    }
    filterDoctors();
  }

  void clearSearch() {
    searchController.clear();
    filterDoctors();
  }
}

class Doctor {
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final int distance;
  final int experience;
  final bool isAvailable;
  final String gender;
  final double price;

  Doctor({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.experience,
    required this.isAvailable,
    required this.gender,
    required this.price,
  });

  String get distanceText {
    return distance < 1000
        ? '${distance}m away'
        : '${(distance / 1000).toStringAsFixed(1)}km away';
  }
}
