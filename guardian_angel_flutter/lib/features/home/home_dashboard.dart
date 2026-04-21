import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/socket_service.dart';
import '../sos/sos_screen.dart';
import '../contacts/contacts_screen.dart'; // to be created
import '../maps/live_tracking_screen.dart'; // to be created
import '../checkin/checkin_screen.dart'; // to be created
import '../nearby/nearby_services_screen.dart'; // to be created
import '../settings/settings_screen.dart'; // to be created

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().user!.id;
    SocketService.connect(userId);
    _updateLocationPeriodic();
  }

  void _updateLocationPeriodic() async {
    while (mounted) {
      try {
        Position pos = await Geolocator.getCurrentPosition();
        final location = {'lat': pos.latitude, 'lng': pos.longitude};
        SocketService.liveLocation({'userId': context.read<AuthProvider>().user!.id, 'location': location});
      } catch (e) {}
      await Future.delayed(Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardian Angel Dashboard'),
        actions: [
          IconButton(icon: Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()))),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            _buildTile('SOS', Icons.sos, () => Navigator.push(context, MaterialPageRoute(builder: (context) => SOSScreen()))),
            _buildTile('Shake SOS', Icons.phone_vibration, () => print('Shake activated')),
            _buildTile('Voice Help', Icons.record_voice_over, () => print('Voice help')),
            _buildTile('Fake Call', Icons.call, () => print('Fake call')),
            _buildTile('Emergency Contacts', Icons.contacts, () => Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsScreen()))),
            _buildTile('Live Tracking', Icons.map, () => Navigator.push(context, MaterialPageRoute(builder: (context) => LiveTrackingScreen()))),
            _buildTile('Nearby Help', Icons.local_hospital, () => Navigator.push(context, MaterialPageRoute(builder: (context) => NearbyServicesScreen()))),
            _buildTile('Safety Check-in', Icons.timer, () => Navigator.push(context, MaterialPageRoute(builder: (context) => CheckinScreen()))),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SOSScreen())),
        icon: Icon(Icons.sos, color: Colors.white),
        label: Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color(0xFF7B2CBF)),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    SocketService.disconnect();
    super.dispose();
  }
}
