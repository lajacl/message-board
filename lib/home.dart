import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_board/profile.dart';
import 'package:message_board/settings.dart';

// Home Page with list of boards and drawer
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _boards = <Map<String, dynamic>>[
    {'id': 'general', 'name': 'General Discussion', 'icon': Icons.chat},
    {'id': 'courses', 'name': 'Course Help', 'icon': Icons.school},
    {'id': 'jobs', 'name': 'Jobs & Internships', 'icon': Icons.work},
  ];

  String _displayName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(u.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _displayName = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
              .trim();
          _email = data['email'] ?? u.email ?? '';
        });
      } else {
        setState(() {
          _displayName = u.email ?? '';
          _email = u.email ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message Boards')),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_displayName.isEmpty ? 'User' : _displayName),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                child: Text(_displayName.isEmpty ? '?' : _displayName[0]),
              ),
            ),
            ListTile(
              title: Text('Message Boards'),
              leading: Icon(Icons.forum),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: Text('Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => ProfilePage()));
              },
            ),
            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => SettingsPage()));
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _boards.length,
        itemBuilder: (context, idx) {
          final b = _boards[idx];
          return ListTile(
            leading: CircleAvatar(child: Icon(b['icon'] as IconData)),
            title: Text(b['name']),
            trailing: Icon(Icons.arrow_forward_ios),
          );
        },
      ),
    );
  }
}
