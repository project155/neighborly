import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighborly/notification_sos.dart';

/// SosPage allows users to send an emergency SOS alert along with their current location.
/// Simply press and hold the bright red button for 3 seconds to notify local authorities and emergency contacts.
class SosPage extends StatefulWidget {
  const SosPage({Key? key}) : super(key: key);

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with TickerProviderStateMixin {
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  String _statusMessage = 'Emergency help needed?';

  late AnimationController _animationController;
  late AnimationController _glowController; // For pulsating glow effect

  @override
  void initState() {
    super.initState();
    _determinePosition();

    // Animation controller for the 3-second long press animation.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // When the long press animation completes, send the SOS.
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _sendSOS();
      }
    });

    // Animation controller for the pulsating glow effect.
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Request location permission and get the current position.
  Future<void> _determinePosition() async {
    setState(() {
      _isFetchingLocation = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = 'Location services are disabled.';
        _isFetchingLocation = false;
      });
      return;
    }

    // Check permission.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = 'Location permissions are denied.';
          _isFetchingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _statusMessage = 'Location permissions are permanently denied.';
        _isFetchingLocation = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _statusMessage = 'Location fetched successfully.';
        _isFetchingLocation = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching location: $e';
        _isFetchingLocation = false;
      });
    }
  }

  /// Fetch user details from the "users" collection and send an SOS report.
  Future<void> _sendSOS() async {
    if (_currentPosition == null) {
      setState(() {
        _statusMessage = 'Location not available yet!';
      });
      return;
    }

    // Fetch current user using FirebaseAuth.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _statusMessage = 'User not logged in.';
      });
      return;
    }

    // Fetch user details from the "users" collection.
    DocumentSnapshot<Map<String, dynamic>> userDoc;
    try {
      userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error fetching user details: $e';
      });
      return;
    }
    final userData = userDoc.data() ?? {};

    try {
      QuerySnapshot authoritiesSnapshot =
          await FirebaseFirestore.instance.collection('authorities').get();

      List<String> extractPlayerIds(QuerySnapshot snapshot) {
        return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where((data) =>
                data.containsKey('playerid') &&
                data['playerid'] != null &&
                data['playerid'].toString().trim().isNotEmpty)
            .map((data) => data['playerid'] as String)
            .toList();
      }

      List<String> authorityPlayerIds = extractPlayerIds(authoritiesSnapshot);
      print(authorityPlayerIds);

      await Notification_sos(authorityPlayerIds, 'gfhhfhfh', 'danger');
      
      // Create a document in the "sos_reports" collection with location and user data.
      await FirebaseFirestore.instance.collection('sos_reports').add({
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'user': userData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('SOS Sent!'),
          content: const Text(
              'Your emergency report has been sent to the authorities.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      _animationController.reset();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error sending SOS: $e';
      });
      _animationController.reset();
    }
  }

  /// Start the long press animation.
  void _onLongPressStart(LongPressStartDetails details) {
    _animationController.forward();
  }

  /// Reset the animation if the long press is released early.
  void _onLongPressEnd(LongPressEndDetails details) async {
    if (_animationController.status != AnimationStatus.completed) {
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Wrap the body in a Container with a gradient background.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.red.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (_isFetchingLocation)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              // Small description explaining the purpose of the SOS page.
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'This page lets you send an emergency SOS alert with your current location to local authorities and contacts. Press and hold the button to trigger the alert.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              // SOS button with animated circular progress and pulsating glow.
              Center(
                child: GestureDetector(
                  onLongPressStart: _onLongPressStart,
                  onLongPressEnd: _onLongPressEnd,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsating glow effect behind the button.
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          double scale = 1 + _glowController.value * 0.2;
                          return Container(
                            width: 140 * scale,
                            height: 140 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent.withOpacity(
                                  0.3 * (1 - _glowController.value)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(
                                      0.5 * (1 - _glowController.value)),
                                  blurRadius: 20 * _glowController.value,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      // Animated circular progress indicator.
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return CircularProgressIndicator(
                              value: _animationController.value,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.red),
                            );
                          },
                        ),
                      ),
                      // The static SOS button with enhanced brightness.
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent,
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: null, // Only handles long press.
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade700,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(60),
                            elevation: 10,
                          ),
                          child: const Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Press and hold for 3 seconds to send an SOS alert',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _statusMessage,
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
    );
  }
}
