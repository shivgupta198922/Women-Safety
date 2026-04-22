import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

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
        AppUtils.showSnackBar(context, 'Profile updated successfully!');
        _toggleEdit(); // Exit edit mode
      } catch (e) {
        AppUtils.showSnackBar(context, 'Failed to update profile: $e', isError: true);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.watch<AuthProvider>(context);

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