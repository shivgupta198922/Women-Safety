import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/account_types.dart';
import '../../core/theme.dart' hide GlassCard;
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _organizationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _pairingCodeController = TextEditingController();
  final _targetPairingCodeController = TextEditingController();
  bool _isLoading = false;
  String _selectedAccountType = AppAccountTypes.individual;
  bool _allowNotifications = true;
  bool _allowLiveLocation = true;
  bool _allowCamera = false;
  bool _allowMicrophone = false;

  bool get _isParentOrChild =>
      _selectedAccountType == AppAccountTypes.parent ||
      _selectedAccountType == AppAccountTypes.child;

  bool get _isOrganizationAccount =>
      _selectedAccountType == AppAccountTypes.hospital ||
      _selectedAccountType == AppAccountTypes.police ||
      _selectedAccountType == AppAccountTypes.council;

  @override
  void initState() {
    super.initState();
    _pairingCodeController.text = _generatePairingCode();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _organizationController.dispose();
    _departmentController.dispose();
    _pairingCodeController.dispose();
    _targetPairingCodeController.dispose();
    super.dispose();
  }

  String _generatePairingCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateDevicePublicKey() {
    const chars = 'abcdef0123456789';
    final random = Random();
    return 'GA-${List.generate(24, (_) => chars[random.nextInt(chars.length)]).join()}';
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AuthProvider>().register(
            fullName: _fullNameController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            accountType: _selectedAccountType,
            organizationName: _isOrganizationAccount ? _organizationController.text.trim() : null,
            departmentName: (_isOrganizationAccount || _isParentOrChild) ? _departmentController.text.trim() : null,
            securePairing: _isParentOrChild
                ? {
                    'pairingCode': _pairingCodeController.text.trim(),
                    'targetPairingCode': _targetPairingCodeController.text.trim(),
                    'pairingStatus': _targetPairingCodeController.text.trim().isEmpty ? 'unpaired' : 'pending',
                    'devicePublicKey': _generateDevicePublicKey(),
                    'accessPermissions': {
                      'notifications': _allowNotifications,
                      'liveLocation': _allowLiveLocation,
                      'camera': _allowCamera,
                      'microphone': _allowMicrophone,
                    },
                  }
                : null,
          );

      if (!mounted) return;

      if (success) {
        AppUtils.showSnackBar(context, 'Registration successful. Sign in to continue.');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        AppUtils.showSnackBar(
          context,
          context.read<AuthProvider>().errorMessage ?? 'Registration failed. Please try again.',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final selectedOption = AppAccountTypes.byId(_selectedAccountType);

    return Scaffold(
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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: GlassCard(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: isMobile ? 72 : 84,
                              height: isMobile ? 72 : 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.92),
                                    selectedOption.color.withOpacity(0.28),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedOption.color.withOpacity(0.32),
                                    blurRadius: 24,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: Icon(selectedOption.icon, size: isMobile ? 34 : 40, color: selectedOption.color),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              'Create Secure Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isMobile ? 24 : 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Choose a registration type and set up protected access for your safety network.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.76),
                                fontSize: isMobile ? 13 : 15,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Registration Type',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: AppAccountTypes.options.map((option) {
                              final isSelected = option.id == _selectedAccountType;
                              return ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(option.icon, size: 18, color: isSelected ? Colors.white : option.color),
                                    const SizedBox(width: 8),
                                    Text(option.shortLabel),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedAccountType = option.id;
                                    if (_selectedAccountType == AppAccountTypes.parent && _pairingCodeController.text.isEmpty) {
                                      _pairingCodeController.text = _generatePairingCode();
                                    }
                                  });
                                },
                                backgroundColor: Colors.white.withOpacity(0.08),
                                selectedColor: option.color.withOpacity(0.85),
                                side: BorderSide(color: isSelected ? Colors.white.withOpacity(0.35) : Colors.white.withOpacity(0.12)),
                                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selectedOption.color.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: selectedOption.color.withOpacity(0.35)),
                            ),
                            child: Text(
                              selectedOption.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _SectionLabel(title: 'Basic Details'),
                          const SizedBox(height: 14),
                          _buildResponsiveFields(
                            isMobile: isMobile,
                            children: [
                              CustomTextField(
                                controller: _fullNameController,
                                hintText: 'Full Name',
                                icon: Icons.person,
                                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
                              ),
                              CustomTextField(
                                controller: _phoneNumberController,
                                hintText: 'Phone Number',
                                icon: Icons.phone,
                                keyboardType: TextInputType.phone,
                                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your phone number' : null,
                              ),
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) return 'Please enter your email';
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                              CustomTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                icon: Icons.lock,
                                obscureText: true,
                                validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirm Password',
                            icon: Icons.lock_reset,
                            obscureText: true,
                            validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                          ),
                          if (_isOrganizationAccount) ...[
                            const SizedBox(height: 24),
                            _SectionLabel(title: 'Organization Verification'),
                            const SizedBox(height: 14),
                            _buildResponsiveFields(
                              isMobile: isMobile,
                              children: [
                                CustomTextField(
                                  controller: _organizationController,
                                  hintText: 'Organization / Unit Name',
                                  icon: Icons.apartment_rounded,
                                  validator: (value) => value == null || value.trim().isEmpty ? 'Organization name is required' : null,
                                ),
                                CustomTextField(
                                  controller: _departmentController,
                                  hintText: 'Department / Desk',
                                  icon: Icons.badge_rounded,
                                  validator: (value) => value == null || value.trim().isEmpty ? 'Department is required' : null,
                                ),
                              ],
                            ),
                          ],
                          if (_isParentOrChild) ...[
                            const SizedBox(height: 24),
                            _SectionLabel(title: 'Secure Parent-Child Link'),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF0F172A).withOpacity(0.7),
                                    selectedOption.color.withOpacity(0.18),
                                  ],
                                ),
                                border: Border.all(color: Colors.white.withOpacity(0.14)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedAccountType == AppAccountTypes.parent
                                        ? 'Create a secure family key for your child app'
                                        : 'Enter the family key shared by the parent account',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This setup stores a pairing code, a device key fingerprint, and consent-based access preferences for alerts, location, camera, and microphone.',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 12.5,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildResponsiveFields(
                                    isMobile: isMobile,
                                    children: [
                                      CustomTextField(
                                        controller: _pairingCodeController,
                                        hintText: 'Your Secure Pairing Key',
                                        icon: Icons.key_rounded,
                                        validator: (value) {
                                          if (_selectedAccountType == AppAccountTypes.parent && (value == null || value.trim().length < 6)) {
                                            return 'Pairing key must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                                          onPressed: () {
                                            setState(() {
                                              _pairingCodeController.text = _generatePairingCode();
                                            });
                                          },
                                        ),
                                      ),
                                      CustomTextField(
                                        controller: _targetPairingCodeController,
                                        hintText: _selectedAccountType == AppAccountTypes.parent
                                            ? 'Child Device Pairing Key (optional)'
                                            : 'Parent Pairing Key',
                                        icon: Icons.link_rounded,
                                        validator: (value) {
                                          if (_selectedAccountType == AppAccountTypes.child && (value == null || value.trim().length < 6)) {
                                            return 'Parent pairing key is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      CustomTextField(
                                        controller: _departmentController,
                                        hintText: _selectedAccountType == AppAccountTypes.parent ? 'Child Name / Label' : 'Parent Name / Label',
                                        icon: Icons.label_rounded,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Protected access permissions',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.92),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _PermissionToggle(
                                    icon: Icons.notifications_active_rounded,
                                    title: 'Emergency notifications',
                                    value: _allowNotifications,
                                    onChanged: (value) => setState(() => _allowNotifications = value),
                                  ),
                                  _PermissionToggle(
                                    icon: Icons.location_on_rounded,
                                    title: 'Live location sharing',
                                    value: _allowLiveLocation,
                                    onChanged: (value) => setState(() => _allowLiveLocation = value),
                                  ),
                                  _PermissionToggle(
                                    icon: Icons.videocam_rounded,
                                    title: 'Camera access during emergency',
                                    value: _allowCamera,
                                    onChanged: (value) => setState(() => _allowCamera = value),
                                  ),
                                  _PermissionToggle(
                                    icon: Icons.mic_rounded,
                                    title: 'Microphone access during emergency',
                                    value: _allowMicrophone,
                                    onChanged: (value) => setState(() => _allowMicrophone = value),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          CustomButton(
                            text: 'REGISTER',
                            onPressed: _handleRegister,
                            isLoading: _isLoading,
                            backgroundColor: selectedOption.color.withOpacity(0.92),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Already have an account? Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveFields({
    required bool isMobile,
    required List<Widget> children,
  }) {
    if (isMobile) {
      return Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: children
          .map(
            (child) => SizedBox(
              width: 390,
              child: child,
            ),
          )
          .toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white.withOpacity(0.92),
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PermissionToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionToggle({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.86)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.greenAccent.shade400,
          ),
        ],
      ),
    );
  }
}
