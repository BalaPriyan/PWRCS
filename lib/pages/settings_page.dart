import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smarttest/pages/home_page.dart';
import 'package:smarttest/pages/signin_page.dart';

class AboutPage extends StatefulWidget {
  final String userId;

  const AboutPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String baseUrl = 'http://127.0.0.7:8080';
  String fullname = '';
  String email = '';
  String credit = '';
  bool isLoading = true;
  String errorMessage = '';

  // Controllers for editable text fields
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final url = Uri.parse('$baseUrl/getUserData');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': widget.userId}),
      );

      if (response.statusCode == 200) {
        final user = jsonDecode(response.body)['user'];
        setState(() {
          fullname = user['fullname'];
          email = user['email'];
          credit = user['credits'].toString();
          isLoading = false;

          // Initialize controllers with user data
          fullnameController.text = fullname;
          emailController.text = email;
        });
      } else {
        setState(() {
          errorMessage = 'User not found: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching user data: $e';
        isLoading = false;
      });
    }
  }

  void logout() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SigninPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar section
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 20),
            // Editable Full Name
            TextField(
              controller: fullnameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Editable Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Display Credits
            Text('Credits: $credit', style: const TextStyle(fontSize: 20)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "You have saved ",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                        ),
                        child: Text('${credit}'),
                      ),
                      const SizedBox(height: 8),
                      const Text("grams of plastic from pollution."),

                    ],
                  ),
                ),
              ),
            ),
            // Logout Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: logout,
                child: const Text('Logout', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
