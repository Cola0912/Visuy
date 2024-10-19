import 'package:flutter/material.dart';
import 'main.dart';
import 'search.dart';
import 'add.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('名刺一覧'),
        ),
        body: ListView(
          children: const [
            Section(
              title: 'デザイナー',
              cards: [
                BusinessCard(
                  date: '2023/9/6',
                ),
                BusinessCard(
                  date: '2023/5/23',
                ),
                BusinessCard(
                  title: 'Title03',
                  date: '2023/3/30',
                ),
                BusinessCard(
                  title: 'Name',
                  role: 'role',
                ),
              ],
            ),
            Section(
              title: 'エンジニア',
              cards: [
                BusinessCard(
                  title: 'Name',
                  role: 'role',
                ),
                BusinessCard(
                  title: 'Name',
                  role: 'role',
                ),
              ],
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
              icon: Icon(Icons.search, color: Colors.grey),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add, color: Colors.grey),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge, color: Colors.orange),
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
                  MaterialPageRoute(
                      builder: (context) => const ContactsScreen()),
                );
                break;
            }
          },
        ));
  }
}

class Section extends StatelessWidget {
  final String title;
  final List<BusinessCard> cards;

  const Section({super.key, required this.title, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          children: cards,
        ),
      ],
    );
  }
}

class BusinessCard extends StatelessWidget {
  final String? title;
  final String? date;
  final String? role;

  const BusinessCard({super.key, this.title, this.date, this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 150,
      height: 100,
      color: Colors.redAccent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(color: Colors.white),
            ),
          if (date != null)
            Text(
              date!,
              style: const TextStyle(color: Colors.white),
            ),
          if (role != null)
            Text(
              role!,
              style: const TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}
