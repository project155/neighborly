import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neighborly/clodinary_upload.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Existing volunteer-related pages.
import 'package:neighborly/Drought.dart';
import 'package:neighborly/Landslide.dart';
import 'package:neighborly/authority.dart';
import 'package:neighborly/flood.dart';
import 'package:neighborly/loginuser.dart';
import 'package:neighborly/newreport.dart';
import 'package:neighborly/Userprofile.dart';
import 'package:neighborly/volunteerfood.dart';
import 'package:neighborly/wildfire.dart';
import 'package:neighborly/Notificationpage.dart';

// New report pages for additional public issues.
import 'package:neighborly/Sexualabuse.dart';
import 'package:neighborly/Narcotics.dart';
import 'package:neighborly/Roadincidents.dart';
import 'package:neighborly/Ecohazard.dart';
import 'package:neighborly/alcohol.dart';
import 'package:neighborly/Animalabuse.dart';
import 'package:neighborly/bribery.dart';
import 'package:neighborly/Foodsafety.dart';
import 'package:neighborly/Hygieneissues.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(VolunteerApp());
}

class VolunteerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Neighborly Volunteer",
      debugShowCheckedModeBanner: false,
      home: VolunteerHome(),
    );
  }
}

class VolunteerHome extends StatefulWidget {
  @override
  _VolunteerHomeState createState() => _VolunteerHomeState();
}

class _VolunteerHomeState extends State<VolunteerHome> {
  // Updated lists with corrected spellings and additional categories.
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
  final List<String> helpAndRecover = [
    "Food Donation"
  ];
  // Optional extra section for changing the notification banner.
  final List<String> notificationBanner = ["Change Banner"];

  // Notice images fetched from Firestore.
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
      print("Error fetching images from Firestore: $e");
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
      backgroundColor: Colors.grey[200],
      // Use a Stack to overlay the floating bottom navigation.
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildNoticeSection(),
                _buildSection("Report Disaster", disasterTypes),
                _buildSection("Report Public Issues", newCategoryItems),
                _buildSection("Help And Recover", helpAndRecover),
                // Optional: if you want to allow banner changes as a separate section.
                _buildSection("Notification Banner", notificationBanner),
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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateReportPage()));
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Neighborly Volunteer",
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 95, 156, 255),
            actions: [
              // Notifications icon now navigates to NotificationPage.
              IconButton(
                icon: Icon(Icons.notifications_active_rounded,
                    color: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NotificationPage()));
                },
              ),
            ],
            automaticallyImplyLeading: false,
          ),
        ),
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
              : (noticeImages.isEmpty
                  ? Center(child: Text("No Banner Available"))
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
                    )),
        ),
      ),
    );
  }

  // Builds a generic section with a heading and grid of items.
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
    // Updated mapping with keys that match the updated lists.
    final Map<String, String> imageMapping = {
      "Flood/Rainfall": 'assets/images/flood.png',
      "Fire": 'assets/images/fire.png',
      "Drought": 'assets/images/drought.png',
      "Landslide": 'assets/images/landslide.png',
      "Sexual Abuse": 'assets/images/sexual_abuse.png',
      "Narcotics": 'assets/images/narcotics.png',
      "Road Incidents": 'assets/images/road_incidents.png',
      "Eco Hazard": 'assets/images/eco_hazard.png',
      "Alcohol": 'assets/images/alcohol.png',
      "Animal Abuse": 'assets/images/animal_abuse.png',
      "Bribery": 'assets/images/bribery.png',
      "Food Safety": 'assets/images/food_safety.png',
      "Hygiene Issues": 'assets/images/hygiene.png',
      "Food Donation": 'assets/images/help.png',
      "Change Banner": 'assets/images/banner.png',
    };

    return GestureDetector(
      onTap: () {
        // Disaster types.
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
        }
        // Public issues.
        else if (title == "Sexual Abuse") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SexualabuseReportPage()));
        } else if (title == "Narcotics") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NarcoticsReportPage()));
        } else if (title == "Road Incidents") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RoadIncidentsReportPage()));
        } else if (title == "Eco Hazard") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EcohazardReportPage()));
        } else if (title == "Alcohol") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AlcoholReportPage()));
        } else if (title == "Animal Abuse") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AnimalabuseReportPage()));
        } else if (title == "Bribery") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BriberyReportPage()));
        } else if (title == "Food Safety") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FoodsafetyReportPage()));
        } else if (title == "Hygiene Issues") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HygieneissuesReportPage()));
        }
        // Help and recover.
        else if (title == "Food Donation") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FoodDonationVolunteerPage()));
        }
        // Notification banner update.
        else if (title == "Change Banner") {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotificationBannerPage()))
              .then((newUrl) {
            if (newUrl != null && newUrl is String) {
              setState(() {
                noticeImages.add(newUrl);
              });
            }
          });
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
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// Upload form for changing the notification banner.
// After a successful upload to Cloudinary, the secure URL is returned and saved to Firestore.
class ChangeNotificationBannerPage extends StatefulWidget {
  @override
  _ChangeNotificationBannerPageState createState() =>
      _ChangeNotificationBannerPageState();
}

class _ChangeNotificationBannerPageState
    extends State<ChangeNotificationBannerPage> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    // Upload the image to Cloudinary using your existing function.
    String? secureUrl = await getClodinaryUrl(_selectedImage!.path);
    if (secureUrl != null) {
      // Save the secureUrl in Firestore under the 'noticeImages' collection.
      await FirebaseFirestore.instance.collection('noticeImages').add({
        'imageUrl': secureUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context, secureUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Notification Banner"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Text("No image selected")),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Select Image"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text("Upload Image"),
            ),
          ],
        ),
      ),
    );
  }
}
