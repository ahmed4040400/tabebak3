import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

enum DoctorSortOption {
  default_sort,
  rating_high_to_low,
  price_low_to_high,
  price_high_to_low
}

class DoctorListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isGridView = false.obs;
  final selectedSpecialty = 'All'.obs;
  final TextEditingController searchController = TextEditingController();
  final RxList<UserModel> doctors = <UserModel>[].obs;
  final RxList<UserModel> filteredDoctors = <UserModel>[].obs;
  final RxList<String> specialties = <String>['All'].obs;
  final isLoading = false.obs;
  final Rx<DoctorSortOption> selectedSortOption = DoctorSortOption.rating_high_to_low.obs;

  // Pagination properties
  final int limit = 10;
  DocumentSnapshot? lastDocument;
  final RxBool hasMoreDoctors = true.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchDoctors({bool isRefresh = false}) async {
    if (isRefresh) {
      doctors.clear();
      lastDocument = null;
      hasMoreDoctors.value = true;
    }

    if (!hasMoreDoctors.value) return;

    isLoading.value = true;
    try {
      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .limit(limit);

      // If this is not the first page, start after the last document
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreDoctors.value = false;
        return;
      }

      if (snapshot.docs.length < limit) {
        hasMoreDoctors.value = false;
      }

      // Save the last document for next query
      lastDocument = snapshot.docs.last;

      List<UserModel> newDoctors =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      doctors.addAll(newDoctors);
      filteredDoctors.value = doctors;
      updateSpecialties();
      
      // Apply the default sorting (highest rated) after fetching doctors
      sortDoctors(selectedSortOption.value);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch doctors: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreDoctors() async {
    if (isLoadingMore.value || !hasMoreDoctors.value) return;

    isLoadingMore.value = true;
    try {
      await fetchDoctors();
      // After fetching, reapply any active filters
      filterDoctors();
    } finally {
      isLoadingMore.value = false;
    }
  }

  void updateSpecialties() {
    final Set<String> uniqueSpecialties = {'All'};
    for (final doctor in doctors) {
      if (doctor.specialty != null && doctor.specialty!.isNotEmpty) {
        uniqueSpecialties.add(doctor.specialty!);
      }
    }
    specialties.value = uniqueSpecialties.toList();
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
                (doc.specialty != null &&
                    doc.specialty!.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ));
            final matchesSpecialty =
                selectedSpecialty.value == 'All' ||
                doc.specialty == selectedSpecialty.value;
            return matchesSearch && matchesSpecialty;
          }).toList();
    }
    // Apply current sort option after filtering
    sortDoctors(selectedSortOption.value);
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

    // Reset pagination and reload when specialty changes
    if (selectedSpecialty.value != specialty) {
      fetchDoctors(isRefresh: true);
    } else {
      filterDoctors();
    }
  }

  void clearSearch() {
    searchController.clear();
    filterDoctors();
  }

  // Add a refresh method to reset pagination and reload
  Future<void> refreshDoctors() async {
    await fetchDoctors(isRefresh: true);
  }

  void sortDoctors(DoctorSortOption option) {
    selectedSortOption.value = option;
    
    switch (option) {
      case DoctorSortOption.rating_high_to_low:
        filteredDoctors.sort((a, b) {
          final ratingA = a.rating ?? 0.0;
          final ratingB = b.rating ?? 0.0;
          return ratingB.compareTo(ratingA); // High to low
        });
        break;
        
      case DoctorSortOption.price_low_to_high:
        filteredDoctors.sort((a, b) {
          final priceA = a.price ?? _calculateDefaultPrice(a);
          final priceB = b.price ?? _calculateDefaultPrice(b);
          return priceA.compareTo(priceB); // Low to high
        });
        break;
        
      case DoctorSortOption.price_high_to_low:
        filteredDoctors.sort((a, b) {
          final priceA = a.price ?? _calculateDefaultPrice(a);
          final priceB = b.price ?? _calculateDefaultPrice(b);
          return priceB.compareTo(priceA); // High to low
        });
        break;
        
      case DoctorSortOption.default_sort:
      default:
        // Keep default sorting or implement default sorting logic
        break;
    }
    
    // Trigger UI update
    filteredDoctors.refresh();
  }
  
  // Helper method to calculate default price for sorting
  double _calculateDefaultPrice(UserModel doctor) {
    double basePrice = 150.0;
    
    if (doctor.specialty != null) {
      switch (doctor.specialty!.toLowerCase()) {
        case 'cardiology':
        case 'neurology':
        case 'oncology':
        case 'orthopedics':
          basePrice += 250.0;
          break;
        case 'dermatology':
        case 'pediatrics':
        case 'psychiatry':
          basePrice += 150.0;
          break;
        default:
          basePrice += 50.0;
      }
    }
    
    if (doctor.rating != null) {
      basePrice += (doctor.rating! * 20.0);
    }
    
    return basePrice;
  }
}
