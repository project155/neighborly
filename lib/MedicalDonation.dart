import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // For date/time formatting

class MedicalDonationsPage extends StatefulWidget {
  @override
  _MedicalDonationsPageState createState() => _MedicalDonationsPageState();
}

class _MedicalDonationsPageState extends State<MedicalDonationsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late GoogleMapController _mapController;
  Set<Marker> _markers = Set();
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;
  // For debugging: force trash icon display.
  bool forceShowTrashIcon = false;
  final LatLng _initialLocation =
      LatLng(11.194249397596916, 75.85098108272076);

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> _fetchDonations() async {
    try {
      // Get user's current position.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final double userLat = position.latitude;
      final double userLng = position.longitude;
      // Define a radius (e.g., 10 km).
      double radiusInMeters = 10000;

      // Fetch donations from Firestore from collection "donationRequests".
      var snapshot = await _firestore
          .collection('MedicalCharity')
          .orderBy('timestamp', descending: true)
          .get();

      // Convert snapshot to list of donations.
      List<Map<String, dynamic>> allDonations = snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Filter donations based on distance from user.
      _donations = allDonations.where((donation) {
        if (donation['location'] != null) {
          double donationLat =
              (donation['location']['latitude'] ?? 0).toDouble();
          double donationLng =
              (donation['location']['longitude'] ?? 0).toDouble();
          double distanceInMeters = Geolocator.distanceBetween(
              userLat, userLng, donationLat, donationLng);
          return distanceInMeters <= radiusInMeters;
        }
        return false;
      }).toList();

      // Update markers on the map.
      _markers.clear();
      for (var donation in _donations) {
        if (donation['location'] != null) {
          double lat = (donation['location']['latitude'] ?? 0).toDouble();
          double lng = (donation['location']['longitude'] ?? 0).toDouble();
          _markers.add(
            Marker(
              markerId: MarkerId(donation['id']),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                  title: donation['title'],
                  snippet: donation['description']),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        }
      }

      // Center the map on the first donation's location if available.
      if (_markers.isNotEmpty) {
        var firstDonation = _donations.first;
        double lat = (firstDonation['location']['latitude'] ?? 0).toDouble();
        double lng = (firstDonation['location']['longitude'] ?? 0).toDouble();
        _mapController.animateCamera(
          CameraUpdate.newLatLng(LatLng(lat, lng)),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching donations: $e");
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
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

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
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.medical_services, color: Colors.white),
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

  // Floating AppBar over the map.
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
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button.
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // Title with generic medical icon.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_services, size: 30, color: Colors.redAccent),
                SizedBox(width: 8),
                Text(
                  "Medical Donations",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            // Search button.
            IconButton(
              icon: Icon(Icons.search, color: Colors.black87),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: DonationSearchDelegate(donations: _donations),
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
              builder: (_) => FullScreenImagePage(imageUrl: imageUrl)),
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

  // Show a confirmation dialog before deleting a donation.
  void _confirmDelete(String donationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Donation"),
          content: Text("Are you sure you want to delete this donation?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDonation(donationId);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            )
          ],
        );
      },
    );
  }

  // Delete the donation from Firestore and update local state.
  Future<void> _deleteDonation(String donationId) async {
    try {
      await _firestore.collection('MedicalCharity').doc(donationId).delete();
      setState(() {
        _donations.removeWhere((donation) => donation['id'] == donationId);
      });
      _showAnimatedSnackbar("Donation deleted successfully!");
    } catch (e) {
      print("Error deleting donation: $e");
      _showAnimatedSnackbar("Failed to delete donation!");
    }
  }

  // Share donation details.
  void _shareDonation(String title, String description) {
    Share.share('$title\n\n$description');
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser?.uid ?? "";
    return Scaffold(
      body: Column(
        children: [
          // Map section with floating AppBar.
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
          // Donations list.
          Expanded(
            flex: 1,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _donations.isEmpty
                    ? Center(child: Text("No donations available"))
                    : ListView.builder(
                        itemCount: _donations.length,
                        itemBuilder: (context, index) {
                          var donation = _donations[index];
                          String donationUserId = donation['userId'] ??
                              donation['uid'] ??
                              "none";
                          List<String> imageUrls = [];
                          if (donation['imageUrl'] is List) {
                            imageUrls = List<String>.from(donation['imageUrl']);
                          } else if (donation['imageUrl'] is String &&
                              donation['imageUrl'].isNotEmpty) {
                            imageUrls = [donation['imageUrl']];
                          }
                          String donationId = donation['id'];
                          String title = donation['title'] ?? "No Title";
                          String description = donation['description'] ?? "No Description";
                          String category = donation['category'] ?? "Unknown";
                          String? latitude = donation['location']?['latitude']?.toString();
                          String? longitude = donation['location']?['longitude']?.toString();
                          // Extract contact details.
                          Map<String, dynamic>? contact = donation['contact'];

                          return InkWell(
                            onTap: () {
                              // Animate map to donation location.
                              if (donation['location'] != null) {
                                double lat = (donation['location']['latitude'] ?? 0).toDouble();
                                double lng = (donation['location']['longitude'] ?? 0).toDouble();
                                _mapController.animateCamera(
                                  CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18),
                                );
                                _mapController.showMarkerInfoWindow(
                                    MarkerId(donation['id']));
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (imageUrls.isNotEmpty)
                                    ImageCarousel(imageUrls: imageUrls),
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 5),
                                        Text(description,
                                            style: TextStyle(
                                                fontSize: 14, color: Colors.black)),
                                        SizedBox(height: 5),
                                        // Display contact information: only name and phone.
                                        if (contact != null) ...[
                                          Text(
                                            "Name: ${contact['name'] ?? 'N/A'}",
                                            style: TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                          Text(
                                            "Phone: ${contact['phone'] ?? 'N/A'}",
                                            style: TextStyle(fontSize: 14, color: Colors.black87),
                                          ),
                                          SizedBox(height: 5),
                                        ],
                                        Text(
                                          "Posted on: ${donation['timestamp'] != null ? DateFormat('dd MMM yyyy, hh:mm a').format((donation['timestamp'] as Timestamp).toDate()) : 'Unknown'}",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        SizedBox(height: 5),
                                        Text("Category: $category",
                                            style: TextStyle(fontWeight: FontWeight.bold)),
                                        if (latitude != null && longitude != null)
                                          Text("Location: $latitude, $longitude",
                                              style: TextStyle(color: Colors.black, fontSize: 12)),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.share_outlined, color: Colors.black),
                                              onPressed: () => _shareDonation(title, description),
                                            ),
                                            if (forceShowTrashIcon ||
                                                ((donation['userId'] ?? donation['uid']) == currentUserId))
                                              IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red),
                                                onPressed: () => _confirmDelete(donationId),
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
    );
  }
}

// Image carousel widget.
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
                        builder: (_) => FullScreenImagePage(imageUrl: image)),
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
              margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _current == entry.key ? Colors.redAccent : Colors.grey.shade400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Search delegate for donations.
class DonationSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> donations;
  DonationSearchDelegate({required this.donations});
  
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
    final results = donations.where((donation) {
      final title = donation['title']?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase());
    }).toList();
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final donation = results[index];
        return ListTile(
          leading: Icon(Icons.medical_services, color: Colors.redAccent),
          title: Text(donation['title'] ?? "No Title"),
          subtitle: Text(donation['description'] ?? "No Description"),
          onTap: () {
            close(context, null);
          },
        );
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = donations.where((donation) {
      final title = donation['title']?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase());
    }).toList();
    
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final donation = suggestions[index];
        return ListTile(
          leading: Icon(Icons.medical_services, color: Colors.redAccent),
          title: Text(donation['title'] ?? "No Title"),
          onTap: () {
            query = donation['title'] ?? "";
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
    return Scaffold(
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
    );
  }
}
