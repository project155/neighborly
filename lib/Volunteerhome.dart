import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:http/http.dart' as http;
import 'package:neighborly/Drought.dart';
import 'package:neighborly/Landslide.dart';
import 'package:neighborly/authority.dart';
import 'package:neighborly/flood.dart';
import 'package:neighborly/loginuser.dart';
import 'package:neighborly/newreport.dart';
import 'package:neighborly/sexualissues.dart';
import 'package:neighborly/Userprofile.dart';
import 'package:neighborly/wildfire.dart';

/// Cloudinary upload function using the cloudinary package.
Future<String?> getClodinaryUrl(String image) async {
  final cloudinary = Cloudinary.signedConfig(
    cloudName: 'dkwnu8zei',
    apiKey: '298339343829723',
    apiSecret: 'T9q3BURXE2-Rj6Uv4Dk9bSzd7rY',
  );

  final response = await cloudinary.upload(
    file: image,
    resourceType: CloudinaryResourceType.image,
  );
  return response.secureUrl;
}

void main() => runApp(VolunteerApp());

class VolunteerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Volunteerhome(),
    );
  }
}

class Volunteerhome extends StatefulWidget {
  @override
  _VolunteerhomeState createState() => _VolunteerhomeState();
}

class _VolunteerhomeState extends State<Volunteerhome> {
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
    "Eco hazard",
    "Alchohol",
    "Animal Abuse",
    "bribery",
    "Food Safety",
    "Hygiene Issues"
  ];
  final List<String> helpandrecover = [
    "XYZ",
    "Example Feature 1",
    "Example Feature 2"
  ];
  // Category for Notification Banner.
  final List<String> notificationBanner = ["Change Banner"];

  // This list will hold the notice image URLs fetched from Cloudinary.
  List<String> noticeImages = [];

  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Fetch images uploaded by volunteers from Cloudinary.
    _fetchNoticeImages().then((_) {
      _startTimer();
    });
  }

  /// Fetch notice image URLs from Cloudinary.
  Future<void> _fetchNoticeImages() async {
    final String cloudName = 'dkwnu8zei';
    final String apiKey = '298339343829723';
    final String apiSecret = 'T9q3BURXE2-Rj6Uv4Dk9bSzd7rY';
    final String url = 'https://api.cloudinary.com/v1_1/$cloudName/resources/image';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': basicAuth,
      });
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> resources = data['resources'];
        setState(() {
          noticeImages =
              resources.map((r) => r['secure_url'] as String).toList();
          // Fallback to local assets if no images are returned.
          if (noticeImages.isEmpty) {
            noticeImages = [
              'assets/notice1.jpg',
              'assets/notice3.jpg',
            ];
          }
        });
      } else {
        setState(() {
          noticeImages = [
            'assets/notice1.jpg',
            'assets/notice3.jpg',
          ];
        });
      }
    } catch (e) {
      print("Error fetching images: $e");
      setState(() {
        noticeImages = [
          'assets/notice1.jpg',
          'assets/notice3.jpg',
        ];
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
            title: Text("Neighborly Volunteer", style: TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromARGB(255, 95, 156, 255),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(Icons.notifications_active_rounded),
              ),
            ],
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              _buildNoticeSection(),
              _buildSection("Report Disaster", disasterTypes),
              _buildSection("Report public issues", newCategoryItems),
              _buildSection("Help And Recover", helpandrecover),
              _buildSection("Notification Banner", notificationBanner),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 95, 156, 255),
          borderRadius: BorderRadius.all(Radius.circular(35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, -4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser()));
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfile()));
                },
              ),
              IconButton(
                icon: Icon(Icons.post_add_rounded, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateReportPage()));
                },
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser()));
                },
              ),
              IconButton(
                icon: Icon(Icons.sos_sharp, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the notice slider section.
  Widget _buildNoticeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: noticeImages.isEmpty
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
    );
  }

  // Builds a generic section with a heading and a grid of items.
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
              Text(heading, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
      "Flood/Rainfall": 'assets/images/flood.png',
      "Fire": 'assets/images/fire.png',
      "Drought": 'assets/images/drought.png',
      "Landslide": 'assets/images/landslide.png',
      "Sexual Abuse": 'assets/images/sexual_abuse.png',
      "Narcotics": 'assets/images/narcotics.png',
      "Road Incidents": 'assets/images/road_incidents.png',
      "Eco hazard": 'assets/images/eco_hazard.png',
      "Alchohol": 'assets/images/alchohol.png',
      "Animal Abuse": 'assets/images/animal_abuse.png',
      "bribery": 'assets/images/bribery.png',
      "Food Safety": 'assets/images/food_safety.png',
      "Hygiene Issues": 'assets/images/hygiene.png',
      "XYZ": 'assets/images/xyz.png',
      "Example Feature 1": 'assets/images/feature1.png',
      "Example Feature 2": 'assets/images/feature2.png',
      "Help And Recover": 'assets/images/help.png',
      "Change Banner": 'assets/images/banner.png',
    };

    return GestureDetector(
      onTap: () {
        if (title == "Flood/Rainfall") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FloodReportPage()));
        } else if (title == "Fire") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => WildfireReportPage()));
        } else if (title == "Drought") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DroughtReportPage()));
        } else if (title == "Landslide") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LandSlideReportPage()));
        } else if (title == "XYZ") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => XYZPage()));
        } else if (title == "Example Feature 1") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleFeaturePage1()));
        } else if (title == "Example Feature 2") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleFeaturePage2()));
        } else if (title == "Help And Recover") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AuthorityPage()));
        } else if (title == "Change Banner") {
          // Navigate to the upload form. When upload is successful,
          // the secure URL is returned and added to the noticeImages list.
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChangeNotificationBannerPage()))
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy pages for demonstration (customize as needed).

class FloodReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flood Report')),
      body: Center(child: Text('Flood report page content here')),
    );
  }
}

class WildfireReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wildfire Report')),
      body: Center(child: Text('Wildfire report page content here')),
    );
  }
}

class DroughtReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drought Report')),
      body: Center(child: Text('Drought report page content here')),
    );
  }
}

class LandSlideReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Landslide Report')),
      body: Center(child: Text('Landslide report page content here')),
    );
  }
}

class XYZPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('XYZ Report')),
      body: Center(child: Text('XYZ report page content here')),
    );
  }
}

class ExampleFeaturePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature 1')),
      body: Center(child: Text('Feature 1 content here')),
    );
  }
}

class ExampleFeaturePage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feature 2')),
      body: Center(child: Text('Feature 2 content here')),
    );
  }
}

class AuthorityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Authority')),
      body: Center(child: Text('Authority page content here')),
    );
  }
}

class LoginUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login User')),
      body: Center(child: Text('Login user page content here')),
    );
  }
}

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Center(child: Text('User profile page content here')),
    );
  }
}

class CreateReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Report')),
      body: Center(child: Text('Create report page content here')),
    );
  }
}

// Upload form for changing the notification banner.
// After a successful upload to Cloudinary, the secure URL is returned.
class ChangeNotificationBannerPage extends StatefulWidget {
  @override
  _ChangeNotificationBannerPageState createState() => _ChangeNotificationBannerPageState();
}

class _ChangeNotificationBannerPageState extends State<ChangeNotificationBannerPage> {
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

    // Use the provided Cloudinary upload function.
    String? secureUrl = await getClodinaryUrl(_selectedImage!.path);
    if (secureUrl != null) {
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
