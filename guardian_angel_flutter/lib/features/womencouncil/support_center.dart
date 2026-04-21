import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/theme.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Women Council Support')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.phone, color: Colors.green),
              title: Text('Women Helpline'),
              subtitle: Text('1091'),
              trailing: Icon(Icons.call),
              onTap: () => launchUrl(Uri.parse('tel:1091')),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.support_agent),
              title: Text('Legal Aid'),
              subtitle: Text('Call for legal help'),
              onTap: () => _requestSupport('legal'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.chat),
              title: Text('Mental Health Counselor'),
              subtitle: Text('Chat support'),
              onTap: () => _requestSupport('counseling'),
            ),
          ),
          Card(
            child: ExpansionTile(
              title: Text('Verified NGOs'),
              children: [
                ListTile(title: Text('Women Safety NGO'), subtitle: Text('Contact info')),
                ListTile(title: Text('Legal Aid Society'), subtitle: Text('Contact info')),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => _openComplaintForm(context),
            child: Text('File Emergency Complaint'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestSupport(String type) async {
    final data = {'type': type, 'description': 'Need immediate support'};
    await ApiService.post('/support', data);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent')));
  }

  void _openComplaintForm(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintForm()));
  }
}

class ComplaintForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency Complaint')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Complaint Details')),
            ElevatedButton(onPressed: () {}, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}

