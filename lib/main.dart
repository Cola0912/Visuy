import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/add_screen.dart';
import 'screens/contacts_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    ProfileScreen(),
    SearchScreen(),
    AddScreen(),
    ContactsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo with BottomNavigationBar'),
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.orange),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.grey),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add, color: Colors.grey),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts, color: Colors.grey),
            label: 'Contacts',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
