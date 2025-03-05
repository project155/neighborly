import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:neighborly/Animalabuse.dart';
import 'package:neighborly/ChildAbuse.dart';
import 'package:neighborly/Drought.dart';
import 'package:neighborly/Ecohazard.dart';
import 'package:neighborly/Fooddonation.dart';
import 'package:neighborly/Foodsafety.dart';
import 'package:neighborly/Hygieneissues.dart';
import 'package:neighborly/Infrastructureissues.dart';
import 'package:neighborly/Landslide.dart';
import 'package:neighborly/Narcotics.dart';
import 'package:neighborly/Notificationpage.dart';
import 'package:neighborly/Roadincidents.dart';
import 'package:neighborly/SOSpage.dart';
import 'package:neighborly/Theft.dart';
import 'package:neighborly/Transportation.dart';
import 'package:neighborly/alcohol.dart';
import 'package:neighborly/authority.dart';
import 'package:neighborly/bloodsignup.dart';
import 'package:neighborly/bribery.dart';
import 'package:neighborly/crimeanalytics.dart';
import 'package:neighborly/disasteranalytics.dart';
import 'package:neighborly/flood.dart';
import 'package:neighborly/loginuser.dart';
import 'package:neighborly/newreport.dart';
import 'package:neighborly/Sexualabuse.dart';
import 'package:neighborly/Userprofile.dart';
import 'package:neighborly/publicissuesanalytics.dart';
import 'package:neighborly/wildfire.dart';
import 'package:neighborly/Lostandfound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    "Hygiene Issues",
    "Infrastructure Issues",
    "Transportation",
    "Theft",
    "Child Abuse"
  ];
  final List<String> helpandrecover = [
    "Food Donation",
    "Lost & Found",
    "Blood Donation",
  ];

  List<String> noticeImages = [];
  bool _isLoading = true;

  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _askPermissions();
    _pageController = PageController();
    _fetchNoticeImages().then((_) {
      _startTimer();
    });
  }

  Future<void> _askPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasAsked = prefs.getBool('hasAskedPermissions') ?? false;
    if (!hasAsked) {
      await [Permission.location, Permission.camera].request();
      await prefs.setBool('hasAskedPermissions', true);
    }
  }

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
            title: Text("reportify", style: TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 58, 133, 255),
            actions: [
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
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateReportPage(attachment: pickedFile),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.sos_sharp, color: Colors.white),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => SosPage()));
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

  Widget _buildSection(String heading, List<String> items) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
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
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
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

  Widget _buildServiceItem(String title) {
    final Map<String, IconData> iconMapping = {
      "Flood/Rainfall": FontAwesomeIcons.houseFloodWater,
      "Fire": FontAwesomeIcons.fire,
      "Landslide": FontAwesomeIcons.mountain,
      "Drought": FontAwesomeIcons.sunPlantWilt,
      "Sexual Abuse": FontAwesomeIcons.personHarassing,
      "Narcotics": FontAwesomeIcons.syringe,
      "Road Incidents": FontAwesomeIcons.roadCircleExclamation,
      "Eco Hazard": Icons.eco,
      "Alcohol": FontAwesomeIcons.wineGlass,
      "Animal Abuse": FontAwesomeIcons.paw,
      "Bribery": FontAwesomeIcons.moneyBill1Wave,
      "Food Safety": FontAwesomeIcons.cutlery,
      "Hygiene Issues": FontAwesomeIcons.broom,
      "Lost & Found": FontAwesomeIcons.search,
      "Food Donation": Icons.volunteer_activism,
      "Infrastructure Issues": FontAwesomeIcons.buildingCircleExclamation,
      "Transportation": FontAwesomeIcons.bus,
      "Theft": FontAwesomeIcons.peopleRobbery,
      "Child Abuse": FontAwesomeIcons.childReaching,
      "Blood Donation": Icons.bloodtype,
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
        } else if (title == "Infrastructure Issues") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InfrastructureReportPage()));
        } else if (title == "Transportation") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TransportationReportPage()));
        } else if (title == "Theft") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TheftReportPage()));
        } else if (title == "Child Abuse") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChildAbuseReportPage()));
        } else if (title == "Alcohol") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AlcoholReportPage()));
        } else if (title == "Blood Donation") {
          // Use showGeneralDialog to create a slow transition popup.
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "BloodDonationOptions",
            transitionDuration: Duration(milliseconds: 250),
            pageBuilder: (context, animation, secondaryAnimation) {
              // Center the dialog.
              return Center(child: BloodDonationPopup());
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
          );
        }
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 65) / 4,
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
              child: Icon(
                iconMapping[title] ?? Icons.help,
                size: 30,
                color: Colors.blue,
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
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom popup widget for blood donation options.
class BloodDonationPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Blood Donation Options",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          // Two options in a horizontal row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOption(
                context,
                label: "Request Blood",
                icon: Icons.bloodtype,
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RequestBloodPage()),
                  );
                },
              ),
              _buildOption(
                context,
                label: "Donation Sign Up",
                icon: Icons.person_add_alt_rounded,
                color: Colors.green,
                onTap: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BloodSignupPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Dummy placeholder for RequestBloodPage.
// Replace with your actual implementation.
class RequestBloodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Blood"),
      ),
      body: Center(
        child: Text("Request Blood Page Content"),
      ),
    );
  }
}

// Dummy placeholder for BloodSignupPage.
// Replace with your actual implementation.
class BloodSignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Donation Sign Up"),
      ),
      body: Center(
        child: Text("Blood Donation Sign Up Page Content"),
      ),
    );
  }
}
