import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/socket_service.dart';
import '../../services/api_service.dart';
import 'dart:convert';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool _isSending = false;

  Future<void> _sendSOS(String type) async {
    try {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final data = {
        'type': type,
        'location': {'lat': pos.latitude, 'lng': pos.longitude},
        'message': 'Emergency SOS triggered',
      };
      SocketService.sosAlert({
        'userId': context.read<AuthProvider>().user!.id,
        'location': data['location'],
        'type': type,
        'message': data['message'],
      });
      await ApiService.post('/sos', data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SOS sent successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sending SOS')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SOS Emergency')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sos, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text('Emergency SOS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: _isSending ? null : () => _sendSOS('sos_button'),
              child: _isSending 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Send SOS', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => _sendSOS('shake'),
              child: Text('Test Shake SOS'),
            ),
          ],
        ),
      ),
    );
  }
}
