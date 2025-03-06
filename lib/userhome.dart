import 'dart:async';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
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
import 'package:flutter_svg/flutter_svg.dart';

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
  String _searchQuery = ""; // For filtering search

  // For animated search suggestions.
  List<String> _searchSuggestions = [
    "Search Flood/Rainfall",
    "Search Fire",
    "Search Landslide",
    "Search Drought"
  ];
  int _currentSuggestionIndex = 0;
  Timer? _suggestionTimer;

  // A FocusNode to hide the animated hint when the field is focused.
  final FocusNode _focusNode = FocusNode();

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
    _startSuggestionTimer();
    _focusNode.addListener(() {
      setState(() {}); // Update to hide/show animated hint.
    });
  }

  void _startSuggestionTimer() {
    _suggestionTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _currentSuggestionIndex =
            (_currentSuggestionIndex + 1) % _searchSuggestions.length;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _suggestionTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
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
          .limit(3)
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

  // Updated search bar widget with a stacked AnimatedSwitcher overlay.
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color:
                  const Color.fromARGB(255, 109, 109, 109).withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextField(
              focusNode: _focusNode,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "", // Leave empty since we'll show our custom hint.
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            // Show the animated hint only when the TextField is not focused and empty.
            if (!_focusNode.hasFocus && _searchQuery.isEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.only(left: 00), // adjust to avoid prefix icon
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 100),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        _searchSuggestions[_currentSuggestionIndex],
                        key: ValueKey<String>(
                            _searchSuggestions[_currentSuggestionIndex]),
                        style: TextStyle(
                          fontFamily: 'proxima', // Replace with your font
                          fontSize: 16,
                          color: Colors.grey,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
            backgroundColor: const Color.fromARGB(233, 0, 0, 0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 115, 168),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: Row(
              children: [
                Transform.translate(
                  offset: Offset(-6, 0),
                  child: SvgPicture.asset(
                    'assets/icons/icon2.svg',
                    height: 60,
                    width: 50,
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-13, 0),
                  child: Text(
                    "reportify",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'proxima',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-10, 0),
                  child: Text(
                    "Public",
                    style: TextStyle(
                      color: Color.fromARGB(179, 223, 223, 223),
                      fontSize: 14,
                      fontFamily: 'proxima',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
              ),
            ],
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 240, 242, 255),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                // Insert search bar between AppBar and notice section.
                _buildSearchBar(),
                _buildNoticeSection(),
                _buildSection("Report Disaster", disasterTypes),
                _buildSection("Report public issues", newCategoryItems),
                _buildSection("Help And Recover", helpandrecover),
              ],
            ),
          ),
          // Bottom navigation bar with the original SOS button order.
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(238, 9, 59, 83),
                    Color.fromARGB(255, 0, 115, 168),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home button
                  IconButton(
                    icon:
                        Icon(FluentIcons.home_20_regular, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginUser()),
                      );
                    },
                  ),
                  // Person button
                  IconButton(
                    icon: Icon(FluentIcons.person_20_regular,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserProfile()),
                      );
                    },
                  ),
                  // Copy Add button
                  IconButton(
                    icon: Icon(FluentIcons.copy_add_20_regular,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateReportPage()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Transform.translate(
                      offset: Offset(3, -3),
                      child: SvgPicture.asset(
                        'assets/icons/sirenn.svg',
                        color: Colors.white,
                        width: 29,
                        height: 29,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SosPage()),
                      );
                    },
                  ),
                  // Camera button
                  IconButton(
                    icon: Icon(FluentIcons.camera_20_regular,
                        color: Colors.white),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CreateReportPage(attachment: pickedFile),
                          ),
                        );
                      }
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
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
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

  // Updated _buildSection that filters service items based on the search query.
  Widget _buildSection(String heading, List<String> items) {
    List<String> filteredItems = _searchQuery.isEmpty
        ? items
        : items
            .where((item) =>
                item.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    if (filteredItems.isEmpty) {
      return Container();
    }

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
              Text(
                heading,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'proxima',
                ),
              ),
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
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return _buildServiceItem(filteredItems[index]);
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
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "BloodDonationOptions",
            transitionDuration: Duration(milliseconds: 250),
            pageBuilder: (context, animation, secondaryAnimation) {
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
                size: 25,
                color: Color.fromARGB(255, 57, 57, 57),
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'proxima',
                fontWeight: FontWeight.w100,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOption(
                context,
                label: "Request Blood",
                icon: Icons.bloodtype,
                color: Colors.red,
                onTap: () {
                  Navigator.of(context).pop();
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
                  Navigator.of(context).pop();
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
              color: Color.fromARGB(255, 9, 60, 83),
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
