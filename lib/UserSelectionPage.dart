import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'package:neighborly/Authoritylogin.dart';
import 'package:neighborly/Userlogin.dart';
import 'package:neighborly/VolunteerLoginPage.dart';

void main() => runApp(MyApp());

/// Helper function to darken a color by a given [amount].
/// [amount] should be between 0.0 and 1.0.
Color darken(Color color, [double amount = .1]) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

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
    // Wrap the Scaffold with WillPopScope to intercept the back button press.
    return WillPopScope(
      onWillPop: () async {
        // Exits the app when back button is pressed.
        SystemNavigator.pop();
        return false; // Prevent further propagation of the back event.
      },
      child: Scaffold(
        body: Stack(
          children: [
            PageView(
              controller: _pageController,
              children: [
                // Public page.
                UserTypePage(
                  color: const Color.fromARGB(255, 24, 169, 236),
                  title: 'PUBLIC',
                  titleStyle: TextStyle(
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'proxima',
                    color: const Color.fromARGB(100, 155, 253, 255)
                        .withOpacity(0.7),
                  ),
                  description:
                      'Login as a regular user to explore the app. This is a longer description to illustrate how the text will be confined within the designated container.',
                  image: 'assets/back.png',
                  titlePosition: Offset(-15, 300),
                  imagePosition: Offset(0.05, 0.25),
                  imageWidth: 450,
                  imageHeight: 550,
                  descriptionPosition: Offset(0.2, 0.6),
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
                  color: const Color.fromARGB(255, 24, 169, 236),
                  title: 'VOLUNTEER',
                  titleStyle: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'proxima',
                    // Title text color same as PUBLIC.
                    color: const Color.fromARGB(100, 155, 253, 255)
                        .withOpacity(0.7),
                  ),
                  description:
                      'Login as a volunteer to contribute and assist. This longer description demonstrates how the text will be limited within the container, ensuring consistency across pages.',
                  descriptionStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                  image: 'assets/volunteer.png',
                 titlePosition: Offset(-15, 300),
                  imagePosition: Offset(0.05, 0.25),
                  imageWidth: 450,
                  imageHeight: 550,
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
                  color: const Color.fromARGB(255, 24, 169, 236),
                  title: 'AUTHORITY',
                  titleStyle: TextStyle(
                    fontSize: 110,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'proxima',
                    // Title text color same as PUBLIC.
                    color: const Color.fromARGB(100, 155, 253, 255)
                        .withOpacity(0.7),
                  ),
                  description:
                      'LOGIN AS AN ADMIN. This description is made longer to show how text confinement works uniformly across pages.',
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
            // Global page indicator placed at the bottom.
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
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

    // Build common widgets.
    final titleWidget = Positioned(
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
    );

    final imageWidget = Positioned(
      top: screenWidth * imagePosition.dy,
      left: screenWidth * imagePosition.dx,
      child: Image.asset(
        image,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover,
      ),
    );

    final descriptionWidget = Positioned(
      bottom: screenWidth * 0.5,
      left: screenWidth * 0.3,
      child: Container(
        padding: EdgeInsets.all(6),
        width: screenWidth * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          description,
          textAlign: TextAlign.left,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: descriptionStyle ??
              TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'proxima',
              ),
        ),
      ),
    );

    final buttonWidget = Positioned(
      bottom: screenHeight * (1 - buttonPosition.dy) - 140,
      left: (screenWidth - 250) / 2, // Center horizontally
      child: ElevatedButton(
        onPressed: onProceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );

    // For the volunteer page, reorder children so that the image overlaps the text.
    List<Widget> stackChildren;
    if (title == "VOLUNTEER") {
      stackChildren = [
        // Add the title first, then description and button,
        // and finally add the image so that it overlaps the volunteer text.
        titleWidget,
        descriptionWidget,
        buttonWidget,
        imageWidget,
      ];
    } else {
      // Default ordering for other pages.
      stackChildren = [
        titleWidget,
        imageWidget,
        descriptionWidget,
        buttonWidget,
      ];
    }

    return Container(
      // Apply a gradient background.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color,
            darken(color, 0.15), // Darker shade of the base color.
          ],
        ),
      ),
      child: Stack(
        children: stackChildren,
      ),
    );
  }
}
