import 'package:flutter/material.dart';
import 'widgets/custom_input_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                  color: Color(0xFF1A73E8),
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
              horizontal: MediaQuery.of(context).size.width < 600 ? 26.0 : 80.0,
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
                      backgroundColor: Color(0xFF1A73E8),
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
                  style: TextStyle(color: Color(0xFF1A73E8)),
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
                    style: TextStyle(color: Color(0xFF1A73E8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
