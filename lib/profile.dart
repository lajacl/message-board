import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_board/auth.dart';

// Profile Page - allow user to edit personal info
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  String _role = 'member';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pop();
      return;
    }
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snap.data() ?? {};
    _first.text = data['firstName'] ?? '';
    _last.text = data['lastName'] ?? '';
    _role = data['role'] ?? 'member';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': _first.text.trim(),
      'lastName': _last.text.trim(),
      'role': _role,
    });
    showSnack(context, 'Profile updated');
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _first,
              decoration: InputDecoration(labelText: 'First name'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _last,
              decoration: InputDecoration(labelText: 'Last name'),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField(
              initialValue: _role,
              items: [
                'member',
                'moderator',
                'admin',
              ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _role = v as String),
              decoration: InputDecoration(labelText: 'Role'),
            ),
            SizedBox(height: 12),
            ElevatedButton(onPressed: _save, child: Text('Update')),
          ],
        ),
      ),
    );
  }
}
