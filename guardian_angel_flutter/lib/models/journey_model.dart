import 'package:google_maps_flutter/google_maps_flutter.dart'; // Corrected import
import 'package:intl/intl.dart'; // Corrected import

class JourneyModel {
  final String id;
  final String userId;
  final List<String> watcherIds;
  final LatLng? startLocation;
  final LatLng? endLocation;
  final DateTime startTime;
  DateTime? endTime;
  bool arrivedSafely;
  bool isActive;
  int checkInIntervalMinutes;
  DateTime? nextCheckInTime;

  JourneyModel({
    required this.id,
    required this.userId,
    required this.watcherIds,
    this.startLocation,
    this.endLocation,
    required this.startTime,
    this.endTime,
    this.arrivedSafely = false,
    this.isActive = true,
    this.checkInIntervalMinutes = 15,
    this.nextCheckInTime,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) {
    return JourneyModel(
      id: json['_id'],
      userId: json['user'],
      watcherIds: List<String>.from(json['watchers'] ?? []),
      startLocation: json['startLocation'] != null ? LatLng(json['startLocation']['lat'], json['startLocation']['lng']) : null,
      endLocation: json['endLocation'] != null ? LatLng(json['endLocation']['lat'], json['endLocation']['lng']) : null,
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      arrivedSafely: json['arrivedSafely'] ?? false,
      isActive: json['isActive'] ?? true,
      checkInIntervalMinutes: json['checkInIntervalMinutes'] ?? 15,
      nextCheckInTime: json['nextCheckInTime'] != null ? DateTime.parse(json['nextCheckInTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'watcherIds': watcherIds,
      'startLocation': startLocation != null ? {'lat': startLocation!.latitude, 'lng': startLocation!.longitude} : null,
      'endLocation': endLocation != null ? {'lat': endLocation!.latitude, 'lng': endLocation!.longitude} : null,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'arrivedSafely': arrivedSafely,
      'isActive': isActive,
      'checkInIntervalMinutes': checkInIntervalMinutes,
      'nextCheckInTime': nextCheckInTime?.toIso8601String(),
    };
  }

  String get formattedStartTime => DateFormat('MMM d, yyyy HH:mm').format(startTime.toLocal());
  String get formattedEndTime => endTime != null ? DateFormat('MMM d, yyyy HH:mm').format(endTime!.toLocal()) : 'N/A';
  String get formattedNextCheckInTime => nextCheckInTime != null ? DateFormat('HH:mm').format(nextCheckInTime!.toLocal()) : 'N/A';
}