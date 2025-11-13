import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool isLoading = true;

  Map<String, String> personalInfo = {
    'First Name': '',
    'Last Name': '',
    'Email Address': '',
    'Phone Number': '',
    'Date of Birth': '',
    'Gender': '',
  };

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    setState(() {
      personalInfo['First Name'] = snap['firstName'] ?? '';
      personalInfo['Last Name'] = snap['lastName'] ?? '';
      personalInfo['Email Address'] = user.email ?? '';
      personalInfo['Phone Number'] = snap['phone'] ?? '';
      personalInfo['Date of Birth'] = snap['dob'] ?? '';
      personalInfo['Gender'] = snap['gender'] ?? '';
      isLoading = false;
    });
  }

  Future<void> saveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "firstName": personalInfo['First Name'],
      "lastName": personalInfo['Last Name'],
      "phone": personalInfo['Phone Number'],
      "dob": personalInfo['Date of Birth'],
      "gender": personalInfo['Gender'],
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Profile Updated")));

    setState(() => isEditing = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () {
              if (isEditing) {
                saveUserData(); 
              } else {
                setState(() => isEditing = true);
              }
            },
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: const TextStyle(color: Color(0xFF9E3581)),
            ),
          ),
        ],
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage:
              NetworkImage('https://randomuser.me/api/portraits/women/43.jpg'),
            ),
            const SizedBox(height: 20),

            buildSection('Personal Information', personalInfo),
            const SizedBox(height: 20),

            buildSecuritySection(),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        Card(
          color: const Color(0xFFF5F5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: data.keys
                  .map((key) => buildInfoField(key, data[key]!))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInfoField(String label, String value) {
    bool isEditable = ['First Name', 'Last Name', 'Phone Number', 'Date of Birth']
        .contains(label);

    bool isDOB = label == 'Date of Birth';
    bool isPhoneNumber = label == 'Phone Number';
    bool isEmail = label == 'Email Address';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: isDOB
          ? buildDOBField(label, value)
          : isPhoneNumber
          ? buildPhoneField(label, value)
          : buildTextField(label, value, isEditable && isEditing, isEmail),
    );
  }

  Widget buildDOBField(String label, String value) {
    return InkWell(
      onTap: isEditing
          ? () async {
        var picked = await DatePicker.showSimpleDatePicker(
          context,
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          dateFormat: "dd-MMMM-yyyy",
          locale: DateTimePickerLocale.en_us,
          looping: true,
        );

        if (picked != null) {
          setState(() {
            personalInfo[label] =
            "${picked.day}-${picked.month}-${picked.year}";
          });
        }
      }
          : null,

      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: isEditing ? Colors.white : Color(0xFFE0E0E0),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          value.isEmpty ? label : value,
          style: TextStyle(
              color: isEditing ? Colors.black : Colors.black54),
        ),
      ),
    );
  }

  Widget buildPhoneField(String label, String value) {
    return IntlPhoneField(
      initialValue: value,
      initialCountryCode: 'IN',
      enabled: isEditing,
      decoration: InputDecoration(
        filled: true,
        fillColor: isEditing ? Colors.white : Color(0xFFE0E0E0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        labelText: label,
      ),
      onChanged: (phone) {
        personalInfo[label] = phone.completeNumber;
      },
    );
  }

  Widget buildTextField(String label, String value, bool isEnabled, bool isEmail) {
    return TextFormField(
      initialValue: value,
      enabled: isEnabled && !isEmail,
      decoration: InputDecoration(
        filled: true,
        fillColor: isEnabled ? Colors.white : Color(0xFFE0E0E0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        labelText: label,
      ),
      onChanged: (newValue) => personalInfo[label] = newValue,
    );
  }

  Widget buildSecuritySection() {
    return Card(
      color: Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.lock, color: Colors.black54),
        title: Text("Change Password"),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          FirebaseAuth.instance.sendPasswordResetEmail(
            email: personalInfo['Email Address']!,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password reset email sent!")),
          );
        },
      ),
    );
  }
}
