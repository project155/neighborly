import 'package:flutter/material.dart';
import 'package:neighborly/volunteerregister.dart';

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
      body: SingleChildScrollView( // Make the screen scrollable
        child: Column(
          
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
               width: MediaQuery.of(context).size.width * 1.00, // 45% of the screen height
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 7, 135, 255),
                borderRadius: BorderRadius.circular(15), 
                // Optional: rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome Back!!',
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
            ),
            SizedBox(height: 50,),
            // Username Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25), // Circular border
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25), // Circular border
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
            Align(
              alignment: Alignment.centerRight,
              child: Padding(padding: const EdgeInsets.only( right: 35, ),
             
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
            ),

            // Sign In Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  // Handle sign-in
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6495ED), // Cornflower Blue
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
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
            SizedBox(height: 200,),
            // Register Now Section
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to the RegisterPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => volunteerregister()),
                      );
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
      ),
    );
  }
}
