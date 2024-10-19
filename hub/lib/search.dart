import 'package:flutter/material.dart';
import 'main.dart';
import 'add.dart';
import 'contacts.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // clear search field
                  },
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: const [
          ListTile(
            title: Text('町田凌久'),
            subtitle: Text('Designer'),
          ),
          ListTile(
            title: Text('永島美那'),
            subtitle: Text('Designer'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.orange),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.grey),
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
