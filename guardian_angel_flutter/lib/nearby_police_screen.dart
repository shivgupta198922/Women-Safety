import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../core/theme.dart';
import '../../utils/app_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyPoliceScreen extends StatefulWidget {
  const NearbyPoliceScreen({super.key});

  @override
  State<NearbyPoliceScreen> createState() => _NearbyPoliceScreenState();
}

class _NearbyPoliceScreenState extends State<NearbyPoliceScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  BitmapDescriptor policeIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcon();
  }

  void _setCustomMarkerIcon() async {
    policeIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/police_marker.png', // You'll need to add a police icon asset
    );
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _searchNearbyPolice();
  }

  Future<void> _searchNearbyPolice() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    try {
      await locationProvider.getCurrentLocation();
      final Position? currentPosition = locationProvider.currentPosition;

      if (currentPosition == null) {
        AppUtils.showSnackBar(context, 'Could not get current location.', isError: true);
        return;
      }

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentPosition.latitude, currentPosition.longitude),
          14,
        ),
      );

      // --- Placeholder for Google Places API integration ---
      // In a real application, you would make an API call to Google Places
      // to find nearby police stations.
      // Example:
      // final response = await GooglePlacesApi.search(
      //   type: 'police_station',
      //   location: '${currentPosition.latitude},${currentPosition.longitude}',
      //   radius: 5000, // 5 km radius
      // );
      // Parse response and create markers.
      // -----------------------------------------------------

      // For now, let's add some dummy markers around the current location
      setState(() {
        markers.clear();
        markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(currentPosition.latitude, currentPosition.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );

        // Dummy police station markers
        markers.add(
          Marker(
            markerId: const MarkerId('police_station_1'),
            position: LatLng(currentPosition.latitude + 0.01, currentPosition.longitude + 0.01),
            infoWindow: const InfoWindow(title: 'Police Station A', snippet: 'Tap to navigate'),
            icon: policeIcon,
            onTap: () => _launchMaps(currentPosition.latitude + 0.01, currentPosition.longitude + 0.01),
          ),
        );
        markers.add(
          Marker(
            markerId: const MarkerId('police_station_2'),
            position: LatLng(currentPosition.latitude - 0.005, currentPosition.longitude + 0.02),
            infoWindow: const InfoWindow(title: 'Police Station B', snippet: 'Tap to navigate'),
            icon: policeIcon,
            onTap: () => _launchMaps(currentPosition.latitude - 0.005, currentPosition.longitude + 0.02),
          ),
        );
      });
      AppUtils.showSnackBar(context, 'Nearby police stations loaded.');
    } catch (e) {
      AppUtils.showSnackBar(context, 'Error searching for police stations: $e', isError: true);
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      AppUtils.showSnackBar(context, 'Could not launch Google Maps.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Police Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _searchNearbyPolice,
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(28.6139, 77.2090), // Default to Delhi if no location yet
          zoom: 10,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}