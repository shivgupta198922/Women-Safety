import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../services/api_service.dart';
import '../../core/theme.dart';

class RaiseConcernScreen extends StatefulWidget {
  const RaiseConcernScreen({super.key});

  @override
  State<RaiseConcernScreen> createState() => _RaiseConcernScreenState();
}

class _RaiseConcernScreenState extends State<RaiseConcernScreen> {
  String selectedType = 'harassment';
  final types = ['stalking', 'harassment', 'unsafe_taxi', 'unsafe_location', 'suspicious'];
  final descriptionController = TextEditingController();
  bool anonymous = false;
  List<XFile> evidence = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Raise Concern')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(labelText: 'Concern Type'),
              items: types.map((type) => DropdownMenuItem(value: type, child: Text(type.toUpperCase()))).toList(),
              onChanged: (value) => setState(() => selectedType = value!),
            ),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SwitchListTile(
              title: Text('Anonymous'),
              value: anonymous,
              onChanged: (value) => setState(() => anonymous = value),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Add Evidence'),
              onPressed: _addEvidence,
            ),
            if (evidence.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: evidence.length,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Stack(
                      children: [
                        Image.file(File(evidence[index].path), width: 100, height: 100, fit: BoxFit.cover),
                        Positioned(top: 0, right: 0, child: IconButton(icon: Icon(Icons.close), onPressed: () {})),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: _submitConcern,
              child: Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addEvidence() async {
    // Camera picker for photo/video
  }

  Future<void> _submitConcern() async {
    final data = {
      'type': selectedType,
      'description': descriptionController.text,
      'anonymous': anonymous,
      // location, evidence URLs
    };
    await ApiService.post('/concern', data);
    Navigator.pop(context);
  }
}

