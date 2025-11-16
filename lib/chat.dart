import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Chat Page - real-time messages
class ChatPage extends StatefulWidget {
  final String boardId;
  final String boardName;
  const ChatPage({super.key, required this.boardId, required this.boardName});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textCtrl = TextEditingController();
  final _scroll = ScrollController();

  Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream() {
    return FirebaseFirestore.instance
        .collection('boards')
        .doc(widget.boardId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final docUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final name =
        ((docUser.data()?['firstName'] ?? '') +
                ' ' +
                (docUser.data()?['lastName'] ?? ''))
            .trim();
    final senderName = name.isNotEmpty ? name : (user.email ?? 'Unknown');

    final ref = FirebaseFirestore.instance
        .collection('boards')
        .doc(widget.boardId);
    final msgCol = ref.collection('messages');
    await msgCol.add({
      'text': text,
      'senderUid': user.uid,
      'senderName': senderName,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _textCtrl.clear();
    _scroll.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _buildMessageTile(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final text = data['text'] ?? '';
    final name = data['senderName'] ?? 'Unknown';
    final ts = (data['createdAt'] as Timestamp?)?.toDate().toLocal();
    final timeStr = ts != null ? DateFormat('MMM d, hh:mm a').format(ts) : '';

    return ListTile(
      title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(text),
      trailing: Text(
        timeStr,
        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.boardName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error loading messages'));
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty)
                  return Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                return ListView.builder(
                  reverse: true,
                  controller: _scroll,
                  itemCount: docs.length,
                  itemBuilder: (context, idx) => _buildMessageTile(docs[idx]),
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: InputDecoration(hintText: 'Type a message'),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
