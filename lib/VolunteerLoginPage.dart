import 'package:flutter/material.dart';

class VolunteerLoginPage extends StatefulWidget {
  const VolunteerLoginPage({super.key});

  @override
  _VolunteerLoginPageState createState() => _VolunteerLoginPageState();
}

class _VolunteerLoginPageState extends State<VolunteerLoginPage> {
  bool _isPasswordVisible = false; // Track password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Stack(
        children: [
          Positioned(
            top: 0, // Adjust this value to position the image correctly under the text
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.35, // 25% of the screen height
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 7, 135, 255),
               
                borderRadius: BorderRadius.circular(15), // Optional: rounded corners
              ),
            ),
          ),

          // Welcome Message (Positioned at the top)
          Positioned(
            top: 100,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome Back!!',
                  style: TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          ),

          // Image under "Welcome back" text (covering 25% of the screen height)
          
          // Username Field
          Positioned(
            top: 365,
            left: 30,
            right: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15), // Circular border
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter Username',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  border: InputBorder.none, // Remove default border
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
          ),

          // Password Field
          Positioned(
            top: 440,
            left: 30,
            right: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(15), // Circular border
              ),
              child: TextField(
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                   hintStyle: TextStyle(color: const Color.fromARGB(255, 168, 168, 168)),
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  border: InputBorder.none, // Remove default border
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),

          // Recovery Password Link
          Positioned(
            top: 500,
            right: 30,
            child: TextButton(
              onPressed: () {
                // Handle recovery password
              },
              child: const Text(
                'Recovery Password',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ),
          ),

          // Sign In Button
          Positioned(
            top: 600,
            left: 30,
            right: 30,
            child: ElevatedButton(
              onPressed: () {
                // Handle sign-in
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6495ED), // Cornflower Blue
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Register Now Section
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Not a member?',
                  style: TextStyle(color: Colors.grey),
                ),
                TextButton(
                  onPressed: () {
                    // Handle register now
                  },
                  child: const Text(
                    'Register now',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
