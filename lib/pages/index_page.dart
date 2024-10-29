import 'package:flutter/material.dart';
import ''
    '/pages/home_page.dart';
import 'notification_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectionIndex = 0;

  void _navigationButton(int index) {
    setState(() {
      _selectionIndex = index;
    });
  }

  final List<Widget> _pages = [
    const IndexPage(),
    const NotificationPage(),
    const ProfilePage(),
    const AboutPage(userId: '6714f151ce6ce27288a18b69'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PWRCS',
      style: TextStyle(fontWeight: FontWeight.w800,color: Colors.green),),
    centerTitle: true,
    backgroundColor: Colors.white60,
    automaticallyImplyLeading: false,
    elevation: 5,),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            HomeScreenContent(userId: '6714f151ce6ce27288a18b69'),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectionIndex,
          onTap: _navigationButton,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: 'Credit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notify',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        )
    );
  }
}

