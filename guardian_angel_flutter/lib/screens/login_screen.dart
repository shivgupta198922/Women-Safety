import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart' hide GlassCard;
import 'package:animate_do/animate_do.dart'; // For animations
import '../../providers/auth_provider.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart'; // Import GlassCard

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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() { _isLoading = true; });
      Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text)
          .then((success) {
        if (mounted) {
          if (success) {
            AppUtils.showSnackBar(context, 'Login Successful!');
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            final message = context.read<AuthProvider>().errorMessage ?? 'Login failed. Please check your credentials.';
            AppUtils.showSnackBar(context, message, isError: true);
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
                        const Icon(
                          Icons.health_and_safety,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 32),
                        
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please enter your email';
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                            return null; // Valid
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          controller: _passwordController,
                          obscureText: true,
                          hintText: 'Password',
                          icon: Icons.lock,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement Forgot Password
                              AppUtils.showSnackBar(context, 'Forgot Password functionality coming soon!');
                            },
                            child: const Text('Forgot Password?', style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        CustomButton(
                          text: 'LOGIN',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        
                        // Sign Up Navigation
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'Don\'t have an account? Sign up',
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
