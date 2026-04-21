import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../core/theme.dart';

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isRinging = false;
  String callerName = 'Mom';
  Timer? _ringTimer;

  @override
  void dispose() {
    _ringTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startFakeCall() async {
    setState(() => _isRinging = true);
    _ringTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _player.play(AssetSource('sounds/ringtone.mp3'));
    });
    // Log to backend
    await Future.delayed(Duration(seconds: 30)); // Call duration
    _endCall();
  }

  void _endCall() {
    setState(() => _isRinging = false);
    _ringTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isRinging 
        ? Stack(
            children: [
              // Full call UI
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade700],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Column(
                children: [
                  Spacer(),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage('https://via.placeholder.com/120'),
                  ),
                  SizedBox(height: 20),
                  Text(callerName, style: TextStyle(fontSize: 24, color: Colors.white)),
                  Text('Calling...', style: TextStyle(color: Colors.white70)),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.call_end, size: 60, color: Colors.white),
                        onPressed: _endCall,
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up, size: 60, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Instant Fake Call Escape', style: TextStyle(fontSize: 24)),
              SizedBox(height: 40),
              TextField(
                decoration: InputDecoration(labelText: 'Caller Name'),
                onChanged: (value) => callerName = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _startFakeCall,
                child: Text('Start Fake Call NOW', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.timer),
                label: Text('Schedule'),
                onPressed: () {},
              ),
            ],
          ),
    );
  }
}

