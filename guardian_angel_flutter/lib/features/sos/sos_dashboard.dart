import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/sos_service.dart';
import '../../core/theme.dart';

class SOSDashboard extends StatelessWidget {
  const SOSDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final sosService = SOSService();

    return Scaffold(
      appBar: AppBar(title: Text('SOS Emergency Hub'), backgroundColor: Colors.red),
      body: Column(
        children: [
          // Giant SOS Button
          Container(
            width: double.infinity,
            height: 200,
            margin: EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: CircleBorder(),
              ),
              onPressed: () => sosService.triggerSOS(type: 'button'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos, size: 80, color: Colors.white),
                  Text('EMERGENCY SOS', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          // Quick Triggers
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(20),
              children: [
                _buildTriggerCard('Shake Phone SOS', Icons.phone_vibration, () => sosService.startShakeSOS()),
                _buildTriggerCard('Voice Command', Icons.mic, () => sosService.startVoiceSOS()),
                _buildTriggerCard('Long Press SOS', Icons.touch_app, () {}),
                _buildTriggerCard('Fake Call', Icons.call_end, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: GuardianTheme.primaryColor),
            SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

