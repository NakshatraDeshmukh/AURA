// lib/screens/home_screen.dart
import 'dart:async';
import 'package:aura/widgets/sos_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'contacts_screen.dart';
import 'safezone_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _position;
  String _networkStatus = 'Unknown';
  Timer? _heartbeatTimer;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double _riskScore = 0.0;

  @override
  void initState() {
    super.initState();
    _initLocation();
    _initConnectivity();
    _startHeartbeat();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() => _position = pos);
    _updateHeartbeat(); // initial ping
  }

  void _initConnectivity() {
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() {
        _networkStatus = (status == ConnectivityResult.none) ? 'Offline' : 'Online';
      });
    });
    // initial check
    Connectivity().checkConnectivity().then((status) {
      setState(() {
        _networkStatus = (status == ConnectivityResult.none) ? 'Offline' : 'Online';
      });
    });
  }

  void _startHeartbeat() {
    // send heartbeat every 60 seconds to Firestore
    _heartbeatTimer = Timer.periodic(Duration(seconds: 60), (_) => _updateHeartbeat());
  }

  Future<void> _updateHeartbeat() async {
    final user = _auth.currentUser;
    if (user == null) return;
    Position? pos;
    try {
      pos = await Geolocator.getLastKnownPosition() ?? _position;
    } catch (_) {
      pos = _position;
    }

    // compute local risk score (placeholder - replace with probability_service logic)
    double score = _computeRiskScore(pos, _networkStatus);
    setState(() => _riskScore = score);

    await _firestore.collection('users').doc(user.uid).set({
      'lastSeen': FieldValue.serverTimestamp(),
      'location': pos != null ? GeoPoint(pos.latitude, pos.longitude) : null,
      'network': _networkStatus,
      'riskScore': _riskScore,
    }, SetOptions(merge: true));
  }

  double _computeRiskScore(Position? pos, String network) {
    // simple heuristic: night + offline increases score; replace with your formula
    double score = 0.0;
    if (network == 'Offline') score += 0.5;
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour <= 5) score += 0.3;
    if (pos == null) score += 0.1;
    return (score).clamp(0.0, 1.0);
  }

  Future<void> _triggerEmergency({required bool urgent}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition();
    } catch (_) {}

    final doc = {
      'uid': user.uid,
      'name': user.displayName ?? user.email,
      'timestamp': FieldValue.serverTimestamp(),
      'urgent': urgent,
      'location': pos != null ? GeoPoint(pos.latitude, pos.longitude) : null,
      'network': _networkStatus,
      'riskScore': _riskScore,
      'handled': false,
    };

    // write to emergency_requests collection; cloud function will handle alerts
    await _firestore.collection('emergency_requests').add(doc);

    // show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(urgent ? 'Emergency sent!' : 'Alert sent (non-urgent)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = _position?.latitude?.toStringAsFixed(5) ?? '—';
    final lng = _position?.longitude?.toStringAsFixed(5) ?? '—';
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('AURA — Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen())),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(Icons.my_location),
                title: Text('Location: $lat, $lng'),
                subtitle: Text('Network: $_networkStatus    Risk: ${(_riskScore * 100).toInt()}%'),
                trailing: ElevatedButton(
                  onPressed: _updateHeartbeat,
                  child: Text('Ping'),
                ),
              ),
            ),
            SizedBox(height: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SOSButton(
                    onTapSOS: () => _triggerEmergency(urgent: false),
                    onLongPressSOS: () => _triggerEmergency(urgent: true),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Press SOS for quick alert\nLong press for emergency',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.contacts),
                  label: Text('Contacts'),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ContactsScreen())),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.map),
                  label: Text('Safe Zones'),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SafezoneScreen())),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (user != null) Text('Signed in as: ${user.email}', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
