import 'package:flutter/material.dart';
import 'main.dart';
import 'search.dart';
import 'contacts.dart';

class AddScreen extends StatelessWidget {
  const AddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.pink],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Image.asset(
                  'assets/qr_code.png', // QRコードの画像パス
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.grey),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.orange),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.badge, color: Colors.grey),
            label: 'ID',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactsScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
