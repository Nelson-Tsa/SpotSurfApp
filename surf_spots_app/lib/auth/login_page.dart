import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/return_button.dart';
import '../services/auth_service.dart';
import '../providers/spots_provider.dart';
import 'package:surf_spots_app/constants/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.onLoginSuccess});
  final VoidCallback? onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Veuillez remplir tous les champs', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showMessage(result['message'], Colors.green);

      // 🔥 Rafraîchir l'historique après login
      await Provider.of<SpotsProvider>(
        context,
        listen: false,
      ).refreshAfterLogin();

      // Callback si fourni
      if (widget.onLoginSuccess != null) {
        widget.onLoginSuccess!.call();
        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } else {
      _showMessage(result['message'], Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
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
              const SizedBox(height: 40),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 600
                      ? 26.0
                      : 80.0,
                ),
                child: Column(
                  children: [
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
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign In',
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
              Column(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
