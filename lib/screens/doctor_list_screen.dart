import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_list_controller.dart';
import '../models/user_model.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controller safely
    late DoctorListController controller;

    if (!Get.isRegistered<DoctorListController>()) {
      controller = Get.put(DoctorListController());
    } else {
      controller = Get.find<DoctorListController>();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Find the Best Doctor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.refreshDoctors();
            },
            tooltip: 'Refresh doctors list',
          ),
          _buildSortButton(context, controller),
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isGridView.value ? Icons.list : Icons.grid_view,
              ),
              onPressed: () => controller.toggleView(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or specialty',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: controller.clearSearch,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (_) => controller.filterDoctors(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: Obx(
                          () => ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.specialties.length,
                            itemBuilder: (context, index) {
                              final specialty = controller.specialties[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Obx(
                                  () => FilterChip(
                                    label: Text(specialty),
                                    selected:
                                        controller.selectedSpecialty.value ==
                                        specialty,
                                    onSelected:
                                        (selected) => controller.selectSpecialty(
                                          specialty,
                                          selected,
                                        ),
                                    backgroundColor: Colors.white,
                                    selectedColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Obx(() => _buildSortChip(context, controller)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GetX<DoctorListController>(
              builder: (controller) {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredDoctors.isEmpty) {
                  return const Center(child: Text('No doctors found'));
                }

                return controller.isGridView.value
                    ? _buildGridView(context, controller)
                    : _buildListView(context, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, DoctorListController controller) {
    return PopupMenuButton<DoctorSortOption>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort doctors',
      onSelected: (DoctorSortOption option) {
        controller.sortDoctors(option);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<DoctorSortOption>>[
        const PopupMenuItem<DoctorSortOption>(
          value: DoctorSortOption.default_sort,
          child: Text('Default sort'),
        ),
        const PopupMenuItem<DoctorSortOption>(
          value: DoctorSortOption.rating_high_to_low,
          child: Text('Highest rated first'),
        ),
        const PopupMenuItem<DoctorSortOption>(
          value: DoctorSortOption.price_low_to_high,
          child: Text('Price: low to high'),
        ),
        const PopupMenuItem<DoctorSortOption>(
          value: DoctorSortOption.price_high_to_low,
          child: Text('Price: high to low'),
        ),
      ],
    );
  }

  Widget _buildSortChip(BuildContext context, DoctorListController controller) {
    String sortText;
    IconData sortIcon;
    
    switch (controller.selectedSortOption.value) {
      case DoctorSortOption.rating_high_to_low:
        sortText = 'Top Rated';
        sortIcon = Icons.star;
        break;
      case DoctorSortOption.price_low_to_high:
        sortText = 'Price: Low→High';
        sortIcon = Icons.arrow_upward;
        break;
      case DoctorSortOption.price_high_to_low:
        sortText = 'Price: High→Low';
        sortIcon = Icons.arrow_downward;
        break;
      case DoctorSortOption.default_sort:
      default:
        sortText = 'Default Sort';
        sortIcon = Icons.sort;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(sortIcon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(sortText, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        // Always show as selected since we always have a sort type active
        selected: true,
        onSelected: (_) {
          _showSortOptions(context, controller);
        },
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
      ),
    );
  }

  void _showSortOptions(BuildContext context, DoctorListController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sort Doctors By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Default sort'),
                selected: controller.selectedSortOption.value == DoctorSortOption.default_sort,
                onTap: () {
                  controller.sortDoctors(DoctorSortOption.default_sort);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Highest rated first'),
                selected: controller.selectedSortOption.value == DoctorSortOption.rating_high_to_low,
                onTap: () {
                  controller.sortDoctors(DoctorSortOption.rating_high_to_low);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_upward),
                title: const Text('Price: low to high'),
                selected: controller.selectedSortOption.value == DoctorSortOption.price_low_to_high,
                onTap: () {
                  controller.sortDoctors(DoctorSortOption.price_low_to_high);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Price: high to low'),
                selected: controller.selectedSortOption.value == DoctorSortOption.price_high_to_low,
                onTap: () {
                  controller.sortDoctors(DoctorSortOption.price_high_to_low);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDoctorImage(UserModel doctor) {
    // Simple logic to select image based on doctor's name
    if (doctor.name.toLowerCase().contains('a')) {
      return 'assets/doctor2.png';
    } else if (doctor.name.toLowerCase().contains('e')) {
      return 'assets/doctor3.png';
    } else if (doctor.name.toLowerCase().contains('i')) {
      return 'assets/doctor4.png';
    } else if (doctor.name.toLowerCase().contains('o')) {
      return 'assets/doctor5.png';
    } else {
      return 'assets/doctor.png';
    }
  }

  Widget _buildListView(BuildContext context, DoctorListController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = controller.filteredDoctors[index];
        final doctorImage = _getDoctorImage(doctor);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to doctor detail page or book appointment
              Get.toNamed('/doctor-detail', arguments: doctor);
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'doctor-${doctor.uid}',
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage(doctorImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doctor.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (doctor.availability != null && doctor.availability!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Available',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doctor.specialty ?? 'General',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(
                              ' ${doctor.rating?.toStringAsFixed(1) ?? "0.0"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor.bio != null ? 'Has bio' : 'No bio',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_getDoctorPrice(doctor)} EGP',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tap to book',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Book appointment
                                Get.toNamed('/book-appointment', arguments: doctor);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Book Now'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, DoctorListController controller) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: controller.filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = controller.filteredDoctors[index];
        final doctorImage = _getDoctorImage(doctor);

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              // Navigate to doctor detail page or book appointment
              Get.toNamed('/doctor-detail', arguments: doctor);
            },
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      image: DecorationImage(
                        image: AssetImage(doctorImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialty ?? 'General',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 14),
                                Text(
                                  ' ${doctor.rating?.toStringAsFixed(1) ?? "0.0"}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_getDoctorPrice(doctor)} EGP',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            // Book appointment
                            Get.toNamed('/book-appointment', arguments: doctor);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                'Book Now',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDoctorPrice(UserModel doctor) {
    // Generate realistic prices for Egyptian market based on specialty and name length
    if (doctor.price != null) {
      return doctor.price!.toStringAsFixed(0);
    }
    
    // Fallback pricing logic if price isn't set in the model
    int basePrice = 150; // Base consultation price
    
    // Adjust price based on specialty
    if (doctor.specialty != null) {
      switch (doctor.specialty!.toLowerCase()) {
        case 'cardiology':
        case 'neurology':
        case 'oncology':
        case 'orthopedics':
          basePrice += 250; // More expensive specialties
          break;
        case 'dermatology':
        case 'pediatrics':
        case 'psychiatry':
          basePrice += 150; // Medium-priced specialties
          break;
        default:
          basePrice += 50; // General specialties
      }
    }
    
    // Adjust price based on rating
    if (doctor.rating != null) {
      basePrice += (doctor.rating! * 20).toInt();
    }
    
    return basePrice.toString();
  }
}
