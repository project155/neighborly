import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neighborly/AuthoritySendnotification.dart';
import 'package:neighborly/Generatereports.dart';
import 'package:neighborly/Notificationpage.dart';
import 'package:neighborly/SOSpage.dart';
import 'package:neighborly/Sosreports.dart';
import 'package:neighborly/Userlogin.dart';
import 'package:neighborly/authorityreports/authorityflood.dart';
import 'package:neighborly/authorityreports/authorityChildabuse.dart';
import 'package:neighborly/authorityreports/authorityalcohol.dart';
import 'package:neighborly/authorityreports/authorityanimalabuse.dart';
import 'package:neighborly/authorityreports/authoritybribery.dart';
import 'package:neighborly/authorityreports/authoritydrought.dart';
import 'package:neighborly/authorityreports/authorityecohazard.dart';
import 'package:neighborly/authorityreports/authorityfire.dart';

import 'package:neighborly/authorityreports/authorityflood.dart';
import 'package:neighborly/authorityreports/authorityfoodi.dart';
import 'package:neighborly/authorityreports/authorityhygiene.dart';
import 'package:neighborly/authorityreports/authorityinfrastructure.dart';
import 'package:neighborly/authorityreports/authoritylandslide.dart';
import 'package:neighborly/authorityreports/authoritynarcotics.dart';
import 'package:neighborly/authorityreports/authorityroadincident.dart';
import 'package:neighborly/authorityreports/authoritysexual.dart';
import 'package:neighborly/authorityreports/authoritytheft.dart';
import 'package:neighborly/authorityreports/authoritytransportation.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthorityHome(),
  ));
}

class AuthorityHome extends StatefulWidget {
  @override
  _AuthorityHomeState createState() => _AuthorityHomeState();
}

class _AuthorityHomeState extends State<AuthorityHome> {
  List<String> noticeImages = [];
  bool _isLoading = true;
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchNoticeImages().then((_) {
      _startTimer();
    });
  }

  /// Fetch notice image URLs from Firestore collection 'noticeImages'
  Future<void> _fetchNoticeImages() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('noticeImages')
          .orderBy('uploadedAt', descending: true)
          .get();
      List<String> urls = snapshot.docs
          .map((doc) => doc.get('imageUrl') as String)
          .toList();
      setState(() {
        noticeImages = urls;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching notice images: $e");
      setState(() {
        noticeImages = [];
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (noticeImages.isNotEmpty) {
        if (_currentIndex < noticeImages.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0;
        }
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// Builds the notice slider section with rounded corners.
  Widget _buildNoticeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PageView.builder(
                  controller: _pageController,
                  itemCount: noticeImages.length,
                  itemBuilder: (context, index) {
                    String imageUrl = noticeImages[index];
                    if (imageUrl.startsWith("http")) {
                      return Image.network(imageUrl, fit: BoxFit.cover);
                    } else {
                      return Image.asset(imageUrl, fit: BoxFit.cover);
                    }
                  },
                ),
        ),
      ),
    );
  }

  /// Builds the Authority Actions section with grid items.
  Widget _buildAuthorityActionsSection() {
    // Define authority actions
    final List<Map<String, dynamic>> actions = [
      {
        "title": "Urgent SOS",
        "icon": Icons.warning,
        "page": SosReportPage(),
      },
      {
        "title": "Categorized Reports",
        "icon": Icons.list,
        "page": CategorizedReportsPage(), // Navigates to our new page.
      },
      {
        "title": "Send Alerts",
        "icon": Icons.notifications,
        "page": SendNotificationPage(),
      },
      {
        "title": "Generate Reports",
        "icon": Icons.analytics,
        "page": GenerateReports(),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Authority Actions",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // two items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _buildActionItem(
                    title: action["title"],
                    icon: action["icon"],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => action["page"]),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a clickable grid item for an authority action.
  Widget _buildActionItem({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 65) / 2,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Icon(icon, size: 30, color: Colors.blue),
            ),
            SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the SOS Reports section which fetches SOS reports from Firestore.
  Widget _buildSOSReportsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "SOS Reports",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            // StreamBuilder to fetch SOS reports from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sos_reports')
                  .orderBy('reportedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text("No SOS reports found."),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    String title = data['title'] ?? "No Title";
                    String description = data['description'] ?? "";
                    // Assume location is stored as a map with 'latitude' and 'longitude'
                    Map<String, dynamic>? location = data['location'];
                    double latitude = location?['latitude'] ?? 0.0;
                    double longitude = location?['longitude'] ?? 0.0;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ExpansionTile(
                        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        children: [
                          Container(
                            height: 200,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(latitude, longitude),
                                zoom: 14,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(doc.id),
                                  position: LatLng(latitude, longitude),
                                ),
                              },
                              // Disable map gestures for embedded preview.
                              zoomGesturesEnabled: false,
                              scrollGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
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
      // Custom AppBar with rounded bottom corners.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Authority Dashboard", style: TextStyle(color: Colors.white)),
            backgroundColor: Color.fromARGB(255, 95, 156, 255),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_active_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                },
              ),
            ],
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildNoticeSection(),
                _buildAuthorityActionsSection(),
                _buildSOSReportsSection(), // SOS Reports section.
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// New Categorized Reports page with three big cards.
class CategorizedReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double cardHeight = 150;
    return Scaffold(
      appBar: AppBar(
        title: Text("Categorized Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Big Card for Disaster Reports.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DisasterReportsPage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 60, color: Colors.red),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          "Disaster Reports",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Big Card for Public Issues Reports.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PublicIssuesReportsPage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.public, size: 60, color: Colors.green),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          "Public Issues Reports",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // New Big Card for Crimes Reports.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CrimesReportsPage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.gavel, size: 60, color: Colors.deepOrange),
                      SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          "Crimes Reports",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Disaster Reports page displaying four disaster type cards.
class DisasterReportsPage extends StatelessWidget {
  final List<Map<String, dynamic>> disasters = [
    {
      "title": "Flood",
      "icon": Icons.water_damage,
      "page": FloodReportClonePage(),
    },
    {
      "title": "Fire",
      "icon": Icons.local_fire_department,
      "page": FireReportClonePage(),
    },
    {
      "title": "Landslide",
      "icon": Icons.terrain,
      "page": LandslideReportClonePage(),
    },
    {
      "title": "Drought",
      "icon": Icons.wb_sunny,
      "page": DroughtReportClonePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 150;
    return Scaffold(
      appBar: AppBar(
        title: Text("Disaster Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: disasters.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final disaster = disasters[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => disaster["page"]),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        disaster["icon"],
                        size: 60,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 20),
                      Text(
                        disaster["title"],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Dummy page for Flood Reports.
class FloodReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flood Reports"),
      ),
      body: Center(
        child: Text("Flood Reports Details Here"),
      ),
    );
  }
}

/// Updated FireReportsPage with uploader details option.
class FireReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fire Reports"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fire_reports')
            .orderBy('reportedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(child: Text("No Fire reports found.")),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
              String title = data['title'] ?? "No Title";
              String description = data['description'] ?? "";
              // Assume location is stored as a map with 'latitude' and 'longitude'
              Map<String, dynamic>? location = data['location'];
              double latitude = location?['latitude'] ?? 0.0;
              double longitude = location?['longitude'] ?? 0.0;

              // Uploader details fields (adjust key names as per your Firestore structure)
              String uploaderName = data['uploaderName'] ?? "Unknown";
              String uploaderContact = data['uploaderContact'] ?? "Not Provided";

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  title: Text(title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    // Map preview for the report location
                    Container(
                      height: 200,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(latitude, longitude),
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: MarkerId(doc.id),
                            position: LatLng(latitude, longitude),
                          ),
                        },
                        zoomGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Button to show uploader details
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Uploader Details"),
                            content: Text(
                                "Name: $uploaderName\nContact: $uploaderContact"),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                                child: Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text("View Uploader Details"),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Dummy page for Landslide Reports.
class LandslideReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Landslide Reports"),
      ),
      body: Center(
        child: Text("Landslide Reports Details Here"),
      ),
    );
  }
}

/// Dummy page for Drought Reports.
class DroughtReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Drought Reports"),
      ),
      body: Center(
        child: Text("Drought Reports Details Here"),
      ),
    );
  }
}

