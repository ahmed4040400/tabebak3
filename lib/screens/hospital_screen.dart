import 'package:flutter/material.dart';
import 'package:faker/faker.dart' as faker;
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class HospitalScreen extends StatelessWidget {
  HospitalScreen({Key? key}) : super(key: key);

  final fakerInstance = faker.Faker();

  // Simulated current user location (Alexandria center)
  final Map<String, double> currentLocation = {'lat': 31.2001, 'lng': 29.9187};

  // Egyptian hospital names and locations (Cairo and Alexandria)
  final List<Map<String, dynamic>> hospitals = [
    // Cairo hospitals
    {
      'name': 'Cairo University Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0277, 'lng': 31.2126},
      'hasER': true,
      'type': 'Public',
    },
    {
      'name': 'Ain Shams University Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0705, 'lng': 31.2818},
      'hasER': true,
      'type': 'Public',
    },
    {
      'name': 'El-Salam International Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0444, 'lng': 31.2357},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'Dar Al Fouad Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 29.9773, 'lng': 31.2560},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'Al-Andalusia Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0566, 'lng': 31.3493},
      'hasER': false,
      'type': 'Private',
    },
    {
      'name': 'El-Nile Badrawi Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0222, 'lng': 31.2304},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'Saudi German Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0292, 'lng': 31.2089},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'Air Force Specialized Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0648, 'lng': 31.2569},
      'hasER': true,
      'type': 'Public',
    },
    {
      'name': 'Al-Gamal Hospital',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0408, 'lng': 31.2355},
      'hasER': false,
      'type': 'Private',
    },
    {
      'name': 'International Medical Center',
      'city': 'Cairo',
      'coordinates': {'lat': 30.0600, 'lng': 31.2253},
      'hasER': true,
      'type': 'Private',
    },
    
    // Alexandria hospitals
    {
      'name': 'Alexandria University Main Hospital',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2090, 'lng': 29.9160},
      'hasER': true,
      'type': 'Public',
    },
    {
      'name': 'El Shatby University Hospital',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2122, 'lng': 29.9214},
      'hasER': true,
      'type': 'Public',
    },
    {
      'name': 'Alexandria Medical Center',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2150, 'lng': 29.9420},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'Alexandria International Hospital',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2230, 'lng': 29.9490},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'Andalusia Hospital Alexandria',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2170, 'lng': 29.9240},
      'hasER': false,
      'type': 'Private',
    },
    {
      'name': 'Smouha Specialized Hospital',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2010, 'lng': 29.9350},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'El Madina Hospital',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2150, 'lng': 29.9290},
      'hasER': false,
      'type': 'Private',
    },
    {
      'name': 'Victoria Hospital',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2080, 'lng': 29.9230},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'Dar Al Shefaa Hospital',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.1980, 'lng': 29.9190},
      'hasER': true,
      'type': 'Private',
    },
    {
      'name': 'German Hospital Alexandria',
      'city': 'Alexandria',
      'coordinates': {'lat': 31.2100, 'lng': 29.9300},
      'hasER': true,
      'type': 'Private',
    },
  ];

  // Function to calculate distance between two coordinates using Haversine formula
  double _calculateDistance(Map<String, double> coord1, Map<String, double> coord2) {
    const R = 6371.0; // Earth radius in kilometers
    
    double lat1 = coord1['lat']! * pi / 180;
    double lon1 = coord1['lng']! * pi / 180;
    double lat2 = coord2['lat']! * pi / 180;
    double lon2 = coord2['lng']! * pi / 180;
    
    double dlon = lon2 - lon1;
    double dlat = lat2 - lat1;
    
    double a = sin(dlat/2) * sin(dlat/2) + cos(lat1) * cos(lat2) * sin(dlon/2) * sin(dlon/2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = R * c;
    
    return distance;
  }

  // Function to launch Google Maps with the hospital location
  Future<void> _launchMaps(Map<String, double> coordinates) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${coordinates['lat']},${coordinates['lng']}',
    );
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort hospitals by distance from current location
    List<Map<String, dynamic>> sortedHospitals = List.from(hospitals);
    
    // Calculate and add distance to each hospital
    for (var hospital in sortedHospitals) {
      hospital['distance'] = _calculateDistance(
        currentLocation, 
        hospital['coordinates'] as Map<String, double>
      );
    }
    
    // Sort by distance
    sortedHospitals.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search hospitals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Nearby'),
                _buildFilterChip('Alexandria'),
                _buildFilterChip('Cairo'),
                _buildFilterChip('Public'),
                _buildFilterChip('Private'),
                _buildFilterChip('Emergency'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hospital list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: sortedHospitals.length,
              itemBuilder: (context, index) {
                final hospital = sortedHospitals[index];
                final name = hospital['name'] as String;
                final isEmergencyAvailable = hospital['hasER'] as bool;
                final rating = 3.5 + fakerInstance.randomGenerator.decimal() * 1.5;
                final distance = hospital['distance'] as double;
                
                // Format distance text
                final distanceText = distance < 1.0
                  ? '${(distance * 1000).toInt()}m away'
                  : '${distance.toStringAsFixed(1)}km away';
                
                final departments = fakerInstance.randomGenerator.integer(6) + 3;
                final city = hospital['city'] as String;

                return _buildHospitalCard(
                  name,
                  isEmergencyAvailable,
                  rating,
                  distanceText,
                  departments,
                  city,
                  hospital['coordinates'] as Map<String, double>,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(label: Text(label), backgroundColor: Colors.grey[200]),
    );
  }

  Widget _buildHospitalCard(
    String name,
    bool isEmergencyAvailable,
    double rating,
    String distance,
    int departments,
    String city,
    Map<String, double> coordinates,
  ) {
    // Find the hospital type from the hospitals list
    final hospitalData = hospitals.firstWhere(
      (hospital) => hospital['name'] == name,
      orElse: () => {'type': 'Unknown'},
    );
    
    final hospitalType = hospitalData['type'] as String;
    final isPublic = hospitalType == 'Public';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.local_hospital, color: Colors.blue),
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
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Hospital type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isPublic 
                                ? Colors.blue[100] 
                                : Colors.purple[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isPublic 
                                  ? Colors.blue[400]! 
                                  : Colors.purple[400]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              hospitalType,
                              style: TextStyle(
                                color: isPublic 
                                  ? Colors.blue[800] 
                                  : Colors.purple[800],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(
                            ' ${rating.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.location_city, color: Colors.grey[600], size: 14),
                          Text(
                            ' $city',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red[400], size: 14),
                          Flexible(
                            child: Text(
                              ' $distance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isEmergencyAvailable
                        ? Colors.red[100]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isEmergencyAvailable ? 'ER' : 'No ER',
                    style: TextStyle(
                      color: isEmergencyAvailable
                          ? Colors.red[800]
                          : Colors.grey[800],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8.0,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      '$departments Depts',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ],
                ),
                const Spacer(),
                Wrap(
                  spacing: 8.0,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(60, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Details',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(60, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Call', style: TextStyle(fontSize: 12)),
                    ),
                    ElevatedButton(
                      onPressed: () => _launchMaps(coordinates),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(60, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Maps',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
