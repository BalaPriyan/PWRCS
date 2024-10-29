import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smarttest/pages/splashPages/pass_page.dart';
import '/pages/notification_page.dart';
import '/pages/scanner_page.dart';
import 'dart:convert';
import '/pages/settings_page.dart';
import '/pages/splashPages/withdraw_page.dart';
import '/pages/splashPages/referpage.dart';
import '/pages/splashPages/policy.dart';

class HomeScreenContent extends StatefulWidget {
  final String userId;
  const HomeScreenContent({Key? key, required this.userId}) : super(key: key);



  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  String credit = '';
  String errorMessage = '';
  String baseUrl = 'http://127.0.0.7:8080';

  void initState() {
    super.initState();
    fetchUserCredit();
  }
  String connectionId = '';
  String statusMessage = 'Enter Connection ID';
  bool isConnected = false;
  bool isLoading = false; // New loading state


  Future<void> fetchUserCredit() async {
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
          credit = user['credits'].toString(); // Only fetching credits
          isLoading = false;
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


  Future<void> connectToServer(String enteredPin) async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/connect'), // Replace with actual server URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pin': enteredPin}),
      );

      if (response.statusCode == 200) {
        setState(() {
          statusMessage = jsonDecode(response.body)['message'];
          isConnected = true;
        });
      } else {
        setState(() {
          statusMessage = jsonDecode(response.body)['message'];
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Failed to connect to server';
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  Future<void> finishConnection() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/finish'), // Replace with actual server URL
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          statusMessage = jsonDecode(response.body)['message'];
          isConnected = false;
          connectionId = ''; // Reset after finish
        });
      } else {
        setState(() {
          statusMessage = jsonDecode(response.body)['message'];
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = 'Failed to finish connection';
      });
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PWRCS',style: TextStyle(color: Colors.green)),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage(userId: '6714f151ce6ce27288a18b69')),
                );
              },
              child: const Icon(Icons.person),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
              child: const Icon(Icons.notifications, color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRScannerLoadingScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("Scan"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) {
                  connectionId = value;
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Connection ID",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: isLoading ? null : () => connectToServer(connectionId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text("Connect"),
              ),
            ),
            Padding(
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
                      "Unlock The Way",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("To Make City Clean Now"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                      ),
                      child: const Text("Connect now"),
                    ),
                  ],
                ),
              ),
            ),
            // Icons Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Referpage()));
                      },
                      child: buildIconItem(Icons.bolt, "Refer", ""),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Policy()));
                      },
                      child: buildIconItem(Icons.security, "Policy", ""),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PassPage()));
                      },
                      child: buildIconItem(Icons.key, "Pass", ""),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawPage()));
                      },
                      child: buildIconItem(Icons.discount, "WD", ""),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.recycling,size: 150,)
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column buildIconItem(IconData icon, String label, String subtitle) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Colors.orange),
        Text(label, style: const TextStyle(fontSize: 16)),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.green),
          ),
      ],
    );
  }
}
