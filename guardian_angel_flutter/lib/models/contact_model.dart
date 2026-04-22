class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? relationship;
  final bool isEmergency;

  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.relationship,
    this.isEmergency = true,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      relationship: json['relationship'],
      isEmergency: json['isEmergency'] ?? true,
    );
  }
}