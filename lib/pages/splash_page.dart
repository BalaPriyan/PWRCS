import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          Column(
            children: [
              Image.asset(
                  'assets/images/Splash1.png',
                  fit: BoxFit.cover,
                  width: 80,
                  height: 250
              ),

            ],
          ),
          Container(
            color: Colors.green,
          ),
          Container(
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}