/// Updated Public Issues Reports page with grid of cards.
class PublicIssuesReportsPage extends StatelessWidget {
  final List<Map<String, dynamic>> issues = [
    {
      "title": "Infrastructure Issues",
      "icon": FontAwesomeIcons.buildingCircleExclamation,
      "page": InfrastructureIssuesReportClonePage(),
    },
    {
      "title": "Eco Hazard",
      "icon": Icons.eco,
      "page": EcoHazardReportClonePage(),
    },
    {
      "title": "Road Incidents",
      "icon": FontAwesomeIcons.road,
      "page": RoadIncidentsReportClonePage(),
    },
    {
      "title": "Food Issues",
      "icon": Icons.fastfood,
      "page": FoodIssuesReportClonePage(),
    },
    {
      "title": "Hygiene Issues",
      "icon": Icons.clean_hands,
      "page": HygieneIssuesReportClonePage(),
    },
    {
      "title": "Transportation Issues",
      "icon": Icons.directions_bus,
      "page": TransportationReportClonePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 150;
    return Scaffold(
      appBar: AppBar(
        title: Text("Public Issues Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: issues.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final issue = issues[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => issue["page"]),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        issue["icon"],
                        size: 60,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 20),
                      Text(
                        issue["title"],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Updated Crimes Reports page with cards for each crime category.
class CrimesReportsPage extends StatelessWidget {
  final List<Map<String, dynamic>> crimeCategories = [
    {
      "title": "Sexual Abuse",
      "icon": Icons.report,
      "page": SexualAbuseReportClonePage(),
    },
    {
      "title": "Alcohol",
      "icon": FontAwesomeIcons.beer,
      "page": AlcoholReportClonePage(),
    },
    {
      "title": "Bribery",
      "icon": Icons.attach_money,
      "page": BriberyReportClonePage(),
    },
    {
      "title": "Child Abuse",
      "icon": Icons.child_care,
      "page": ChildAbuseReportClonePage(),
    },
    {
      "title": "Narcotics",
      "icon": Icons.local_pharmacy,
      "page": NarcoticsReportClonePage(),
    },
    {
      "title": "Theft",
      "icon": Icons.security,
      "page": TheftReportClonePage(),
    },
    {
      "title": "Animal Abuse",
      "icon": Icons.pets,
      "page": AnimalAbuseReportClonePage(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double cardHeight = 150;
    return Scaffold(
      appBar: AppBar(
        title: Text("Crimes Reports"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: crimeCategories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two cards per row.
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final category = crimeCategories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => category["page"]),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category["icon"],
                        size: 60,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 20),
                      Text(
                        category["title"],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



