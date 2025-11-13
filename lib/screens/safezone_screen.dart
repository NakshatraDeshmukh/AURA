
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SafezoneScreen extends StatefulWidget {
  const SafezoneScreen({super.key});
  @override
  State<SafezoneScreen> createState() => _SafezoneScreenState();
}

class _SafezoneScreenState extends State<SafezoneScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _nameCtrl = TextEditingController();

  Future<void> _addSafezone() async {
    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final col = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('safezones');
    final doc = col.doc();
    await doc.set({
      'id': doc.id,
      'name': _nameCtrl.text.trim().isEmpty ? 'Safe Place' : _nameCtrl.text.trim(),
      'location': GeoPoint(pos.latitude, pos.longitude),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _nameCtrl.clear();
    Navigator.pop(context);
  }

  void _showAddDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('Add Safe Zone (uses current GPS)'),
      content: TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Name (optional)')),
      actions: [
        TextButton(onPressed: ()=>Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(onPressed: _addSafezone, child: Text('Add')),
      ],
    ));
  }

  Future<void> _deleteZone(String id) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).collection('safezones').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final col = _firestore.collection('users').doc(_auth.currentUser!.uid).collection('safezones').orderBy('createdAt', descending: true);
    return Scaffold(
      appBar: AppBar(title: Text('Safe Zones')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add_location_alt),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: col.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return Center(child: Text('No safe zones added yet.'));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final map = d.data() as Map<String, dynamic>;
              final geo = map['location'] as GeoPoint?;
              return ListTile(
                leading: Icon(Icons.location_on),
                title: Text(map['name'] ?? 'Safe Place'),
                subtitle: Text(geo != null ? '${geo.latitude.toStringAsFixed(5)}, ${geo.longitude.toStringAsFixed(5)}' : ''),
                trailing: IconButton(icon: Icon(Icons.delete), onPressed: ()=>_deleteZone(d.id)),
              );
            },
          );
        },
      ),
    );
  }
}
