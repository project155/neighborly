import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:neighborly/clodinary_upload.dart';
import 'package:neighborly/Userlogin.dart'; // Import the login page

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
  
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? profileImageUrl;
  String? userName;
  String? userEmail;
  String? userPhone;
  String? userLocation;
  String? userRole;
  bool isLoading = true; // Loading indicator
  late String collectionName;

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
        // Check "users" collection first
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        // If not found, check "volunteers" collection
        if (!userDoc.exists) {
          userDoc = await _firestore.collection('volunteers').doc(user.uid).get();
          collectionName = 'volunteers';
        } else {
          collectionName = 'users';
        }

        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get('name') ?? 'No Name';
            userEmail = userDoc.get('email') ?? 'No Email';
            userPhone = userDoc.get('phone') ?? 'No Phone';
            userLocation = userDoc.get('location') ?? 'No Location';
            profileImageUrl = userDoc.get('profileImage') ?? '';
            userRole = userDoc.get('role') ?? 'User';
            isLoading = false;
          });
        } else {
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
      await _firestore.collection(collectionName).doc(user.uid).update({'profileImage': imageUrl});
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

  // Sign out and return to login page
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserLoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      appBar: AppBar(title: const Text('User Profile')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading while fetching data
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Profile Image (Large & Centered)
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage('assets/default_profile.png') as ImageProvider,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: InkWell(
                            onTap: _pickImage,
                            child: const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              radius: 20,
                              child: Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // User Details
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            userName ?? "No Name",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "📍 $userLocation",
                            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                          ),
                          const Divider(thickness: 1, height: 30),
                          _buildDetailRow(Icons.email, "Email", userEmail),
                          const SizedBox(height: 10),
                          _buildDetailRow(Icons.phone, "Phone", userPhone),
                          const SizedBox(height: 10),
                          _buildDetailRow(Icons.person, "Role", userRole),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign Out Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text("Sign Out", style: TextStyle(fontSize: 18, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            value ?? "Not Available",
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
