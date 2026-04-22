import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/account_types.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart' hide GlassCard;
import '../../utils/app_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart'; // Import GlassCard

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController = TextEditingController(text: authProvider.user?.fullName);
    _emailController = TextEditingController(text: authProvider.user?.email);
    _phoneNumberController = TextEditingController(text: authProvider.user?.phoneNumber);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<AuthProvider>(context, listen: false).updateUser(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phoneNumber: _phoneNumberController.text,
        );
        if (mounted) AppUtils.showSnackBar(context, 'Profile updated successfully!');
        _toggleEdit(); // Exit edit mode
      } catch (e) {
        if (mounted) AppUtils.showSnackBar(context, 'Failed to update profile: $e', isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final accountType = AppAccountTypes.byId(user?.accountType);
    final securePairing = user?.securePairing ?? const <String, dynamic>{};
    final accessPermissions = Map<String, dynamic>.from(securePairing['accessPermissions'] ?? {});

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: isDark ? GuardianTheme.darkGradientStart : GuardianTheme.primaryGradientStart,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEdit,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [GuardianTheme.darkGradientStart, GuardianTheme.darkGradientEnd]
                : [GuardianTheme.primaryGradientStart, GuardianTheme.primaryGradientEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: accountType.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: accountType.color.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(accountType.icon, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            accountType.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    CustomTextField(
                      controller: _fullNameController,
                      hintText: 'Full Name',
                      icon: Icons.person,
                      enabled: _isEditing,
                      validator: (value) => value == null || value.isEmpty ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneNumberController,
                      hintText: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      enabled: _isEditing,
                      validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
                    ),
                    if ((user?.organizationName ?? '').isNotEmpty || (user?.departmentName ?? '').isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _InfoCard(
                        title: 'Organization',
                        lines: [
                          if ((user?.organizationName ?? '').isNotEmpty) 'Name: ${user!.organizationName}',
                          if ((user?.departmentName ?? '').isNotEmpty) 'Department: ${user!.departmentName}',
                        ],
                      ),
                    ],
                    if (securePairing.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _InfoCard(
                        title: 'Secure Pairing',
                        lines: [
                          if ((securePairing['pairingCode'] ?? '').toString().isNotEmpty) 'Your key: ${securePairing['pairingCode']}',
                          if ((securePairing['targetPairingCode'] ?? '').toString().isNotEmpty) 'Linked key: ${securePairing['targetPairingCode']}',
                          'Status: ${securePairing['pairingStatus'] ?? 'unpaired'}',
                          if ((securePairing['devicePublicKey'] ?? '').toString().isNotEmpty)
                            'Device fingerprint: ${securePairing['devicePublicKey']}',
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _PermissionChip(
                            label: 'Notifications',
                            active: accessPermissions['notifications'] != false,
                          ),
                          _PermissionChip(
                            label: 'Location',
                            active: accessPermissions['liveLocation'] != false,
                          ),
                          _PermissionChip(
                            label: 'Camera',
                            active: accessPermissions['camera'] == true,
                          ),
                          _PermissionChip(
                            label: 'Microphone',
                            active: accessPermissions['microphone'] == true,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    if (_isEditing)
                      CustomButton(
                        text: 'SAVE CHANGES',
                        onPressed: _saveProfile,
                        isLoading: _isLoading,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _InfoCard({
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                line,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.76),
                  height: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionChip extends StatelessWidget {
  final String label;
  final bool active;

  const _PermissionChip({
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (active ? Colors.greenAccent : Colors.white54).withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? Colors.greenAccent.withOpacity(0.35) : Colors.white24,
        ),
      ),
      child: Text(
        '$label ${active ? 'On' : 'Off'}',
        style: TextStyle(
          color: active ? Colors.greenAccent.shade100 : Colors.white70,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
