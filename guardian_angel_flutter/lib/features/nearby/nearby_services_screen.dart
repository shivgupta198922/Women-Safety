import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../core/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyServicesScreen extends StatefulWidget {
  const NearbyServicesScreen({super.key});

  @override
  State<NearbyServicesScreen> createState() => _NearbyServicesScreenState();
}

class _NearbyServicesScreenState extends State<NearbyServicesScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  String selectedType = 'police'; // police, hospital, pharmacy

  final List<Map<String, dynamic>> services = [
    {'type': 'police', 'icon': Icons.local_police, 'name': 'Police Stations'},
    {'type': 'hospital', 'icon': Icons.local_hospital, 'name': 'Hospitals'},
    {'type': 'pharmacy', 'icon': Icons.local_pharmacy, 'name': 'Pharmacies'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Safety Services'),
        actions: [
          PopupMenuButton<String>(
            initialValue: selectedType,
            onSelected: (value) => setState(() => selectedType = value),
            itemBuilder: (context) => services.map((s) => PopupMenuItem(
              value: s['type'],
              child: Row(
                children: [Icon(s['icon']), SizedBox(width: 8), Text(s['name'])],
              ),
            )).toList(),
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(28.6139, 77.2090), // Default Delhi
                    zoom: 12,
                  ),
                  markers: markers,
                  myLocationEnabled: true,
                  onMapCreated: (controller) => mapController = controller,
                ),
              ),
              Container(
                height: 120,
                padding: EdgeInsets.all(16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedType = service['type']),
                      child: Card(
                        color: selectedType == service['type'] ? primaryGradientStart : null,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(service['icon'], color: Colors.white, size: 32),
                              SizedBox(height: 4),
                              Text(
                                service['name'],
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _searchNearby,
        child: Icon(Icons.search),
      ),
    );
  }

  Future<void> _searchNearby() async {
    final location = context.read<LocationProvider>().currentPosition;
    if (location == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Get location first')));
      return;
    }

    // Google Places API call
    // Add markers for police/hospitals
    final fakeMarkers = [
      Marker(markerId: MarkerId('police1'), position: LatLng(location.latitude + 0.01, location.longitude)),
      Marker(markerId: MarkerId('hospital1'), position: LatLng(location.latitude - 0.01, location.longitude + 0.01)),
    ];
    setState(() => markers = Set.from(fakeMarkers));
  }
}

