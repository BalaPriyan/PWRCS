import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/pages/signin_page.dart';
import '/pages/home_page.dart';

class AuthService {
  static const String baseUrl = 'http://127.0.0.7:8080';

  Future<void> register(BuildContext context, String fullname, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fullname': fullname, 'email': email, 'password': password}),
    );

    Navigator.of(context).pop();

    if (response.statusCode == 201) {
      print('Registration successful');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SigninPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${response.body}')),
      );
    }
  }

  Future<void> login(BuildContext context, String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      print('Logged in successfully');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenContent(userId: '6714f151ce6ce27288a18b69')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Error: ${response.body}')),
      );
    }
  }

  // Add this method for the `about` functionality
  Future<void> about(BuildContext context) async {
    final url = Uri.parse('$baseUrl/about');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': 'balapriyan@gmail.com'}),
    );

    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body)['user'];
      print('User Information: Fullname: ${user['fullname']}, Email: ${user['email']}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User: ${user['fullname']}, Email: ${user['email']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found: ${response.body}')),
      );
    }
  }

}
