import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_board/auth.dart';

// Settings page - logout and update user info
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _dobCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    _dobCtrl.text = (snap.data()?['dob'] ?? '');
  }

  Future<void> _saveDob() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'dob': _dobCtrl.text.trim(),
    });
    showSnack(context, 'Saved');
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => AuthGate()));
  }

  @override
  void dispose() {
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton.icon(
            label: Text('Log Out'),
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dobCtrl,
              decoration: InputDecoration(
                labelText: 'Date of birth (optional)',
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(onPressed: _saveDob, child: Text('Save')),
          ],
        ),
      ),
    );
  }
}
