
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();

  String get uid => _auth.currentUser!.uid;

  Future<void> _addContact() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) return;
    final docRef = _firestore.collection('users').doc(uid).collection('contacts').doc();
    await docRef.set({
      'id': docRef.id,
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'relation': _relationCtrl.text.trim(),
      'isPrimary': false,
      'smsEnabled': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _nameCtrl.clear(); _phoneCtrl.clear(); _relationCtrl.clear();
    Navigator.of(context).pop();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _phoneCtrl, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: _relationCtrl, decoration: InputDecoration(labelText: 'Relation')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(onPressed: _addContact, child: Text('Add')),
        ],
      ),
    );
  }

  Future<void> _setPrimary(String docId) async {
    final contactsRef = _firestore.collection('users').doc(uid).collection('contacts');
    final batch = _firestore.batch();
    final snapshot = await contactsRef.get();
    for (final d in snapshot.docs) {
      batch.update(d.reference, {'isPrimary': d.id == docId});
    }
    await batch.commit();
  }

  Future<void> _deleteContact(String docId) async {
    await _firestore.collection('users').doc(uid).collection('contacts').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final contactsRef = _firestore.collection('users').doc(uid).collection('contacts').orderBy('createdAt', descending: true);
    return Scaffold(
      appBar: AppBar(title: Text('Trusted Contacts')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: contactsRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return Center(child: Text('No contacts yet'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['phone'] ?? ''),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (data['isPrimary'] == true) Icon(Icons.star, color: Colors.orange),
                  IconButton(icon: Icon(Icons.check), onPressed: () => _setPrimary(d.id)),
                  IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteContact(d.id)),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
