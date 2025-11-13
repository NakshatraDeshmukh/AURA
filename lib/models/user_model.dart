import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? gender;
  final String? dob;
  final double? riskScore;
  final GeoPoint? lastKnownLocation;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.gender,
    this.dob,
    this.riskScore,
    this.lastKnownLocation,
  });
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob,
      'riskScore': riskScore ?? 0.0,
      'lastKnownLocation': lastKnownLocation,
    };
  }
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'],
      dob: map['dob'],
      riskScore: (map['riskScore'] ?? 0.0).toDouble(),
      lastKnownLocation: map['lastKnownLocation'],
    );
  }
}
