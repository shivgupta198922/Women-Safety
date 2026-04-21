import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../core/theme.dart';
import '../../services/socket_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? mapController;
  String shareLink = 'https://guardianangel.app/track/12345';
  Set<Marker> markers = {};
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking'),
        actions: [
          Switch(value: _isSharing, onChanged: _toggleSharing),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: LatLng(28.6139, 77.2090), zoom: 14),
              myLocationEnabled: true,
              markers: markers,
              onMapCreated: (controller) => mapController = controller,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text('ETA to Destination'),
                    trailing: Text('15 min'),
                  ),
                ),
                SizedBox(height: 16),
                QrImageView(
                  data: shareLink,
                  version: QrVersions.auto,
                  size: 150,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.share),
                  label: Text('Share Live Location'),
                  onPressed: _shareLocation,
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.route),
                  label: Text('End Trip'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _endTrip,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSharing(bool value) {
    setState(() => _isSharing = value);
    if (value) {
      context.read<LocationProvider>().startTracking();
    } else {
      context.read<LocationProvider>().stopTracking();
    }
  }

  void _shareLocation() {
    // Share shareLink
  }

  void _endTrip() {
    // Safe arrival confirm
  }
}

