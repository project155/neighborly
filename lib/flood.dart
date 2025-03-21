import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';  // Added for date/time formatting

class FloodReportPage extends StatefulWidget {
  @override
  _FloodReportPageState createState() => _FloodReportPageState();
}

class _FloodReportPageState extends State<FloodReportPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late GoogleMapController _mapController;
  Set<Marker> _markers = Set();
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  // Set to true to force trash icon display for debugging.
  bool forceShowTrashIcon = false;

  final LatLng _initialLocation =
      LatLng(11.194249397596916, 75.85098108272076);

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> _fetchReports() async {
    try {
      // Get user's current position.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final double userLat = position.latitude;
      final double userLng = position.longitude;
      // Define a radius in meters (e.g., 10000m for 10 km).
      double radiusInMeters = 10000;

      // Fetch all 'flood' reports.
      var snapshot = await _firestore
          .collection('reports')
          .where('category', isEqualTo: 'flood')
          .orderBy('timestamp', descending: true)
          .get();

      // Convert snapshot to a list of reports.
      List<Map<String, dynamic>> allReports = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter reports based on distance from the user.
      _reports = allReports.where((report) {
        if (report['location'] != null) {
          double reportLat =
              (report['location']['latitude'] ?? 0).toDouble();
          double reportLng =
              (report['location']['longitude'] ?? 0).toDouble();
          double distanceInMeters = Geolocator.distanceBetween(
              userLat, userLng, reportLat, reportLng);
          return distanceInMeters <= radiusInMeters;
        }
        return false;
      }).toList();

      // Update markers for each report.
      _markers.clear();
      for (var report in _reports) {
        if (report['location'] != null) {
          double lat = (report['location']['latitude'] ?? 0).toDouble();
          double lng = (report['location']['longitude'] ?? 0).toDouble();
          _markers.add(
            Marker(
              markerId: MarkerId(report['id']),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                  title: report['title'],
                  snippet: report['description']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
            ),
          );
        }
      }

      // Center the map on the first report's location (if available).
      if (_markers.isNotEmpty) {
        var firstReport = _reports.first;
        double lat =
            (firstReport['location']['latitude'] ?? 0).toDouble();
        double lng =
            (firstReport['location']['longitude'] ?? 0).toDouble();
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(lat, lng)),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching reports: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Animated snackbar for notifications.
  void _showAnimatedSnackbar(String message) {
    AnimationController controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    Animation<Offset> offsetAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: offsetAnimation,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)!.insert(overlayEntry);
    controller.forward();

    Future.delayed(Duration(seconds: 3), () async {
      await controller.reverse();
      overlayEntry.remove();
      controller.dispose();
    });
  }

  // Floating AppBar widget over the map.
  Widget _buildFloatingAppBar() {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button.
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Title with Flood Icon.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop,
                    size: 30, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(
                  "Flood Reports",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ],
            ),
            // Search Button.
            IconButton(
              icon: Icon(Icons.search, color: Colors.black87),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: FloodReportSearchDelegate(reports: _reports),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Tappable image that opens a full-screen view.
  Widget _buildTappableImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  FullScreenImagePage(imageUrl: imageUrl)),
        );
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250,
      ),
    );
  }

  // Original like functionality (retained for reference)
  void _handleLike(String docId, bool isLiked) {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;
    int index = _reports.indexWhere((report) => report['id'] == docId);
    if (index != -1) {
      setState(() {
        if (isLiked) {
          _reports[index]['likes'] =
              ((_reports[index]['likes'] ?? 0) as int) - 1;
          List likedBy = List.from(_reports[index]['likedBy'] ?? []);
          likedBy.remove(userId);
          _reports[index]['likedBy'] = likedBy;
        } else {
          _reports[index]['likes'] =
              ((_reports[index]['likes'] ?? 0) as int) + 1;
          List likedBy = List.from(_reports[index]['likedBy'] ?? []);
          likedBy.add(userId);
          _reports[index]['likedBy'] = likedBy;
        }
      });
      _firestore.collection('reports').doc(docId).update({
        'likes': isLiked ? FieldValue.increment(-1) : FieldValue.increment(1),
        'likedBy': isLiked
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
      });
    }
  }

  // New rating functions for upvote/downvote.
  void _handleUpvote(String docId, bool isUpvoted) {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;
    int index = _reports.indexWhere((report) => report['id'] == docId);
    if (index != -1) {
      setState(() {
        if (isUpvoted) {
          _reports[index]['upvotes'] =
              ((_reports[index]['upvotes'] ?? 0) as int) - 1;
          List upvotedBy = List.from(_reports[index]['upvotedBy'] ?? []);
          upvotedBy.remove(userId);
          _reports[index]['upvotedBy'] = upvotedBy;
        } else {
          _reports[index]['upvotes'] =
              ((_reports[index]['upvotes'] ?? 0) as int) + 1;
          List upvotedBy = List.from(_reports[index]['upvotedBy'] ?? []);
          upvotedBy.add(userId);
          _reports[index]['upvotedBy'] = upvotedBy;
          if ((_reports[index]['downvotedBy'] ?? []).contains(userId)) {
            _reports[index]['downvotes'] =
                ((_reports[index]['downvotes'] ?? 0) as int) - 1;
            List downvotedBy = List.from(_reports[index]['downvotedBy'] ?? []);
            downvotedBy.remove(userId);
            _reports[index]['downvotedBy'] = downvotedBy;
          }
        }
      });
      _firestore.collection('reports').doc(docId).update({
        'upvotes': isUpvoted ? FieldValue.increment(-1) : FieldValue.increment(1),
        'upvotedBy': isUpvoted
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
        if (!isUpvoted && (_reports[index]['downvotedBy'] ?? []).contains(userId))
          'downvotes': FieldValue.increment(-1),
        if (!isUpvoted && (_reports[index]['downvotedBy'] ?? []).contains(userId))
          'downvotedBy': FieldValue.arrayRemove([userId]),
      });
    }
  }

  void _handleDownvote(String docId, bool isDownvoted) {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;
    int index = _reports.indexWhere((report) => report['id'] == docId);
    if (index != -1) {
      setState(() {
        if (isDownvoted) {
          _reports[index]['downvotes'] =
              ((_reports[index]['downvotes'] ?? 0) as int) - 1;
          List downvotedBy = List.from(_reports[index]['downvotedBy'] ?? []);
          downvotedBy.remove(userId);
          _reports[index]['downvotedBy'] = downvotedBy;
        } else {
          _reports[index]['downvotes'] =
              ((_reports[index]['downvotes'] ?? 0) as int) + 1;
          List downvotedBy = List.from(_reports[index]['downvotedBy'] ?? []);
          downvotedBy.add(userId);
          _reports[index]['downvotedBy'] = downvotedBy;
          if ((_reports[index]['upvotedBy'] ?? []).contains(userId)) {
            _reports[index]['upvotes'] =
                ((_reports[index]['upvotes'] ?? 0) as int) - 1;
            List upvotedBy = List.from(_reports[index]['upvotedBy'] ?? []);
            upvotedBy.remove(userId);
            _reports[index]['upvotedBy'] = upvotedBy;
          }
        }
      });
      _firestore.collection('reports').doc(docId).update({
        'downvotes': isDownvoted ? FieldValue.increment(-1) : FieldValue.increment(1),
        'downvotedBy': isDownvoted
            ? FieldValue.arrayRemove([userId])
            : FieldValue.arrayUnion([userId]),
        if (!isDownvoted && (_reports[index]['upvotedBy'] ?? []).contains(userId))
          'upvotes': FieldValue.increment(-1),
        if (!isDownvoted && (_reports[index]['upvotedBy'] ?? []).contains(userId))
          'upvotedBy': FieldValue.arrayRemove([userId]),
      });
    }
  }

  double _calculateLegitPercentage(Map<String, dynamic> report) {
    int upvotes = report['upvotes'] ?? 0;
    int downvotes = report['downvotes'] ?? 0;
    int total = upvotes + downvotes;
    if (total == 0) return 0;
    return (upvotes / total) * 100;
  }

  // Display comments in a bottom sheet.
  void _showComments(BuildContext context, String docId) {
    int reportIndex = _reports.indexWhere((report) => report['id'] == docId);
    List<dynamic> comments = reportIndex != -1
        ? List.from(_reports[reportIndex]['comments'] ?? [])
        : [];
    TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: comments.map((comment) {
                        if (comment is Map && comment.containsKey('name')) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(
                                  'assets/images/anonymous_avatar.png'),
                            ),
                            title: Text(
                              comment['name'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(comment['comment'] ?? ""),
                          );
                        } else {
                          return ListTile(title: Text(comment.toString()));
                        }
                      }).toList(),
                    ),
                  ),
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: "Add a comment..."),
                    onSubmitted: (text) {
                      if (text.isNotEmpty) {
                        var newComment = {
                          'name': 'Anonymous',
                          'comment': text
                        };
                        setModalState(() {
                          comments.add(newComment);
                        });
                        if (reportIndex != -1) {
                          setState(() {
                            _reports[reportIndex]['comments'] =
                                List.from(_reports[reportIndex]['comments'] ?? [])
                                  ..add(newComment);
                          });
                        }
                        _firestore.collection('reports').doc(docId).update({
                          'comments': FieldValue.arrayUnion([newComment]),
                        });
                        commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Share report using share_plus.
  void _shareReport(String title, String description) {
    Share.share('$title\n\n$description');
  }

  // _confirmDelete method to show a confirmation dialog before deleting a report.
  void _confirmDelete(String reportId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Report"),
          content: Text("Are you sure you want to delete this report?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReport(reportId);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            )
          ],
        );
      },
    );
  }

  // Delete the report from Firestore and update the local state.
  Future<void> _deleteReport(String reportId) async {
    try {
      await _firestore.collection('reports').doc(reportId).delete();
      setState(() {
        _reports.removeWhere((report) => report['id'] == reportId);
      });
      _showAnimatedSnackbar("Report deleted successfully!");
    } catch (e) {
      print("Error deleting report: $e");
      _showAnimatedSnackbar("Failed to delete report!");
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser?.uid ?? "";
    return Theme(
      data: ThemeData(fontFamily: 'proxima'),
      child: Scaffold(
        body: Column(
          children: [
            // Map section with the floating AppBar.
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _initialLocation,
                      zoom: 15,
                    ),
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    zoomControlsEnabled: true,
                    markers: _markers,
                  ),
                  _buildFloatingAppBar(),
                ],
              ),
            ),
            // Reports List section.
            Expanded(
              flex: 1,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _reports.isEmpty
                      ? Center(child: Text("No reports available"))
                      : ListView.builder(
                          itemCount: _reports.length,
                          itemBuilder: (context, index) {
                            var report = _reports[index];
                            // Debug: print report userId and current user id.
                            String reportUserId = report['userId'] ??
                                report['uid'] ??
                                "none";
                            List<String> imageUrls = [];
                            if (report['imageUrl'] is List) {
                              imageUrls =
                                  List<String>.from(report['imageUrl']);
                            } else if (report['imageUrl'] is String &&
                                report['imageUrl'].isNotEmpty) {
                              imageUrls = [report['imageUrl']];
                            }
                            String reportId = report['id'];
                            String title =
                                report['title'] ?? "No Title";
                            String description = report['description'] ??
                                "No Description";
                            String category =
                                report['category'] ?? "Unknown";
                            String urgency =
                                report['urgency'] ?? "Normal";
                            String? latitude =
                                report['location']?['latitude']?.toString();
                            String? longitude =
                                report['location']?['longitude']?.toString();

                            // Determine if the current user has upvoted or downvoted.
                            List upvotedBy =
                                List.from(report['upvotedBy'] ?? []);
                            List downvotedBy =
                                List.from(report['downvotedBy'] ?? []);
                            bool isUpvoted = upvotedBy.contains(currentUserId);
                            bool isDownvoted = downvotedBy.contains(currentUserId);

                            return InkWell(
                              onTap: () {
                                // When tapping a report, animate the map to its location and show its info window.
                                if (report['location'] != null) {
                                  double lat = (report['location']['latitude'] ?? 0)
                                      .toDouble();
                                  double lng = (report['location']['longitude'] ?? 0)
                                      .toDouble();
                                  _mapController.animateCamera(
                                    CameraUpdate.newLatLngZoom(
                                        LatLng(lat, lng), 18),
                                  );
                                  _mapController.showMarkerInfoWindow(
                                      MarkerId(report['id']));
                                }
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    if (imageUrls.isNotEmpty)
                                      ImageCarousel(
                                          imageUrls: imageUrls),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(title,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 5),
                                          Text(description,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black)),
                                          // Date and time display added here
                                          SizedBox(height: 5),
                                          Text(
                                            "Reported on: ${report['timestamp'] != null ? DateFormat('dd MMM yyyy, hh:mm a').format((report['timestamp'] as Timestamp).toDate()) : 'Unknown'}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Category: $category",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold)),
                                              Text("Urgency: $urgency",
                                                  style: TextStyle(
                                                      color: Colors.blueAccent)),
                                            ],
                                          ),
                                          if (latitude != null &&
                                              longitude != null)
                                            Text("Location: $latitude, $longitude",
                                                style: TextStyle(
                                                    color: Color.fromARGB(255, 0, 0, 0),
                                                    fontSize: 12)),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.thumb_up,
                                                  color: isUpvoted ? Colors.blue : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  _handleUpvote(reportId, isUpvoted);
                                                  _showAnimatedSnackbar(isUpvoted ? "Upvote removed!" : "Upvoted!");
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.thumb_down,
                                                  color: isDownvoted ? Colors.red : Colors.grey,
                                                ),
                                                onPressed: () {
                                                  _handleDownvote(reportId, isDownvoted);
                                                  _showAnimatedSnackbar(isDownvoted ? "Downvote removed!" : "Downvoted!");
                                                },
                                              ),
                                              Text(
                                                (_calculateLegitPercentage(report) > 0)
                                                    ? "Legit: ${_calculateLegitPercentage(report).toStringAsFixed(0)}%"
                                                    : "No votes yet",
                                                style: TextStyle(color: Colors.black),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.comment_outlined, color: Colors.black),
                                                onPressed: () => _showComments(context, reportId),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.share_outlined, color: Colors.black),
                                                onPressed: () => _shareReport(title, description),
                                              ),
                                              if (forceShowTrashIcon ||
                                                  ((report['userId'] ?? report['uid']) == currentUserId))
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _confirmDelete(reportId),
                                                ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// Carousel widget for displaying report images.
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  ImageCarousel({required this.imageUrls});
  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 250,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: widget.imageUrls.map((image) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            FullScreenImagePage(imageUrl: image)),
                  );
                },
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 250,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(
                  vertical: 2.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == entry.key
                    ? Colors.blueAccent
                    : Colors.grey.shade400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Custom SearchDelegate for flood reports.
class FloodReportSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> reports;
  FloodReportSearchDelegate({required this.reports});
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        )
    ];
  }
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
  @override
  Widget buildResults(BuildContext context) {
    final results = reports.where((report) {
      final title = report['title']?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final report = results[index];
        return ListTile(
          leading: Icon(Icons.water_drop, color: Colors.blueAccent),
          title: Text(report['title'] ?? "No Title"),
          subtitle: Text(report['description'] ?? "No Description"),
          onTap: () {
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FloodReportPage(), // or your detailed page if applicable
              ),
            );
          },
        );
      },
    );
  }
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = reports.where((report) {
      final title = report['title']?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase());
    }).toList();
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final report = suggestions[index];
        return ListTile(
          leading: Icon(Icons.water_drop, color: Colors.blueAccent),
          title: Text(report['title'] ?? "No Title"),
          onTap: () {
            query = report['title'] ?? "";
            showResults(context);
          },
        );
      },
    );
  }
}

// Full screen image view.
class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  FullScreenImagePage({required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(fontFamily: 'proxima'),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
