import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighborly/notification_sos.dart';

/// Define your primary theme color for non-SOS elements.
const Color primaryColor = Color.fromARGB(255, 9, 60, 83);

/// SosPage allows users to send an emergency SOS alert along with their current location.
class SosPage extends StatefulWidget {
  const SosPage({Key? key}) : super(key: key);

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with TickerProviderStateMixin {
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  // Internal status used for debugging (not shown in the AppBar).
  String _statusMessage = 'Need Emergency Help?';

  // Controller for the 15-second countdown.
  late AnimationController _animationController;
  // Controller for the ripple effect.
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _determinePosition();

    // Countdown controller.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _sendSOS();
      }
    });

    // Ripple effect controller.
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    setState(() {
      _isFetchingLocation = true;
    });
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = 'Location services are disabled.';
        _isFetchingLocation = false;
      });
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
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

  Future<void> _sendSOS() async {
    if (_currentPosition == null) {
      setState(() {
        _statusMessage = 'Location not available yet!';
      });
      return;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _statusMessage = 'User not logged in.';
      });
      return;
    }
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
      await Notification_sos(authorityPlayerIds, 'SOS Alert', 'Emergency');
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

  void _onSOSButtonPressed() {
    if (_animationController.isAnimating) return;
    setState(() {
      _statusMessage = "SOS will be sent in 15 seconds. Swipe to cancel.";
    });
    _animationController.forward(from: 0.0);
  }

  void _cancelSOS() {
    if (_animationController.isAnimating) {
      _animationController.reset();
      setState(() {
        _statusMessage = "SOS request canceled.";
      });
    }
  }

  int get _remainingSeconds {
    return (15 * (1 - _animationController.value)).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar always shows "Emergency SOS".
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            centerTitle: true,
            title: const Text(
              'Emergency SOS',
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    Color.fromARGB(255, 0, 115, 168),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            children: [
              SizedBox(height: 40,),
              // New big text under the AppBar.
              const Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Are you in an Unusual Situation?',
                  style: TextStyle(
                    fontFamily: 'proxima',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_isFetchingLocation)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Text(
                  'Tap the red button to start a 15-second SOS alert. Swipe the slider to cancel before time runs out.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontFamily: 'proxima',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 120,),
              //const Spacer(),
              // SOS button with full red circle, ripple effect, and timer overlay.
              Center(
                child: GestureDetector(
                  onTap: _onSOSButtonPressed,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ripple effect: an expanding red border.
                      AnimatedBuilder(
                        animation: _rippleController,
                        builder: (context, child) {
                          double scale = 1 + _rippleController.value * 0.5;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Full red circle background.
                      Container(
                        width: 160,
                        height: 160,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                      ),
                      // Custom circular timer overlay.
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: CircleTimerPainter(
                                progress: _animationController.value,
                                backgroundColor: Colors.grey.shade300,
                                progressColor: Colors.red,
                              ),
                              child: const SizedBox.expand(),
                            );
                          },
                        ),
                      ),
                      // Transparent clickable layer.
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ElevatedButton(
                          onPressed: _onSOSButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: const CircleBorder(),
                          ),
                          child: const SizedBox.shrink(),
                        ),
                      ),
                      // "SOS" text on top.
                      const Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'proxima',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Show the swipe-to-cancel slider only when the countdown animation is active.
              if (_animationController.isAnimating)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    SwipeToCancel(
                      onSwipeCompleted: () {
                        _cancelSOS();
                      },
                    ),
                  ],
                ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Tap the button to send an SOS alert after 15 seconds unless canceled.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'proxima',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw a circular timer.
class CircleTimerPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  CircleTimerPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);
    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircleTimerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A custom swipe-to-cancel widget that mimics a swipe-to-unlock UI.
/// The widget uses LayoutBuilder to constrain the thumb within the available width.
/// The slider width has been reduced to 80% of the parent's width.
class SwipeToCancel extends StatefulWidget {
  final VoidCallback? onSwipeCompleted;
  const SwipeToCancel({Key? key, this.onSwipeCompleted}) : super(key: key);

  @override
  State<SwipeToCancel> createState() => _SwipeToCancelState();
}

class _SwipeToCancelState extends State<SwipeToCancel> {
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Set sliderWidth to 80% of available width.
      final double sliderWidth = constraints.maxWidth * 0.8;
      final double availableWidth = sliderWidth;
      const double sliderHeight = 55.0;
      const double thumbDiameter = 50.0;

      return Center(
        child: Container(
          width: sliderWidth,
          height: sliderHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(sliderHeight / 2),
            color: primaryColor.withOpacity(0.1),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Background fill behind the thumb.
              Positioned(
                left: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: _dragPosition + thumbDiameter,
                  height: sliderHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(sliderHeight / 2),
                    color: primaryColor.withOpacity(0.5),
                  ),
                ),
              ),
              // Centered label.
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: thumbDiameter / 2),
                  child: Center(
                    child: Text(
                      'Swipe to cancel SOS',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'proxima',
                      ),
                    ),
                  ),
                ),
              ),
              // Draggable thumb.
              Positioned(
                left: _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition += details.delta.dx;
                      _dragPosition = _dragPosition.clamp(0.0, availableWidth - thumbDiameter);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition >= availableWidth - thumbDiameter) {
                      if (widget.onSwipeCompleted != null) widget.onSwipeCompleted!();
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    } else {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: thumbDiameter,
                    height: thumbDiameter,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
