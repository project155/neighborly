import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:neighborly/UserSelectionPage.dart';
import 'package:neighborly/clodinary_upload.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neighborly/Notificationpage.dart';

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
  bool isLoading = true;
  late String collectionName;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data for users, volunteers, and authorities
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc;

        // Check "users" collection
        userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          collectionName = 'users';
        } else {
          // Check "volunteers" collection
          userDoc = await _firestore.collection('volunteers').doc(user.uid).get();
          if (userDoc.exists) {
            collectionName = 'volunteers';
          } else {
            // Check "authorities" collection
            userDoc = await _firestore.collection('authorities').doc(user.uid).get();
            if (userDoc.exists) {
              collectionName = 'authorities';
            } else {
              setState(() {
                isLoading = false;
              });
              return;
            }
          }
        }

        setState(() {
          userName = userDoc.get('name') ?? 'No Name';
          userEmail = userDoc.get('email') ?? 'No Email';
          userPhone = userDoc.get('phone') ?? 'No Phone';
          userLocation = userDoc.get('location') ?? 'No Location';
          profileImageUrl = userDoc.get('profileImage') ?? '';
          userRole = userDoc.get('role') ?? 'User';
          isLoading = false;
        });
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
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('role');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // matching userhome's background
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 115, 168),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: Text(
              'User Profile',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
              ),
            ],
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Profile Image
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
                  // User Details Card
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'proxima',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "📍 $userLocation",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[700],
                              fontFamily: 'proxima',
                            ),
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
                      label: const Text(
                        "Sign Out",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'proxima'),
                      ),
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
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontFamily: 'proxima',
            ),
          ),
        ),
      ],
    );
  }
}
