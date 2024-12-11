import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neighborly/loginuser.dart';

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
  _userhomeState createState() => _userhomeState();
}

class _userhomeState extends State<Userhome> {
  final List<String> disasterTypes = ["Flood", "Fire", "Drought", "Landslide"];
  final List<String> newCategoryItems = ["XYZ", "Example Feature 1", "Example Feature 2", "Help"];
  final List<String> noticeImages = [
    'assets/notice1.jpg', // Replace with your actual image paths
    'assets/notice2.jpg',
    'assets/notice3.jpg',
  ];
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 3), (timer) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Neighborly", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 54, 178, 255),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Notice section (sliding images)
              _buildNoticeSection(),
              // First Section: Report Disaster with a white container
              _buildSection("Report Disaster", disasterTypes),
              // Second Section: New Category (XYZ and Features)
              _buildSection("Report Disaster XYZ", newCategoryItems),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 70,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 188, 188, 188),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage()));
                },
              ),
              IconButton(
                icon: Icon(Icons.map, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MapPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create the sliding notice section
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
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: PageView.builder(
          controller: _pageController,
          itemCount: noticeImages.length,
          itemBuilder: (context, index) {
            return Image.asset(
              noticeImages[index], // Load images from assets
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  // Helper method to create sections with clickable disaster types
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
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
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
              // Use Row to display items in a single row with 4 buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items.map((item) {
                  return _buildServiceItem(item);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a clickable service item
  Widget _buildServiceItem(String title) {
    return GestureDetector(
      onTap: () {
        // Navigate to the respective page when the item is clicked
        if (title == "Flood" || title == "Fire" || title == "Drought" || title == "Landslide") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser()));
        } else if (title == "XYZ") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => XYZPage()));
        } else if (title == "Example Feature 1") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleFeaturePage1()));
        } else if (title == "Example Feature 2") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleFeaturePage2()));
        }  else if (title == "Help") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser()));
        }
        
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 65) / 4,  // Adjust width for 4 buttons
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
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Icon(Icons.warning, size: 55, color: const Color.fromARGB(255, 255, 64, 64)),
            ),
            SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}

// Define the new pages for navigation
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(child: Text('This is the Home Page')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile Page')),
      body: Center(child: Text('This is the Profile Page')),
    );
  }
}

class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Camera Page')),
      body: Center(child: Text('This is the Camera Page')),
    );
  }
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map Page')),
      body: Center(child: Text('This is the Map Page')),
    );
  }
}

class XYZPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('XYZ Page')),
      body: Center(child: Text('This is the XYZ Page')),
    );
  }
}

class ExampleFeaturePage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example Feature 1')),
      body: Center(child: Text('This is Example Feature 1')),
    );
  }
}

class ExampleFeaturePage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example Feature 2')),
      body: Center(child: Text('This is Example Feature 2')),
    );
  }
}
