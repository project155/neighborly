import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighborly/Volunteerhome.dart';
import 'package:neighborly/volunteerregister.dart';
import 'package:neighborly/password.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VolunteerLoginPage extends StatefulWidget {
  const VolunteerLoginPage({super.key});

  @override
  _VolunteerLoginPageState createState() => _VolunteerLoginPageState();
}

class _VolunteerLoginPageState extends State<VolunteerLoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // Retrieve the volunteer document from the "volunteers" collection.
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('volunteers')
            .doc(uid)
            .get();

        if (docSnapshot.exists) {
          var data = docSnapshot.data() as Map<String, dynamic>;

          // Check if the account is approved.
          if (data['isApproved'] != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Your account is not approved yet.",
                  style: TextStyle(fontFamily: 'proxima'),
                ),
              ),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "No volunteer data found for this user.",
                style: TextStyle(fontFamily: 'proxima'),
              ),
            ),
          );
          return;
        }

        // Get the OneSignal Player ID.
        final deviceState = await OneSignal.shared.getDeviceState();
        String? pId = deviceState?.userId;

        // Update Firestore document with the OneSignal Player ID.
        await FirebaseFirestore.instance.collection('volunteers').doc(uid).update({
          'playerid': pId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Login Successful",
              style: TextStyle(fontFamily: 'proxima'),
            ),
          ),
        );

        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('role', 'volunteer');

        // Navigate to the VolunteerHome screen.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => VolunteerHome()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: ${e.toString()}",
            style: const TextStyle(fontFamily: 'proxima'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top container with background image, welcome text, and SVG icon.
            Stack(
              clipBehavior: Clip.none, // Allow children to overflow if needed
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/upperimage.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome to!',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'proxima',
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Reportify!',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'proxima',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Report, Stay Informed, and Make a Difference.!',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'proxima',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Positioned SVG icon with the referenced snippet.
                Positioned(
                  top: 20, // Adjust vertical positioning as needed.
                  right: 20, // Adjust horizontal positioning as needed.
                  child: SvgPicture.asset(
                    'assets/icons/icon2.svg',
                    // Remove color override if you want to see original colors.
                    // color: Colors.black,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            // Email TextField.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter Email',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 9, 60, 83),
                    fontFamily: 'proxima',
                  ),
                  prefixIcon:
                      const Icon(Icons.email, color: Color.fromARGB(255, 9, 60, 83)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
              ),
            ),
            // Password TextField.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 9, 60, 83),
                    fontFamily: 'proxima',
                  ),
                  prefixIcon:
                      const Icon(Icons.lock, color: Color.fromARGB(255, 9, 60, 83)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color.fromARGB(255, 9, 60, 83),
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
            // Forgot Password button.
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 35),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PasswordRecoveryPage()),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 141, 206),
                      fontSize: 16,
                      fontFamily: 'proxima',
                    ),
                  ),
                ),
              ),
            ),
            // Sign In button.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 9, 60, 83),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 90),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'proxima',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Register now button.
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey, fontFamily: 'proxima'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => VolunteerRegister()),
                      );
                    },
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                        color: Color.fromARGB(255, 52, 109, 246),
                        fontFamily: 'proxima',
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
