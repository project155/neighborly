import 'dart:async';
import 'package:flutter/material.dart';
import 'package:neighborly/loginuser.dart';
import 'package:neighborly/sexualissues.dart';

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
  final List<String> newCategoryItems = ["XYZ", "Example Feature 1", "Example Feature 2", "Help", "ABC"];
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
        automaticallyImplyLeading: false,
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
              _buildSection("Report public issues", newCategoryItems),
              _buildSection("Report public issue", newCategoryItems),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width * double.infinity,
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser()));
                },
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser()));
                },
              ),
              IconButton(
                icon: Icon(Icons.sos_outlined, color: Colors.white),
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
              // Use GridView to display items in 4 columns
              GridView.builder(
                shrinkWrap: true, // Prevent GridView from taking up unnecessary space
                physics: NeverScrollableScrollPhysics(), // Disable scrolling in GridView
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 items per row
                  crossAxisSpacing: 10, // Spacing between columns
                  mainAxisSpacing: 10, // Spacing between rows
                  childAspectRatio: 1, // Ensure the items are square-shaped
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

  // Helper method to create a clickable service item with PNG images
  Widget _buildServiceItem(String title) {
    // Define a mapping of titles to image paths
    final Map<String, String> imageMapping = {
      "Flood": 'userimage.png',
      "Fire": 'upperimage.png',
      "Drought": 'assets/images/drought.png',
      "Landslide": 'assets/images/landslide.png',
      "XYZ": 'assets/images/xyz.png',
      "Example Feature 1": 'assets/images/feature1.png',
      "Example Feature 2": 'assets/images/feature2.png',
      "Help": 'assets/images/help.png',
      "ABC": 'assets/images/abc.png', // Add image for ABC category
    };

    return GestureDetector(
      onTap: () {
        // Navigate to the respective page when the item is clicked
        if (title == "Flood") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FloodPage()));
        } else if (title == "Fire") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FirePage()));
        } else if (title == "Drought") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DroughtPage()));
        } else if (title == "Landslide") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SexualIssuesReportsPage()));
        } else if (title == "XYZ") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => XYZPage()));
        } else if (title == "Example Feature 1") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleFeaturePage1()));
        } else if (title == "Example Feature 2") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ExampleFeaturePage2()));
        } else if (title == "Help") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
        } else if (title == "ABC") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ABCPage()));
        }
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 65) / 4, // Adjust width for 4 buttons
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
              child: Image.asset(
                imageMapping[title] ?? 'assets/images/default.png', // Use the mapped image or a default image
                fit: BoxFit.contain,
              ),
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

// Example pages (you can customize these)
class FloodPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flood Report')),
      body: Center(child: Text('Flood report page content here')),
    );
  }
}

class FirePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fire Report')),
      body: Center(child: Text('Fire report page content here')),
    );
  }
}

class DroughtPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drought Report')),
      body: Center(child: Text('Drought report page content here')),
    );
  }
}

class LandslidePage extends StatelessWidget {
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

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help')),
      body: Center(child: Text('Help page content here')),
    );
  }
}

class ABCPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ABC Report')),
      body: Center(child: Text('ABC report page content here')),
    );
  }
}
