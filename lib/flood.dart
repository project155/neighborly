import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
      var snapshot = await _firestore
          .collection('reports')
          .where('category', isEqualTo: 'flood')
          .orderBy('timestamp', descending: true)
          .get();

      setState(() {
        _reports = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });

      // Add markers to the map
      _markers.clear();
      for (var report in _reports) {
        if (report['location'] != null) {
          double lat = (report['location']['latitude'] ?? 0).toDouble();
          double lng = (report['location']['longitude'] ?? 0).toDouble();
          print("Report Location: Lat: $lat, Lng: $lng");
          _markers.add(
            Marker(
              markerId: MarkerId(report['id']),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                  title: report['title'], snippet: report['description']),
            ),
          );
        }
      }

      // Center map based on the first report (if available)
      if (_markers.isNotEmpty) {
        var firstReport = _reports.first;
        double lat = (firstReport['location']['latitude'] ?? 0).toDouble();
        double lng = (firstReport['location']['longitude'] ?? 0).toDouble();
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(lat, lng)),
        );
      }
    } catch (e) {
      print("Error fetching reports: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Animated Snackbar Method (same as before)
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
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
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

  // Floating AppBar as an elongated cylinder overlapping the map.
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
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Title with Flood Icon and Text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_damage, size: 30, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  "Flood Reports",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            // Search Button triggers search
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No traditional appBar; using a Stack to overlay a floating bar on the map.
      body: Column(
        children: [
          // Map section with floating AppBar on top.
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
                          List<String> imageUrls = [];
                          if (report['imageUrl'] is List) {
                            imageUrls = List<String>.from(report['imageUrl']);
                          } else if (report['imageUrl'] is String &&
                              report['imageUrl'].isNotEmpty) {
                            imageUrls = [report['imageUrl']];
                          }

                          String reportId = report['id'];
                          String title = report['title'] ?? "No Title";
                          String description =
                              report['description'] ?? "No Description";
                          String category = report['category'] ?? "Unknown";
                          String urgency = report['urgency'] ?? "Normal";
                          String? latitude =
                              report['location']?['latitude']?.toString();
                          String? longitude =
                              report['location']?['longitude']?.toString();
                          int likes = report['likes'] ?? 0;
                          List comments = report['comments'] ?? [];
                          String userId = _auth.currentUser?.uid ?? "";
                          List likedBy =
                              List<String>.from(report['likedBy'] ?? []);
                          bool isLiked = likedBy.contains(userId);

                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageUrls.isNotEmpty)
                                  CarouselSlider(
                                    options: CarouselOptions(
                                      height: 250,
                                      enableInfiniteScroll: false,
                                      enlargeCenterPage: true,
                                    ),
                                    items: imageUrls.map((image) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 250,
                                        ),
                                      );
                                    }).toList(),
                                  ),
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
                                      Text(
                                        description,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700]),
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
                                                color: Colors.blueGrey)),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              isLiked
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_alt_outlined,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              _handleLike(reportId, isLiked);
                                              _showAnimatedSnackbar(isLiked
                                                  ? "Like removed!"
                                                  : "Liked!");
                                            },
                                          ),
                                          Text("$likes Likes",
                                              style:
                                                  TextStyle(color: Colors.blue)),
                                          IconButton(
                                            icon: Icon(Icons.comment_outlined,
                                                color: Colors.green),
                                            onPressed: () =>
                                                _showComments(context, reportId, comments),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.share_outlined,
                                                color: Colors.orange),
                                            onPressed: () =>
                                                _shareReport(title, description),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _handleLike(String docId, bool isLiked) {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;
    _firestore.collection('reports').doc(docId).update({
      'likes': isLiked ? FieldValue.increment(-1) : FieldValue.increment(1),
      'likedBy': isLiked
          ? FieldValue.arrayRemove([userId])
          : FieldValue.arrayUnion([userId]),
    });
  }

  void _shareReport(String title, String description) {
    Share.share('$title\n\n$description');
  }

  void _showComments(BuildContext context, String docId, List comments) {
    TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: comments
                      .map((comment) => ListTile(title: Text(comment)))
                      .toList(),
                ),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(hintText: "Add a comment..."),
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
                    _firestore.collection('reports').doc(docId).update({
                      'comments': FieldValue.arrayUnion([text]),
                    });
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      },
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
        close(context, null); // Close search delegate
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
          leading: Icon(Icons.water_damage, color: Colors.black87),
          title: Text(report['title'] ?? "No Title"),
          subtitle: Text(report['description'] ?? "No Description"),
          onTap: () {
            close(context, null); // Close search delegate
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FloodReportDetailPage(report: report),
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
          leading: Icon(Icons.water_damage, color: Colors.black87),
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

// A basic detail page for a flood report.
class FloodReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;

  FloodReportDetailPage({required this.report});

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = [];
    if (report['imageUrl'] is List) {
      imageUrls = List<String>.from(report['imageUrl']);
    } else if (report['imageUrl'] is String &&
        report['imageUrl'].isNotEmpty) {
      imageUrls = [report['imageUrl']];
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(report['title'] ?? "Report Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 250,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                ),
                items: imageUrls.map((image) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 250,
                    ),
                  );
                }).toList(),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['title'] ?? "No Title",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    report['description'] ?? "No Description",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Category: ${report['category'] ?? "Unknown"}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Urgency: ${report['urgency'] ?? "Normal"}",
                    style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                  ),
                  // Add additional details as needed...
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
