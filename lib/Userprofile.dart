import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String? userPlace;

  bool isLoading = true; // Show loading indicator while fetching data

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore ("volunteers" collection)
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
            userPlace = userDoc.get('place') ?? 'No Place';
            profileImageUrl = userDoc.get('profileImage') ?? '';
            isLoading = false; // Data fetched, hide loading indicator
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
          isLoading = false; // Hide loading indicator even if there's an error
        });
      }
    }
  }

  // Upload image to Cloudinary (or another server)
  Future<void> _uploadImage(File imageFile) async {
    final cloudinaryUrl =
        'https://api.cloudinary.com/v1_1/YOUR_CLOUD_NAME/image/upload';
    final uploadPreset = 'YOUR_UPLOAD_PRESET';

    var request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);
      String imageUrl = jsonData['secure_url'];

      _updateProfileImage(imageUrl);
    }
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
      appBar: AppBar(title: Text('User Profile')),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading while fetching data
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage('assets/default_profile.png') as ImageProvider,
                  ),
                  SizedBox(height: 20),
                  Text(userName ?? "No Name", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("📍 $userPlace", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  SizedBox(height: 10),
                  Text("📧 $userEmail", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  SizedBox(height: 10),
                  Text("📞 $userPhone", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text('Change Profile Picture'),
                  ),
                ],
              ),
            ),
    );
  }
}
