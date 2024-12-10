import 'dart:async';
import 'package:flutter/material.dart';

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
  final List<String> disasterTypes = ["Flood", "Fire", "Drought", "Landslide", "hello", "hi"];
  final List<String> publicIssues = [
    "Traffic Blockage",
    "Waste Disposal",
    "Potholes on Roads",
    "Street Lighting Issues", "hello", "hi",
  ];
  
  final List<String> xyzFeatures = [
    "Feature 1", "Feature 2", "Feature 3", "Feature 4"
  ];

  // To track the current page in PageView
  PageController _pageController = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Timer to automatically change the page every 3 seconds
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        currentIndex++;
        if (currentIndex >= 3) {  // Adjust this to your number of images
          currentIndex = 0;
        }
        _pageController.animateToPage(currentIndex, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Neighborly", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: SingleChildScrollView( // Body content is scrollable
        child: Padding(
          padding: EdgeInsets.only(bottom: 100),  // Add padding to prevent overflow due to the fixed bottom bar
          child: Column(
            children: [
              // Notice board above the "Report Disaster" section
              _buildNoticeBoard(),
              // First Section: Report Disaster with a white container
              _buildSection("Report Disaster", disasterTypes),
              // Second Section: Public Issues with a white container
              _buildSection("Public Issues", publicIssues),
              // New Section: XYZ Features
              _buildSection("XYZ Features", xyzFeatures), // New section added
            ],
          ),
        ),
      ),
      // Keep the original fixed bottom container (bottom sheet)
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width * 0.9,  // Adjust width to 80% of screen width
        height: 70,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 188, 188, 188), // Background color of the container
          borderRadius: BorderRadius.all(Radius.circular(35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(0, -4), // Creates a lift effect
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
                  // Handle Home navigation
                },
                highlightColor: Colors.transparent, // Remove highlight color
                splashColor: Colors.transparent,    // Remove splash color effect
              ),
              IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                onPressed: () {
                  // Handle Profile navigation
                },
                highlightColor: Colors.transparent, // Remove highlight color
                splashColor: Colors.transparent,    // Remove splash color effect
              ),
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () {
                  // Handle Camera navigation
                },
                highlightColor: Colors.transparent, // Remove highlight color
                splashColor: Colors.transparent,    // Remove splash color effect
              ),
              IconButton(
                icon: Icon(Icons.map, color: Colors.white),
                onPressed: () {
                  // Handle Map navigation
                },
                highlightColor: Colors.transparent, // Remove highlight color
                splashColor: Colors.transparent,    // Remove splash color effect
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create the sliding Notice Board section
  Widget _buildNoticeBoard() {
    return Container(
      height: 250, // Adjust height for the notice board
      margin: EdgeInsets.symmetric(vertical: 30),
      child: PageView.builder(
        controller: _pageController,
        itemCount: 3, // Change this according to the number of images you have
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage("https://via.placeholder.com/400x200.png?text=Notice+$index"),  // Replace with your image URLs
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Notice $index',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to create sections with icons and text inside a white container
  Widget _buildSection(String heading, List<String> items) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 15),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,  // White background for each section
          borderRadius: BorderRadius.circular(20),  // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),  // Slight shadow
              blurRadius: 4,
              offset: Offset(0, 4),  // Shadow position
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
              // Display the icons and text in white boxes
              Wrap(
                spacing: 10,
                runSpacing: 10,
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

  // Helper method to create a service item with icon, text, white box, and slight shadow
  Widget _buildServiceItem(String title) {
    return Container(
      width: (MediaQuery.of(context).size.width - 15) / 5, // Adjust width to fit 4 items per row
      height: 130,  // Adjust height for better spacing
      decoration: BoxDecoration(
        color: Colors.white,  // White background
        borderRadius: BorderRadius.circular(30),  // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),  // Slight shadow
            blurRadius: 4,
            offset: Offset(0, 0),  // Shadow position
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 40, color: Colors.teal),
          SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
