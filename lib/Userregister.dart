import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighborly/Userlogin.dart';
//import 'Userlogin.dart';  // Add the import for the login page

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
  final _locationController = TextEditingController();

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
                  _buildTextField(_locationController, 'Location', Icons.location_on),
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
            Text('Join us as a User!', style: TextStyle(fontSize: 20, color: Colors.white)),
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

  Widget _buildRoleDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: const [
          Icon(Icons.person, color: Colors.grey),
          SizedBox(width: 10),
          Text('Role: User', style: TextStyle(color: Colors.black)),
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
    String location = _locationController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty || location.isEmpty) {
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
        'location': location,
        'role': 'User',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration Successful!')),
      );

      // Navigate to the login page after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserLoginPage()), // Assuming your LoginPage is named LoginPage
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
