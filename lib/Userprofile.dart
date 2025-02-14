import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighborly/clodinary_upload.dart';

class Userprofile extends StatefulWidget {
  @override
  _UserprofileState createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? profileImageUrl;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userLocation;
  bool isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('volunteers').doc(user.uid).get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get('name') ?? 'No Name';
            userEmail = userDoc.get('email') ?? 'No Email';
            userPhone = userDoc.get('phone') ?? 'No Phone';
            userLocation = userDoc.get('location') ?? 'No Place';
            profileImageUrl = userDoc.get('profileImage') ?? '';
            isLoading = false;
          });
        } else {
          print("No user found in volunteers collection.");
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Upload image to Cloudinary
  Future<void> _uploadImage(File imageFile) async {
    final imageUrl = await getClodinaryUrl(imageFile.path);
    _updateProfileImage(imageUrl ?? '');
  }

  // Update profile image in Firestore
  Future<void> _updateProfileImage(String imageUrl) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('volunteers').doc(user.uid).update({'profileImage': imageUrl});
      setState(() {
        profileImageUrl = imageUrl;
      });
    }
  }

  // Pick an image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _uploadImage(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      appBar: AppBar(title: Text('User Profile')),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading while fetching data
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40),

                  // Profile Image (Large & Centered)
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 20,
                              child: Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // User Details
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            userName ?? "No Name",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "📍 $userLocation",
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          ),
                          Divider(thickness: 1, height: 30),

                          _buildDetailRow(Icons.email, "Email", userEmail),
                          SizedBox(height: 10),
                          _buildDetailRow(Icons.phone, "Phone", userPhone),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget for detail rows
  Widget _buildDetailRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent, size: 28),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            value ?? "Not Available",
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
