import 'package:flutter/material.dart';
import 'package:neighborly/Authoritylogin.dart';
import 'package:neighborly/Userlogin.dart';
import 'package:neighborly/VolunteerLoginPage.dart';

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
  final int totalPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack to overlay the PageView and global page indicator.
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              // User page.
              UserTypePage(
                color: const Color.fromARGB(255, 0, 189, 202),
                title: 'USER',
                titleStyle: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white.withOpacity(0.8),
                ),
                description: 'Login as a regular user to explore the app.',
                image: 'assets/userimage.png',
                titlePosition: Offset(6, 400),
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
              // Volunteer page.
              UserTypePage(
                color: const Color.fromARGB(255, 174, 218, 255),
                title: 'VOLUNTEER',
                titleStyle: TextStyle(
                  fontSize: 110,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white.withOpacity(0.8),
                ),
                description: 'Login as a volunteer to contribute and assist.',
                descriptionStyle: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
                image: 'assets/volunteer.png',
                titlePosition: Offset(6, 220),
                imagePosition: Offset(0.2, 0.2),
                imageWidth: 180,
                imageHeight: 250,
                descriptionPosition: Offset(0.1, 0.6),
                buttonPosition: Offset(0.3, 0.75),
                onProceed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VolunteerLoginPage()),
                  );
                },
              ),
              // Authority page.
              UserTypePage(
                color: const Color.fromARGB(255, 255, 21, 21),
                title: 'AUTHORITY',
                titleStyle: TextStyle(
                  fontSize: 110,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white.withOpacity(0.8),
                ),
                description: 'Login as an admin to manage the platformfefeeffefefefefefefefefef.',
                image: 'assets/authority.png',
                titlePosition: Offset(6, 200),
                imagePosition: Offset(0.25, 0.25),
                imageWidth: 220,
                imageHeight: 320,
                descriptionPosition: Offset(0.21, 0.6),
                buttonPosition: Offset(0.3, 0.75),
                onProceed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthorityLoginPage()),
                  );
                },
              ),
            ],
          ),
          // Global page indicator placed at the bottom (above the individual page's proceed button).
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.03,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  height: 6,
                  width: _currentPage == index ? 25 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
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
  // These positions are fractions relative to the screen.
  final Offset descriptionPosition;
  final Offset buttonPosition;
  final VoidCallback onProceed;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;

  const UserTypePage({
    Key? key,
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
    this.titleStyle,
    this.descriptionStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: color,
      child: Stack(
        children: [
          // Title positioned at its given top coordinates.
          Positioned(
            top: titlePosition.dy,
            left: titlePosition.dx,
            child: RotatedBox(
              quarterTurns: 3,
              child: Text(
                title,
                style: titleStyle ??
                    TextStyle(
                      fontSize: 90,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'proxima',
                      color: const Color.fromARGB(255, 74, 255, 38).withOpacity(0.4),
                    ),
              ),
            ),
          ),
          // Image positioned relative to the screen width.
          Positioned(
            top: 100,
            left: screenWidth * imagePosition.dx,
            child: Image.asset(
              image,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
          // Description positioned using the provided bottom fraction.
          Positioned(
            bottom: screenHeight * (1 - descriptionPosition.dy),
            left: screenWidth * descriptionPosition.dx,
            child: SizedBox(
              width: screenWidth * 0.8,
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: descriptionStyle ??
                    TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'proxima',
                    ),
              ),
            ),
          ),
          // Proceed button positioned using the provided bottom fraction.
          Positioned(
            bottom: screenHeight * (1 - buttonPosition.dy)-140,
            left: (screenWidth - 250) / 2, // Center horizontally

            child: ElevatedButton(
              onPressed: onProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 18),
                shape: StadiumBorder(),
                elevation: 8,
                shadowColor: Colors.black26,
              ),
              child: Text(
                'Proceed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'proxima',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
