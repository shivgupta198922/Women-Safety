import 'package:flutter/material.dart';

class AccountTypeOption {
  final String id;
  final String label;
  final String shortLabel;
  final IconData icon;
  final Color color;
  final String description;

  const AccountTypeOption({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class AppAccountTypes {
  static const String individual = 'individual';
  static const String parent = 'parent';
  static const String child = 'child';
  static const String hospital = 'hospital';
  static const String police = 'police';
  static const String council = 'council';
  static const String guardian = 'guardian';

  static const List<AccountTypeOption> options = [
    AccountTypeOption(
      id: individual,
      label: 'Individual User',
      shortLabel: 'User',
      icon: Icons.person_rounded,
      color: Color(0xFF38BDF8),
      description: 'Personal safety access with SOS, tracking, and private alerts.',
    ),
    AccountTypeOption(
      id: parent,
      label: 'Parent Account',
      shortLabel: 'Parent',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFF22C55E),
      description: 'Monitor linked children, receive alerts, and review secure live activity.',
    ),
    AccountTypeOption(
      id: child,
      label: 'Children Account',
      shortLabel: 'Child',
      icon: Icons.child_care_rounded,
      color: Color(0xFFF97316),
      description: 'Connect safely with a parent account using a protected pairing key.',
    ),
    AccountTypeOption(
      id: hospital,
      label: 'Hospital Account',
      shortLabel: 'Hospital',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFEF4444),
      description: 'Medical-response registration for verified emergency coordination.',
    ),
    AccountTypeOption(
      id: police,
      label: 'Police Account',
      shortLabel: 'Police',
      icon: Icons.local_police_rounded,
      color: Color(0xFF3B82F6),
      description: 'Law-enforcement response access for incident and dispatch workflows.',
    ),
    AccountTypeOption(
      id: council,
      label: 'Council / Support',
      shortLabel: 'Council',
      icon: Icons.groups_2_rounded,
      color: Color(0xFFA855F7),
      description: 'Women support cells, councils, and community response teams.',
    ),
    AccountTypeOption(
      id: guardian,
      label: 'Guardian Network',
      shortLabel: 'Guardian',
      icon: Icons.shield_rounded,
      color: Color(0xFFEAB308),
      description: 'Trusted family or guardian responder account with shared safety access.',
    ),
  ];

  static AccountTypeOption byId(String? id) {
    return options.firstWhere(
      (option) => option.id == id,
      orElse: () => options.first,
    );
  }
}
