import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:neighborly/UserSelectionPage.dart';
import 'package:neighborly/clodinary_upload.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? userAddress;
  String? userRole;
  bool isLoading = true;
  late String collectionName;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from one of the collections (users, volunteers, authorities)
  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc;
        // Try "users" collection first
        userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          collectionName = 'users';
        } else {
          // Try "volunteers"
          userDoc = await _firestore.collection('volunteers').doc(user.uid).get();
          if (userDoc.exists) {
            collectionName = 'volunteers';
          } else {
            // Try "authorities"
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
        // Debug print to check the fetched document data
        print("Fetched document from $collectionName: ${userDoc.data()}");

        // Safely cast document data to a Map
        final data = userDoc.data() as Map<String, dynamic>;

        // Determine default role based on collection
        String defaultRole;
        if (collectionName == 'volunteers') {
          defaultRole = 'Volunteer';
        } else if (collectionName == 'authorities') {
          defaultRole = 'Authority';
        } else {
          defaultRole = 'User';
        }

        // Check if the fetched role is null or empty; if so, use the default.
        String? fetchedRole = data['role'];
        if (fetchedRole == null || (fetchedRole is String && fetchedRole.trim().isEmpty)) {
          fetchedRole = defaultRole;
        }
        
        print("Collection: $collectionName, Fetched role: '${data['role']}', Resolved role: '$fetchedRole'");
        
        setState(() {
          userName = data['name'] != null ? data['name'].toString() : 'No Name';
          userEmail = data['email'] != null ? data['email'].toString() : 'No Email';
          userPhone = data['phone'] != null ? data['phone'].toString() : 'No Phone';
          // Use the 'address' field instead of 'location'
          userAddress = data['address'] != null ? data['address'].toString() : 'No Address';
          profileImageUrl = data['profileImage'] != null ? data['profileImage'].toString() : '';
          userRole = fetchedRole;
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

  // Upload image to Cloudinary then update Firestore with new profile image URL
  Future<void> _uploadImage(File imageFile) async {
    final imageUrl = await getClodinaryUrl(imageFile.path);
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _updateProfileImage(imageUrl);
    }
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

  // Pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _uploadImage(imageFile);
    }
  }

  // Show a dialog with text fields to edit profile details
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);
    final phoneController = TextEditingController(text: userPhone);
    final addressController = TextEditingController(text: userAddress);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile", style: TextStyle(fontFamily: 'proxima')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  style: const TextStyle(fontFamily: 'proxima'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  // Making the email field uneditable
                  enabled: false,
                  style: const TextStyle(fontFamily: 'proxima'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                  style: const TextStyle(fontFamily: 'proxima'),
                ),
                // Changed from Location to Address
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                  style: const TextStyle(fontFamily: 'proxima'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(fontFamily: 'proxima')),
            ),
            ElevatedButton(
              onPressed: () async {
                await _updateProfileDetails(
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                  addressController.text,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 9, 60, 83),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontFamily: 'proxima'),
              ),
              child: const Text("Save"),
            ),
          ],
        );
      }
    );
  }

  // Update profile details in Firestore and local state
  Future<void> _updateProfileDetails(String name, String email, String phone, String address) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection(collectionName).doc(user.uid).update({
        'name': name,
        // Email remains unchanged
        'phone': phone,
        // Update the 'address' field instead of 'location'
        'address': address,
      });
      setState(() {
        userName = name;
        userPhone = phone;
        userAddress = address;
      });
    }
  }

  // Sign out and navigate to the user selection page
  Future<void> _signOut() async {
    await _auth.signOut();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('role');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserSelectionPage()),
    );
  }

  // Build a detail row with an icon and corresponding detail
  Widget _buildDetailRow(IconData icon, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 9, 60, 83), size: 28),
          const SizedBox(width: 15),
          Text(
            detail,
            style: const TextStyle(fontSize: 18, fontFamily: 'proxima'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
            title: const Text(
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
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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
                  // Profile Image without camera icon
                  Center(
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Row with Edit Profile and Change Profile Picture Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _showEditProfileDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 9, 60, 83),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontFamily: 'proxima'),
                        ),
                        child: const Text("Edit Profile"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 9, 60, 83),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontFamily: 'proxima'),
                        ),
                        child: const Text("Change Profile Picture"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Display profile details with icons
                  _buildDetailRow(Icons.person, "Name: ${userName ?? 'No Name'}"),
                  _buildDetailRow(Icons.email, "Email: ${userEmail ?? 'No Email'}"),
                  _buildDetailRow(Icons.phone, "Phone: ${userPhone ?? 'No Phone'}"),
                  // Updated label from Location to Address
                  _buildDetailRow(Icons.location_on, "Address: ${userAddress ?? 'No Address'}"),
                  _buildDetailRow(Icons.badge, "Role: ${userRole ?? 'User'}"),
                  const SizedBox(height: 30),
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
                        backgroundColor: const Color.fromARGB(255, 9, 60, 83),
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
}
