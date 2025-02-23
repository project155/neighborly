import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neighborly/Userlogin.dart';
import 'incidentlocation.dart'; // Make sure PickLocationPage returns a LatLng

class Userregister extends StatefulWidget {
  const Userregister({super.key});

  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<Userregister> {
  bool _isPasswordVisible = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Using a LatLng variable to store the selected location
  LatLng? _selectedLatLng;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            flex: 1,
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
                  const SizedBox(height: 90),
                  Center(
                    child: Container(
                      width: 250, // Fixed width; adjust as needed.
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6495ED),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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

  // Header widget with background image and text shifted upward
  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://res.cloudinary.com/dkwnu8zei/image/upload/v1740293549/upperimage_k8cepq.png',
          ),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Padding(
        padding:  EdgeInsets.all(20),
        child: Transform.translate(
          offset:  Offset(0, -50), // Move text upward by 20 pixels
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children:  [
              Text(
                'Welcome!',
                style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 25),
              Text('Join us as a User!', style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // General text field widget with outlined borders
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
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
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

  // Location selector widget with outlined border and transparent background.
  Widget _buildLocationSelector() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PickLocationPage()),
        );
        if (result != null && result is LatLng) {
          setState(() {
            _selectedLatLng = result;
            // For debugging: print the selected location.
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
            const Icon(Icons.location_on, color: Colors.grey, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedLatLng != null
                    ? 'Selected: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
                    : "Select Location",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _selectedLatLng != null ? Colors.black : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  // Password visibility toggle icon
  Widget _buildPasswordVisibilityIcon() {
    return IconButton(
      icon: Icon(
        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
        color: Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
    );
  }

  // Registration function that saves user data along with the selected location
  Future<void> _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedLatLng == null) {
      _showError('All fields are required.');
      return;
    }
    if (password != confirmPassword) {
      _showError('Passwords do not match.');
      return;
    }
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'location': {
          'latitude': _selectedLatLng!.latitude,
          'longitude': _selectedLatLng!.longitude,
        },
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserLoginPage()),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  // Helper function to display error messages
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
