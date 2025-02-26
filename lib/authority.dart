import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighborly/AuthoritySendnotification.dart';
import 'package:neighborly/Notificationpage.dart';
import 'package:neighborly/SOSpage.dart';
import 'package:neighborly/Userlogin.dart';

// Dummy pages for Authority actions

class AuthorityHome extends StatefulWidget {
  @override
  _AuthorityHomeState createState() => _AuthorityHomeState();
}

class _AuthorityHomeState extends State<AuthorityHome> {
  List<String> noticeImages = [];
  bool _isLoading = true;
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchNoticeImages().then((_) {
      _startTimer();
    });
  }

  /// Fetch notice image URLs from Firestore collection 'noticeImages'
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
      print("Error fetching notice images: $e");
      setState(() {
        noticeImages = [];
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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
    _timer?.cancel();
    super.dispose();
  }

  /// Builds the notice slider section with rounded corners.
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
              : PageView.builder(
                  controller: _pageController,
                  itemCount: noticeImages.length,
                  itemBuilder: (context, index) {
                    String imageUrl = noticeImages[index];
                    if (imageUrl.startsWith("http")) {
                      return Image.network(imageUrl, fit: BoxFit.cover);
                    } else {
                      return Image.asset(imageUrl, fit: BoxFit.cover);
                    }
                  },
                ),
        ),
      ),
    );
  }

  /// Builds the Authority Actions section with grid items.
  Widget _buildAuthorityActionsSection() {
    // Define authority actions
    final List<Map<String, dynamic>> actions = [
      {
        "title": "Urgent SOS",
        "icon": Icons.warning,
        "page": UserLoginPage(),
      },
      {
        "title": "Categorized Reports",
        "icon": Icons.list,
        "page": UserLoginPage(),
      },
      {
        "title": "Send Alerts",
        "icon": Icons.notifications,
        "page": SendNotificationPage(),
      },
      {
        "title": "Generate Reports",
        "icon": Icons.analytics,
        "page": UserLoginPage(),
      },
    ];

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
              Text("Authority Actions",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // two items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return _buildActionItem(
                    title: action["title"],
                    icon: action["icon"],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => action["page"]),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a clickable grid item for an authority action.
  Widget _buildActionItem({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 65) / 2,
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
              child: Icon(icon, size: 30, color: Colors.blue),
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

  /// Builds the floating bottom navigation bar.
  Widget _buildBottomNavigationBar() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 95, 156, 255),
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
                // Already on Authority Home
                Navigator.push(context, MaterialPageRoute(builder: (context) => AuthorityHome()));
              },
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginPage()));
              },
            ),
            IconButton(
              icon: Icon(Icons.post_add_rounded, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginPage()));
              },
            ),
            IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginPage()));
              },
            ),
            IconButton(
              icon: Icon(Icons.sos_sharp, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar with rounded bottom corners.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            title: Text("Authority Dashboard", style: TextStyle(color: Colors.white)),
            backgroundColor: Color.fromARGB(255, 95, 156, 255),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_active_rounded, color: Colors.white),
                onPressed: () {
                  // For example, navigate to notifications page
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                },
              ),
            ],
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildNoticeSection(),
                _buildAuthorityActionsSection(),
              ],
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthorityHome(),
  ));
}
