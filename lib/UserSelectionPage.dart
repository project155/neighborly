import 'package:flutter/material.dart';
import 'package:neighborly/Authoritylogin.dart';
import 'package:neighborly/Userlogin.dart';
import 'package:neighborly/VolunteerLoginPage.dart';
import 'package:neighborly/loginuser.dart';
import 'package:neighborly/userhome.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserSelectionPage(),
    );
  }
}

class UserSelectionPage extends StatefulWidget {
  @override
  _UserSelectionPageState createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for user selection
          PageView(
            controller: _pageController,
            children: [
              UserTypePage(
                color: const Color.fromARGB(255, 170, 237, 255),
                title: 'USER',
                description: 'Login as a regular user to explore the app.',
                image: 'userimage.png',
                titlePosition: Offset(10, 400),
                imagePosition: Offset(0.25, 0.15),
                imageWidth: 350,
                imageHeight: 500,
                descriptionPosition: Offset(0.1, 0.6),
                buttonPosition: Offset(0.3, 0.75),
                onProceed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserLoginPage()),
                  );
                },
              ),
              UserTypePage(
                color: const Color.fromARGB(255, 174, 218, 255),
                title: 'VOLUNTEER',
                description: 'Login as a volunteer to contribute and assist.',
                image: 'volunteer.png',
                titlePosition: Offset(10, 220),
                imagePosition: Offset(0.2, 0.2),
                imageWidth: 180,
                imageHeight: 250,
                descriptionPosition: Offset(0.1, 0.6),
                buttonPosition: Offset(0.3, 0.75),
                onProceed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VolunteerLoginPage()),
                  );
                },
              ),
              UserTypePage(
                color: const Color.fromARGB(255, 255, 21, 21),
                title: 'AUTHORITY',
                description: 'Login as an admin to manage the platform.',
                image: 'assets/authority.png',
                titlePosition: Offset(5, 200),
                imagePosition: Offset(0.25, 0.25),
                imageWidth: 220,
                imageHeight: 320,
                descriptionPosition: Offset(0.1, 0.6),
                buttonPosition: Offset(0.3, 0.75),
                onProceed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuthorityLoginPage()),
                  );
                },
              ),
            ],
          ),
          // Dots indicator
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.07,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 20 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserTypePage extends StatelessWidget {
  final Color color;
  final String title;
  final String description;
  final String image;
  final Offset titlePosition;
  final Offset imagePosition;
  final double imageWidth;
  final double imageHeight;
  final Offset descriptionPosition;
  final Offset buttonPosition;
  final VoidCallback onProceed;

  UserTypePage({
    required this.color,
    required this.title,
    required this.description,
    required this.image,
    required this.titlePosition,
    required this.imagePosition,
    required this.imageWidth,
    required this.imageHeight,
    required this.descriptionPosition,
    required this.buttonPosition,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Stack(
        children: [
          // Rotated title with custom positioning
          Positioned(
            top: titlePosition.dy,
            left: titlePosition.dx,
            child: RotatedBox(
              quarterTurns: 3, // Rotates text 90 degrees to the left
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 90, // Larger font size
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
          // Image with separate positioning, width, and height
          Positioned(
            top:100,
            left: MediaQuery.of(context).size.width * imagePosition.dx,
            child: Image.asset(
              image,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
          // Description with separate positioning
          Positioned(
            top: 600,
            left: 100,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // Optional: Adjust width
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'proxima',
                ),
              ),
            ),
          ),
          // Proceed button with separate positioning
          Positioned(
            top: MediaQuery.of(context).size.height * buttonPosition.dy,
            left: MediaQuery.of(context).size.width * buttonPosition.dx,
            child: ElevatedButton(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'Proceed',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
