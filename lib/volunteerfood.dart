import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class FoodDonationVolunteerPage extends StatefulWidget {
  @override
  _FoodDonationVolunteerPageState createState() => _FoodDonationVolunteerPageState();
}

class _FoodDonationVolunteerPageState extends State<FoodDonationVolunteerPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _donations = [];
  bool _isLoading = true;

  // Default location for map initial camera position.
  final LatLng _initialLocation = LatLng(11.1942494, 75.8509811);

  // Hard-coded static locations for orphanages and old age homes.
  final List<Map<String, dynamic>> _staticLocations = [
    {
      'id': 'orphanage_1',
      'name': 'Sunrise Orphanage',
      'latitude': 11.1945,
      'longitude': 75.8500,
      'type': 'Orphanage',
    },
    {
      'id': 'oldage_1',
      'name': 'Happy Old Age Home',
      'latitude': 11.1950,
      'longitude': 75.8510,
      'type': 'Old Age Home',
    },
    // Add more locations as needed.
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToDonations();
  }

  void _subscribeToDonations() {
    _firestore
        .collection('food_donations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> donations = [];
      Set<Marker> markers = {};

      // Build markers for donation requests.
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        donations.add(data);
        if (data['pickupLocation'] != null) {
          double lat = (data['pickupLocation']['latitude'] as num).toDouble();
          double lng = (data['pickupLocation']['longitude'] as num).toDouble();
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: data['foodName'] ?? 'No Name',
                snippet: data['foodType'] ?? '',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          );
        }
      }

      // Add static markers for orphanages and old age homes in blue.
      for (var loc in _staticLocations) {
        markers.add(
          Marker(
            markerId: MarkerId(loc['id']),
            position: LatLng(loc['latitude'], loc['longitude']),
            infoWindow: InfoWindow(
              title: loc['name'],
              snippet: loc['type'],
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }

      setState(() {
        _donations = donations;
        _markers = markers;
        _isLoading = false;
      });

      // Center the map on the first donation's pickup location, if available.
      if (_donations.isNotEmpty && _mapController != null) {
        var first = _donations.first;
        if (first['pickupLocation'] != null) {
          double lat = (first['pickupLocation']['latitude'] as num).toDouble();
          double lng = (first['pickupLocation']['longitude'] as num).toDouble();
          _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
        }
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  // Opens a dialog to update the status of a donation.
  void _showStatusUpdateDialog(String docId, String currentStatus) {
    List<String> statusOptions = [
      "Accepted",
      "Volunteer on the way",
      "Order Picked Up",
      "Completed"
    ];
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStatus;
        return AlertDialog(
          title: Text("Update Donation Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusOptions.map((status) {
              return RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: selectedStatus,
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                  Navigator.of(context).pop(value);
                },
              );
            }).toList(),
          ),
        );
      },
    ).then((selectedStatus) {
      if (selectedStatus != null && selectedStatus != currentStatus) {
        _updateDonationStatus(docId, selectedStatus);
      }
    });
  }

  Future<void> _updateDonationStatus(String docId, String newStatus) async {
    try {
      await _firestore.collection('food_donations').doc(docId).update({
        'orderStatus': newStatus,
      });
      _showAnimatedSnackbar("Status updated to '$newStatus'");
    } catch (e) {
      _showAnimatedSnackbar("Failed to update status");
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
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  // Floating app bar widget over the map.
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
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
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
            // Title.
            Text(
              "Food Donation Requests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(width: 48), // Dummy spacing to balance the row.
          ],
        ),
      ),
    );
  }

  // Custom update status button with gradient background.
  Widget _buildUpdateStatusButton(String donationId, String orderStatus) {
    return GestureDetector(
      onTap: () => _showStatusUpdateDialog(donationId, orderStatus),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              offset: Offset(0, 4),
              blurRadius: 4,
            )
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.update, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Update Status",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build a card for each donation request, including image previews.
  Widget _buildDonationCard(Map<String, dynamic> donation) {
    String donationId = donation['id'];
    String foodType = donation['foodType'] ?? 'Unknown';
    String foodName = donation['foodName'] ?? 'No Name';
    String description = donation['description'] ?? '';
    String quantity = donation['quantity'] ?? '';
    String expiryDate = donation['expiryDate'] != null ? donation['expiryDate'].toString().split('T').first : '';
    String expiryTime = donation['expiryTime'] ?? '';
    String orderStatus = donation['orderStatus'] ?? 'Pending';
    String pickupLocationStr = '';
    if (donation['pickupLocation'] != null) {
      double lat = (donation['pickupLocation']['latitude'] as num).toDouble();
      double lng = (donation['pickupLocation']['longitude'] as num).toDouble();
      pickupLocationStr = '($lat, $lng)';
    }

    Widget imageSection = SizedBox.shrink();
    if (donation['imageUrls'] != null &&
        (donation['imageUrls'] as List).isNotEmpty) {
      List imageUrls = donation['imageUrls'];
      imageSection = Container(
        height: 150,
        margin: EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Open full-screen image view with all images.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenImagePage(
                      imageUrls: List<String>.from(imageUrls),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrls[index],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageSection,
            Text("Food: $foodName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Type: $foodType", style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text("Description: $description", style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text("Quantity: $quantity", style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text("Expiry: $expiryDate $expiryTime", style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text("Pickup: $pickupLocationStr", style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text("Status: $orderStatus", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            // Use the custom update status button.
            _buildUpdateStatusButton(donationId, orderStatus),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Map view section.
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
                  markers: _markers,
                  myLocationEnabled: true,
                  zoomControlsEnabled: true,
                ),
                _buildFloatingAppBar(),
              ],
            ),
          ),
          // Donation requests list.
          Expanded(
            flex: 1,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _donations.isEmpty
                    ? Center(child: Text("No donation requests available"))
                    : ListView.builder(
                        itemCount: _donations.length,
                        itemBuilder: (context, index) {
                          return _buildDonationCard(_donations[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Full screen image view that displays a carousel of images.
class FullScreenImagePage extends StatelessWidget {
  final List<String> imageUrls;
  FullScreenImagePage({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
