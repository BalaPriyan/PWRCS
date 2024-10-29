import 'package:flutter/material.dart';
import '/components/customscaffold.dart';
import '/pages/signin_page.dart';
import '/pages/register_page.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Centered Text
          Padding(
            padding: const EdgeInsets.only(bottom: 275.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Waste Is\nA Treasure,\nSo Collect It',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),
          Center(
            child: SizedBox(
              height: 60,
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SigninPage()));
                },
                child: const Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterPage()));
            },
            child: const Text(
              'Create an account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
