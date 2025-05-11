import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pharmacy_model.dart';

class PharmacyScreen extends StatelessWidget {
  PharmacyScreen({Key? key}) : super(key: key);

  // Sample pharmacy data for Alexandria
  final List<PharmacyModel> pharmacies = [
    PharmacyModel(
      id: '1',
      name: 'El Ezaby Pharmacy',
      address: '144 El-Horreya Road, Alexandria',
      latitude: 31.2057,
      longitude: 29.9244,
      phoneNumber: '+201234567890',
      facebookUrl: 'https://www.facebook.com/ElEzabyPharmacies',
      imageUrl: 'https://example.com/elezaby.jpg',
    ),
    PharmacyModel(
      id: '2',
      name: 'Seif Pharmacy',
      address: '12 Syria St., Roushdy, Alexandria',
      latitude: 31.2196,
      longitude: 29.9426,
      phoneNumber: '+201098765432',
      facebookUrl: 'https://www.facebook.com/SeifPharmacies',
      imageUrl: 'https://example.com/seif.jpg',
    ),
    PharmacyModel(
      id: '3',
      name: '19011 Pharmacy',
      address: '15 Victor Emmanuel St., Smouha, Alexandria',
      latitude: 31.2060,
      longitude: 29.9401,
      phoneNumber: '+201112223344',
      facebookUrl: 'https://www.facebook.com/19011Pharmacies',
      imageUrl: 'https://example.com/19011.jpg',
    ),
    PharmacyModel(
      id: '4',
      name: 'El Dawlia Pharmacy',
      address: '560 El-Horreya Road, Alexandria',
      latitude: 31.2099,
      longitude: 29.9319,
      phoneNumber: '+201566778899',
      facebookUrl: 'https://www.facebook.com/ElDawliaPharmacy',
      imageUrl: null,
    ),
    PharmacyModel(
      id: '5',
      name: 'Amin Pharmacy',
      address: '377 El-Geish Road, Alexandria',
      latitude: 31.2125,
      longitude: 29.9153,
      phoneNumber: '+201033445566',
      facebookUrl: 'https://www.facebook.com/AminPharmacy',
      imageUrl: null,
    ),
  ];

  // Function to open Google Maps with the pharmacy's location
  Future<void> _openGoogleMaps(double latitude, double longitude, String name) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Function to open Facebook page
  Future<void> _openFacebookPage(String facebookUrl) async {
    final Uri url = Uri.parse(facebookUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alexandria Pharmacies'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: pharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = pharmacies[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pharmacy.imageUrl != null)
                  Image.network(
                    pharmacy.imageUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.local_pharmacy, size: 50),
                      );
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.local_pharmacy, size: 50),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(pharmacy.address),
                      if (pharmacy.phoneNumber != null) ...[
                        const SizedBox(height: 4),
                        Text('Phone: ${pharmacy.phoneNumber}'),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.location_on),
                            label: const Text('Google Maps'),
                            onPressed: () {
                              _openGoogleMaps(
                                pharmacy.latitude, 
                                pharmacy.longitude, 
                                pharmacy.name
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          if (pharmacy.facebookUrl != null)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.facebook),
                              label: const Text('Facebook'),
                              onPressed: () {
                                _openFacebookPage(pharmacy.facebookUrl!);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
