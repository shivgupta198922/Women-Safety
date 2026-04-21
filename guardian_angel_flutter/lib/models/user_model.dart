class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePic;
  final List<String> emergencyContacts;
  final bool isAdmin;
  final Map<String, dynamic> safetySettings;
  final Map<String, dynamic>? lastLocation;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePic,
    required this.emergencyContacts,
    required this.isAdmin,
    required this.safetySettings,
    this.lastLocation,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePic: json['profilePic'],
      emergencyContacts: List<String>.from(json['emergencyContacts'] ?? []),
      isAdmin: json['isAdmin'] ?? false,
      safetySettings: Map<String, dynamic>.from(json['safetySettings'] ?? {}),
      lastLocation: json['lastLocation'],
    );
  }
}
