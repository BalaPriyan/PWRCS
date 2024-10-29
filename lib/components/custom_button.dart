import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.ButtonText});
final String? ButtonText;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(50))
      ),
      child: Text(ButtonText!
        , style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
      ),
    );
  }
}
