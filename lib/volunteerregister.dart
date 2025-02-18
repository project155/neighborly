import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighborly/incidentlocation.dart';
import 'incidentlocation.dart'; // Import the SelectLocation screen

class VolunteerRegister extends StatefulWidget {
  const VolunteerRegister({super.key});

  @override
  _VolunteerRegisterState createState() => _VolunteerRegisterState();
}

class _VolunteerRegisterState extends State<VolunteerRegister> {
  bool _isPasswordVisible = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedLocation = "Select Location"; // Default location text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            flex: 2,
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
                  _buildLocationSelector(),  // Location field
                  const SizedBox(height: 20),
                  _buildRoleDisplay(),
                  const SizedBox(height: 30),
                  ElevatedButton(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 7, 135, 255),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Welcome!',
              style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 25),
            Text('Join us as a Volunteer!', style: TextStyle(fontSize: 20, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PickLocationPage()),
        );
        if (result != null && result is String) {
          setState(() {
            _selectedLocation = result; // Update the selected location
          });
        }
      },
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedLocation, // Display the selected location
                style: TextStyle(color: _selectedLocation == "Select Location" ? Colors.grey : Colors.black),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: const [
          Icon(Icons.volunteer_activism, color: Colors.grey),
          SizedBox(width: 10),
          Text('Role: Volunteer', style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildPasswordVisibilityIcon() {
    return IconButton(
      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
      onPressed: () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      },
    );
  }

  Future<void> _register() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty || _selectedLocation == "Select Location") {
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
      await _firestore.collection('volunteers').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'location': _selectedLocation,
        'role': 'Volunteer',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );

      Navigator.pop(context); // Go back to the previous page after success
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
