import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'package:animate_do/animate_do.dart'; // For animations
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart'; // Import GlassCard

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
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() { _isLoading = true; });
      Provider.of<AuthProvider>(context, listen: false)
          .register(
            _fullNameController.text,
            _phoneNumberController.text,
            _emailController.text,
            _passwordController.text,
          )
          .then((success) {
        if (mounted) {
          if (success) {
            AppUtils.showSnackBar(context, 'Registration Successful! Please log in.');
            Navigator.pushReplacementNamed(context, '/login');
          } else {
            AppUtils.showSnackBar(context, 'Registration failed. Please try again.', isError: true);
          }
        }
      }).catchError((e) {
        if (mounted) {
          AppUtils.showSnackBar(context, e.toString(), isError: true);
        }
      }).whenComplete(() {
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              padding: const EdgeInsets.all(24.0),
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: GlassCard(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_add, size: 64, color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join Guardian Angel Premium',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 32),
                        
                        CustomTextField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          icon: Icons.person,
                          validator: (value) => value == null || value.isEmpty ? 'Please enter your full name' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneNumberController,
                          hintText: 'Phone Number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty ? 'Please enter your phone number' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your email';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm Password',
                          icon: Icons.lock_reset,
                          obscureText: true,
                          validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                        ),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'REGISTER',
                          onPressed: _handleRegister,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Go back to login
                          },
                          child: const Text(
                            'Already have an account? Login',
                            style: TextStyle(color: Colors.white),
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
    );
  }
}