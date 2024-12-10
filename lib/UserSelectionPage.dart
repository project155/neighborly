import 'package:flutter/material.dart';
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
                image: 'assets/user.png',
                titlePosition: Offset(10, 400),
                onProceed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginUser()),
                  );
                },
              ),
              UserTypePage(
                color: const Color.fromARGB(255, 174, 218, 255),
                title: 'VOLUNTEER',
                description: 'Login as a volunteer to contribute and assist.',
                image: 'assets/volunteer.png',
                titlePosition: Offset(10, 220),
                onProceed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VolunteerLoginPage()),
                  );
                },
              ),
              UserTypePage(
                color: Colors.teal,
                title: 'AUTHORITY',
                description: 'Login as an admin to manage the platform.',
                image: 'assets/authority.png',
                titlePosition: Offset(5, 200),
                onProceed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>Userhome()),
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
  final VoidCallback onProceed;

  UserTypePage({
    required this.color,
    required this.title,
    required this.description,
    required this.image,
    required this.titlePosition,
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
          // Image on top of text
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                image,
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.height * 0.4,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Description and button below
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// // LoginUser Page
// class LoginUser extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Login'),
//       ),
//       body: Center(
//         child: Text(
//           'Welcome to User Login Page',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }
