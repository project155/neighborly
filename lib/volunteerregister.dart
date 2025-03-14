import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart'; // Cloudinary package for image upload.
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neighborly/incidentlocation.dart'; // For picking location.
import 'package:neighborly/Userlogin.dart';

/// Uploads the image at [image] path to Cloudinary and returns the secure URL.
Future<String?> getClodinaryUrl(String image) async {
  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dkwnu8zei',
    apiKey: '298339343829723',
    apiSecret: 'T9q3BURXE2-Rj6Uv4Dk9bSzd7rY',
  );

  final response = await cloudinary.upload(
    file: image,
    resourceType: CloudinaryResourceType.image,
  );
  return response.secureUrl;
}

class VolunteerRegister extends StatefulWidget {
  const VolunteerRegister({super.key});

  @override
  _VolunteerRegisterState createState() => _VolunteerRegisterState();
}

class _VolunteerRegisterState extends State<VolunteerRegister> {
  // Define primaryColor and common font family as in Userregister.
  final Color primaryColor = const Color.fromARGB(255, 9, 60, 83);
  bool _isPasswordVisible = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Store the selected location.
  LatLng? _selectedLatLng;

  // Identity card image file.
  File? _identityCard;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            flex: 1, // Matching the flex used in Userregister.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Name', Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _phoneController,
                    'Phone Number',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _passwordController,
                    'Password',
                    Icons.lock,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: _buildPasswordVisibilityIcon(),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _confirmPasswordController,
                    'Confirm Password',
                    Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  _buildLocationSelector(),
                  const SizedBox(height: 10),
                  _buildIdentityCardPicker(),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      width: 250, // Fixed width as in Userregister.
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'proxima',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header copied from Userregister with asset image and updated text.
  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/upperimage.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding( 
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Reportify!',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                fontFamily: 'proxima',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Join us as a Volunteer!',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'proxima',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // General text field widget with design copied from Userregister.
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontFamily: 'proxima'),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: primaryColor,
            fontFamily: 'proxima',
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 214, 214, 214)),
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromARGB(255, 235, 235, 235)),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  // Location selector widget updated to match Userregister styling.
  Widget _buildLocationSelector() {
    return InkWell(
      onTap: () async {
        // Navigate to PickLocationPage and expect a LatLng result.
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PickLocationPage()),
        );
        if (result != null && result is LatLng) {
          setState(() {
            _selectedLatLng = result;
            print("Selected location: $_selectedLatLng");
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color.fromARGB(255, 235, 235, 235)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedLatLng != null
                    ? 'Selected: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
                    : "Select Location",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedLatLng != null ? Colors.black : primaryColor,
                  fontFamily: 'proxima',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  // Identity Card Picker widget updated with the new styling.
  Widget _buildIdentityCardPicker() {
    return InkWell(
      onTap: _pickIdentityCardImage,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 235, 235, 235)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.image, color: primaryColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: _identityCard == null
                  ? Text(
                      "Upload Identity Card",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                        fontFamily: 'proxima',
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _identityCard!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Identity Card Selected",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'proxima',
                          ),
                        ),
                      ],
                    ),
            ),
            Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 24),
          ],
        ),
      ),
    );
  }

  // Password visibility toggle icon.
  Widget _buildPasswordVisibilityIcon() {
    return IconButton(
      icon: Icon(
        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        color: primaryColor,
      ),
      onPressed: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
    );
  }

  // Function to pick identity card image.
  Future<void> _pickIdentityCardImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: primaryColor),
                title: const Text("Camera", style: TextStyle(fontFamily: 'proxima')),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _identityCard = File(pickedFile.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: primaryColor),
                title: const Text("Gallery", style: TextStyle(fontFamily: 'proxima')),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _identityCard = File(pickedFile.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Registration function with validations for email, password length, and phone number.
  Future<void> _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Check if all required fields are provided.
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedLatLng == null ||
        _identityCard == null) {
      _showError('All fields are required, including your identity card.');
      return;
    }

    // Validate email format.
    if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email)) {
      _showError('Please enter a valid email.');
      return;
    }

    // Validate password length.
    if (password.length < 8) {
      _showError('Password must be at least 8 characters.');
      return;
    }

    // Validate phone number length.
    if (phone.length != 10) {
      _showError('Phone number must be exactly 10 digits.');
      return;
    }

    // Check if passwords match.
    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }

    try {
      // Create a new user with Firebase Auth.
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = userCredential.user!.uid;

      // Upload identity card image to Cloudinary and get the secure URL.
      String? downloadUrl = await getClodinaryUrl(_identityCard!.path);
      if (downloadUrl == null) {
        _showError('Image upload failed.');
        return;
      }

      // Save volunteer data to Firestore along with the image URL.
      await _firestore.collection('volunteers').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'isApproved': false,
        'location': {
          'latitude': _selectedLatLng!.latitude,
          'longitude': _selectedLatLng!.longitude,
        },
        'idCardImage': downloadUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );
      Navigator.pop(context); // Navigate back after successful registration.
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Helper function to display error messages.
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'proxima')),
      ),
    );
  }
}
