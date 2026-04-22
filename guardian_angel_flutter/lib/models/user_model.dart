class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String accountType;
  final String? organizationName;
  final String? departmentName;
  final String? profilePic;
  final bool isAdmin;
  final Map<String, dynamic> settings; // Changed from safetySettings
  final Map<String, dynamic>? lastLocation;
  final Map<String, dynamic> securePairing;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.accountType = 'individual',
    this.organizationName,
    this.departmentName,
    this.profilePic,
    this.isAdmin = false, // Initialize isAdmin here
    required this.settings,
    this.lastLocation,
    this.securePairing = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      fullName: json['fullName'] ?? '', // Use fullName
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? '', // Use phoneNumber
      accountType: json['accountType'] ?? 'individual',
      organizationName: json['organizationName'],
      departmentName: json['departmentName'],
      profilePic: json['profilePic'],
      isAdmin: json['isAdmin'] ?? false,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}), // Use settings
      lastLocation: json['lastLocation'],
      securePairing: Map<String, dynamic>.from(json['securePairing'] ?? {}),
    );
  }
}
