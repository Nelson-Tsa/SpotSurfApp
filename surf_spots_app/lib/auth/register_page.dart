import 'package:flutter/material.dart';
import 'package:surf_spots_app/services/auth_service.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/return_button.dart';
import 'package:surf_spots_app/constants/colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showMessage('Veuillez remplir tous les champs', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.registerUser(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      _showMessage('Inscription réussie !');
      // Optionnel : rediriger vers la page de connexion
      Navigator.pushNamed(context, '/login');
    } else {
      _showMessage(result['error'], isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 26.0),
                child: Image.asset('assets/logo/wave.png', width: 130),
              ),
              Column(
                children: [
                  Text(
                    'Surf App',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Find your spot',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600
                      ? 26.0
                      : 80.0,
                ),
                child: Column(
                  children: [
                    CustomInputField(
                      label: 'Name',
                      keyboardType: TextInputType.name,
                      controller: _nameController,
                    ),
                    CustomInputField(
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                    ),
                    CustomInputField(
                      label: 'Password',
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ReturnButton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
