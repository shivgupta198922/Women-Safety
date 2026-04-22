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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedAccountType = AppAccountTypes.individual;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
            accountType: _selectedAccountType,
          );

      if (!mounted) return;

      if (success) {
        final user = context.read<AuthProvider>().user;
        if (user != null && user.accountType != _selectedAccountType) {
          AppUtils.showSnackBar(
            context,
            'Signed in as ${AppAccountTypes.byId(user.accountType).label}.',
          );
        } else {
          AppUtils.showSnackBar(context, 'Login Successful!');
        }
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        AppUtils.showSnackBar(
          context,
          context.read<AuthProvider>().errorMessage ?? 'Login failed. Please check your credentials.',
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
    final isMobile = size.width < 720;
    final selectedRole = AppAccountTypes.byId(_selectedAccountType);

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
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: GlassCard(
                    padding: EdgeInsets.all(isMobile ? 18 : 28),
                    child: Column(
                      children: [
                        if (!isMobile)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _LoginShowcase(
                                  selectedRole: selectedRole,
                                  selectedAccountType: _selectedAccountType,
                                  onRoleChanged: (value) {
                                    setState(() {
                                      _selectedAccountType = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(child: _buildForm(selectedRole, isMobile)),
                            ],
                          )
                        else ...[
                          _LoginShowcase(
                            selectedRole: selectedRole,
                            selectedAccountType: _selectedAccountType,
                            onRoleChanged: (value) {
                              setState(() {
                                _selectedAccountType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildForm(selectedRole, isMobile),
                        ],
                      ],
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

  Widget _buildForm(AccountTypeOption selectedRole, bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: isMobile ? 72 : 80,
              height: isMobile ? 72 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.94),
                    selectedRole.color.withOpacity(0.26),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: selectedRole.color.withOpacity(0.32),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Icon(selectedRole.icon, size: isMobile ? 34 : 40, color: selectedRole.color),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Welcome Back',
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
              'Sign in to your ${selectedRole.shortLabel.toLowerCase()} account',
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontSize: isMobile ? 13 : 15,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            obscureText: true,
            hintText: 'Password',
            icon: Icons.lock,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              return null;
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                AppUtils.showSnackBar(context, 'Forgot Password functionality coming soon!');
              },
              child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: 'LOGIN',
            onPressed: _handleLogin,
            isLoading: _isLoading,
            backgroundColor: selectedRole.color.withOpacity(0.92),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: const Text(
              'Don\'t have an account? Sign up',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginShowcase extends StatelessWidget {
  final AccountTypeOption selectedRole;
  final String selectedAccountType;
  final ValueChanged<String> onRoleChanged;

  const _LoginShowcase({
    required this.selectedRole,
    required this.selectedAccountType,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Account Type',
          style: TextStyle(
            color: Colors.white.withOpacity(0.94),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppAccountTypes.options.map((option) {
            final isSelected = option.id == selectedAccountType;
            return ChoiceChip(
              selected: isSelected,
              onSelected: (_) => onRoleChanged(option.id),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.icon, size: 18, color: isSelected ? Colors.white : option.color),
                  const SizedBox(width: 8),
                  Text(option.shortLabel),
                ],
              ),
              backgroundColor: Colors.white.withOpacity(0.08),
              selectedColor: option.color.withOpacity(0.82),
              side: BorderSide(color: isSelected ? Colors.white.withOpacity(0.32) : Colors.white.withOpacity(0.12)),
              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                selectedRole.color.withOpacity(0.2),
                Colors.white.withOpacity(0.06),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedRole.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                selectedRole.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.76),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              _ShowcasePoint(
                icon: Icons.key_rounded,
                text: 'Role-aware registration for hospital, police, parent, child, council, guardian, and personal accounts.',
              ),
              _ShowcasePoint(
                icon: Icons.link_rounded,
                text: 'Parent-child secure pairing uses family keys, pairing status, and device key fingerprints.',
              ),
              _ShowcasePoint(
                icon: Icons.shield_rounded,
                text: 'Emergency permissions can be prepared for notifications, location, camera, and microphone access.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShowcasePoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ShowcasePoint({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.88), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.74),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
