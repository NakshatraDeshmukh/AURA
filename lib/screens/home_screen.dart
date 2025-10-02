import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int safetyScore = 85; // Example, dynamic from backend later
  bool hasNetwork = true;
  LatLng lastLocation = LatLng(19.0760, 72.8777); // Mumbai example
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void sendPanicAlert() {
    // Call your backend or cloud function to trigger alert
    print("Panic Alert Triggered!");
    // TODO: integrate Twilio/Email API
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Alert Sent"),
        content: Text("Your emergency contacts have been notified."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  Widget _buildSafetyCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Safety Score",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "$safetyScore / 100",
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: safetyScore > 70 ? Colors.green : Colors.red),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasNetwork ? Icons.wifi : Icons.wifi_off,
                  color: hasNetwork ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(hasNetwork ? "Connected" : "No Network",
                    style: TextStyle(fontSize: 16))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPanicButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: sendPanicAlert,
        icon: Icon(Icons.warning, size: 30,
          color: Colors.white,),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
          child: Text(
            "Panic Button",
            style: TextStyle(fontSize: 22,
              color: Colors.white,),

          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF9E3581),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 250,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition:
          CameraPosition(target: lastLocation, zoom: 14.0),
          markers: {
            Marker(
              markerId: MarkerId("user_location"),
              position: lastLocation,
              infoWindow: InfoWindow(title: "You are here"),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildQuickContacts() {
    // Dummy contacts
    List<String> contacts = ["Mom", "Friend", "Police"];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Emergency Contacts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 16,
              children: contacts
                  .map((c) => Chip(
                label: Text(c),
                avatar: Icon(Icons.person),
              ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AURA",
          style: TextStyle(
          color: Colors.white, // Set the title text color to white
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),

        centerTitle: true,
        backgroundColor: Color(0xFF9E3581),
        iconTheme: const IconThemeData(
          color: Colors.white, // Back arrow and other icons color
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSafetyCard(),
            _buildMap(),
            _buildPanicButton(),
            _buildQuickContacts(),
          ],
        ),
      ),
    );
  }
}

