import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/return_button.dart';
import 'package:surf_spots_app/constants/colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    CustomInputField(label: 'Password', obscureText: true),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle registration logic here
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        "Don't have an account? Sign Up",
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
