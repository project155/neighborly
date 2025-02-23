import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighborly/Animalabuse.dart';
import 'package:neighborly/Drought.dart';
import 'package:neighborly/Ecohazard.dart';
import 'package:neighborly/Fooddonation.dart';
import 'package:neighborly/Foodsafety.dart';
import 'package:neighborly/Hygieneissues.dart';
import 'package:neighborly/Landslide.dart';
import 'package:neighborly/Narcotics.dart';
import 'package:neighborly/Notificationpage.dart';
import 'package:neighborly/Roadincidents.dart';
import 'package:neighborly/alcohol.dart';
import 'package:neighborly/authority.dart';
import 'package:neighborly/bribery.dart';
import 'package:neighborly/flood.dart';
import 'package:neighborly/loginuser.dart';
import 'package:neighborly/newreport.dart';
import 'package:neighborly/Sexualabuse.dart';
import 'package:neighborly/Userprofile.dart';
import 'package:neighborly/wildfire.dart';
import 'package:neighborly/Lostandfound.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Userhome(),
    );
  }
}

class Userhome extends StatefulWidget {
  @override
  _UserhomeState createState() => _UserhomeState();
}

class _UserhomeState extends State<Userhome> {
  final List<String> disasterTypes = [
    "Flood/Rainfall",
    "Fire",
    "Landslide",
    "Drought"
  ];
  final List<String> newCategoryItems = [
    "Sexual Abuse",
    "Narcotics",
    "Road Incidents",
    "Eco Hazard",
    "Alcohol",
    "Animal Abuse",
    "Bribery",
    "Food Safety",
    "Hygiene Issues"
  ];
  final List<String> helpandrecover = [
    "Food Donation",
    "Lost & Found",
    "Example Feature 2",
  ];

  // Notice images are fetched from Firestore.
  List<String> noticeImages = [];
  bool _isLoading = true;

  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchNoticeImages().then((_) {
      _startTimer();
    });
  }

  /// Fetch notice image URLs from Firestore collection 'noticeImages'.
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
      print("Error fetching images: $e");
      setState(() {
        noticeImages = [];
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 3), (timer) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Neighborly", style: TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 95, 156, 255),
            actions: [
              // Bell icon navigates to NotificationPage.
              IconButton(
                icon: Icon(Icons.notifications_active_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => NotificationPage()));
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
          // Main content.
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildNoticeSection(),
                _buildSection("Report Disaster", disasterTypes),
                _buildSection("Report public issues", newCategoryItems),
                _buildSection("Help And Recover", helpandrecover),
              ],
            ),
          ),
          // Floating bottom navigation bar.
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 95, 156, 255),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(Icons.home, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginUser()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => UserProfile()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.post_add_rounded, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CreateReportPage()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginUser()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.sos_sharp, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginUser()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds the notice slider section with rounded corners.
  Widget _buildNoticeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50), // More rounded look.
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50), // Enforce rounded clipping.
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PageView.builder(
                  controller: _pageController,
                  itemCount: noticeImages.length,
                  itemBuilder: (context, index) {
                    if (noticeImages[index].startsWith("http")) {
                      return Image.network(
                        noticeImages[index],
                        fit: BoxFit.cover,
                      );
                    } else {
                      return Image.asset(
                        noticeImages[index],
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }

  // Builds a generic section with a heading and grid items.
  Widget _buildSection(String heading, List<String> items) {
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
              Text(heading,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildServiceItem(items[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds a clickable grid item for a given service.
  Widget _buildServiceItem(String title) {
    final Map<String, String> imageMapping = {
      "Flood": 'userimage.png',
      "Fire": 'upperimage.png',
      "Drought": 'assets/images/drought.png',
      "Landslide": 'assets/images/landslide.png',
      "XYZ": 'assets/images/xyz.png',
      "Example Feature 1": 'assets/images/feature1.png',
      "Example Feature 2": 'assets/images/feature2.png',
      "Help": 'assets/images/help.png',
      "ABC": 'assets/images/abc.png',
    };

    return GestureDetector(
      onTap: () {
        if (title == "Flood/Rainfall") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FloodReportPage()));
        } else if (title == "Fire") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => WildfireReportPage()));
        } else if (title == "Drought") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DroughtReportPage()));
        } else if (title == "Landslide") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LandSlideReportPage()));
        } else if (title == "Sexual Abuse") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SexualabuseReportPage()));
        } else if (title == "Narcotics") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NarcoticsReportPage()));
        } else if (title == "Road Incidents") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RoadIncidentsReportPage()));
        } else if (title == "Animal Abuse") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AnimalabuseReportPage()));
        } else if (title == "Bribery") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BriberyReportPage()));
        } else if (title == "Food Safety") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FoodsafetyReportPage()));
        } else if (title == "Hygiene Issues") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HygieneissuesReportPage()));
               } else if (title == "Lost & Found") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LostAndFoundPage()));
        } else if (title == "Food Donation") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FoodDonationPage()));
        } else if (title == "Eco Hazard") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EcohazardReportPage()));
        } else if (title == "Alcohol") {
          
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AlcoholReportPage()));
        }
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 65) / 4,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Image.asset(
                imageMapping[title] ?? 'assets/images/default.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
      ),
    );
  }
}
