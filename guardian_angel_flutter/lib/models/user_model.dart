class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePic;
  final bool isAdmin;
  final Map<String, dynamic> settings; // Changed from safetySettings
  final Map<String, dynamic>? lastLocation;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePic,
    this.isAdmin = false, // Initialize isAdmin here
    required this.settings,
    this.lastLocation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      fullName: json['fullName'] ?? '', // Use fullName
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? '', // Use phoneNumber
      profilePic: json['profilePic'],
      isAdmin: json['isAdmin'] ?? false,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}), // Use settings
      lastLocation: json['lastLocation'],
    );
  }
}
