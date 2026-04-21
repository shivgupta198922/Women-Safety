import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../home/home_dashboard.dart'; // to be created

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _emailController, decoration: InputDecoration(labelText: 'Email'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: 'Phone'), validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(controller: _passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password'), validator: (v) => v!.length < 6 ? 'Min 6 chars' : null),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final success = await context.read<AuthProvider>().register(
                      _nameController.text,
                      _emailController.text,
                      _phoneController.text,
                      _passwordController.text,
                    );
                    if (success) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeDashboard()));
                  }
                },
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Already have account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
