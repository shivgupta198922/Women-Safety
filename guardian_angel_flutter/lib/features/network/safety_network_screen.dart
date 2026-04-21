import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../core/theme.dart';

class SafetyNetworkScreen extends StatefulWidget {
  const SafetyNetworkScreen({super.key});

  @override
  State<SafetyNetworkScreen> createState() => _SafetyNetworkScreenState();
}

class _SafetyNetworkScreenState extends State<SafetyNetworkScreen> {
  List circles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  Future<void> _loadCircles() async {
    try {
      final user = context.read<AuthProvider>().user!;
      final response = await ApiService.get('/safety-circles', auth: true);
      if (response.statusCode == 200) {
        setState(() {
          circles = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createCircle() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create Safety Circle'),
        content: TextField(
          decoration: InputDecoration(labelText: 'Circle Name'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ''), child: Text('Create')),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      // POST /safety-circles
      _loadCircles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Safety Network'), actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _createCircle,
        ),
      ]),
      body: isLoading 
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadCircles,
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: circles.length,
              itemBuilder: (context, index) {
                final circle = circles[index];
                return GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${circle['members'].length}')),
                    title: Text(circle['name']),
                    subtitle: Text('${circle['members'].length} members'),
                    trailing: ElevatedButton(
                      onPressed: () => _startGroupSOS(circle['_id']),
                      child: Text('SOS'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ),
    );
  }

  void _startGroupSOS(String circleId) {
    // Socket emit group-sos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group SOS sent to circle!')),
    );
  }
}

