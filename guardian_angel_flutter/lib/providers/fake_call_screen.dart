import 'package:flutter/material.dart';

class FakeCallScreen extends StatelessWidget {
  const FakeCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fake Call')),
      body: const Center(child: Text('Fake Call Feature (Coming Soon)')),
    );
  }
}