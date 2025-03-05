import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighborly/notification_sos.dart';

/// SosPage allows users to send an emergency SOS alert along with their current location.
class SosPage extends StatefulWidget {
  const SosPage({Key? key}) : super(key: key);

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with TickerProviderStateMixin {
  Position? _currentPosition;
  bool _isFetchingLocation = false;
  String _statusMessage = 'Need Emergency Help?';

  // Controller for the 15-second countdown.
  late AnimationController _animationController;
  // Controller for the pulsating glow effect.
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _determinePosition();

    // Set up the 15-second countdown animation.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // When the countdown completes, send the SOS.
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _sendSOS();
      }
    });

    // Pulsating glow effect.
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = 'Location services are disabled.';
        _isFetchingLocation = false;
      });
      return;
    }

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

  /// Fetch user details and send an SOS report.
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
      print(authorityPlayerIds);

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

  /// Called when the SOS button is tapped.
  void _onSOSButtonPressed() {
    if (_animationController.isAnimating) return;
    setState(() {
      _statusMessage = "SOS will be sent in 15 seconds. Swipe to cancel.";
    });
    _animationController.forward(from: 0.0);
  }

  /// Cancels the SOS request.
  void _cancelSOS() {
    if (_animationController.isAnimating) {
      _animationController.reset();
      setState(() {
        _statusMessage = "SOS request canceled.";
      });
    }
  }

  /// Returns the remaining seconds based on the animation value.
  int get _remainingSeconds {
    return (15 * (1 - _animationController.value)).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with gradient background.
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: const Radius.circular(20)),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        centerTitle: true,
        title: Text(
          _statusMessage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Body with gradient background.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.red.shade100],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                if (_isFetchingLocation)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Text(
                    'Tap the red button to start a 15-second SOS alert. Swipe the slider to cancel before time runs out.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                // SOS button with a circular timer overlay.
                Center(
                  child: GestureDetector(
                    onTap: _onSOSButtonPressed,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsating glow.
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            double scale = 1 + _glowController.value * 0.2;
                            return Container(
                              width: 160 * scale,
                              height: 160 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.redAccent.withOpacity(
                                    0.3 * (1 - _glowController.value)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withOpacity(
                                        0.5 * (1 - _glowController.value)),
                                    blurRadius:
                                        20 * _glowController.value,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                        // Custom circular timer drawn with CustomPaint.
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Attractive swipe-to-cancel slider with animated background.
                if (_animationController.isAnimating)
                  SwipeToCancel(
                    onSwipeCompleted: _cancelSOS,
                  ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Tap the button to send an SOS alert after 15 seconds unless canceled.',
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
class SwipeToCancel extends StatefulWidget {
  final VoidCallback onSwipeCompleted;
  const SwipeToCancel({Key? key, required this.onSwipeCompleted})
      : super(key: key);

  @override
  State<SwipeToCancel> createState() => _SwipeToCancelState();
}

class _SwipeToCancelState extends State<SwipeToCancel>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Compute available width as screen width minus total horizontal margin of 40.
    final double availableWidth = MediaQuery.of(context).size.width - 40;
    const double sliderHeight = 55.0;
    const double thumbDiameter = 50.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      width: availableWidth,
      height: sliderHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(sliderHeight / 2),
        color: Colors.red.shade50,
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Animated background fill behind the thumb.
          Positioned(
            left: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _dragPosition + thumbDiameter,
              height: sliderHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(sliderHeight / 2),
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withOpacity(0.5),
                    Colors.redAccent.withOpacity(0.0)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          // Shimmer effect overlay behind the text.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: 0.3,
                  alignment: Alignment(_shimmerController.value * 2 - 1, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.0)
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Background label with side padding.
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: thumbDiameter / 2),
              child: Center(
                child: Text(
                  'Swipe to cancel SOS',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Draggable circular thumb.
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
                if (_dragPosition > availableWidth * 0.6) {
                  widget.onSwipeCompleted();
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
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
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
    );
  }
}
