import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_board/chat.dart';
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create new board',
        onPressed: () {
          _showCreateBoardDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCreateBoardDialog(BuildContext ctx) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dctx) {
        return AlertDialog(
          title: Text('Create board'),
          content: TextField(
            controller: nameCtrl,
            decoration: InputDecoration(labelText: 'Board name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                setState(() {
                  _boards.add({
                    'id': name.toLowerCase().replaceAll(' ', '_'),
                    'name': name,
                    'icon': Icons.forum,
                  });
                });
                Navigator.of(dctx).pop();
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
