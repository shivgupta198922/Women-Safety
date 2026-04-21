import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EvidenceService {
  static CameraController? _controller;
  static bool _isRecording = false;
  static bool _isScreenOffRecord = false;

  static Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
  }

  static Future<void> startSecretRecording({bool screenOff = false}) async {
    _isRecording = true;
    _isScreenOffRecord = screenOff;
    // Start video/audio recording
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/evidence_${DateTime.now().millisecondsSinceEpoch}.mp4';
    // Record to path
    await Future.delayed(Duration(seconds: 30)); // Max 30s secret record
    await _uploadEvidence(path);
  }

  static Future<void> _uploadEvidence(String path) async {
    // Multer backend upload /evidence
    final request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/evidence'));
    request.files.add(await http.MultipartFile.fromPath('file', path));
    final response = await request.send();
    if (response.statusCode == 201) {
      print('Evidence uploaded');
    }
    await File(path).delete();
  }

  static Future<void> stopRecording() async {
    _isRecording = false;
    _controller?.stopImageStream();
  }
}

