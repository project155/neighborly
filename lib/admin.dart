import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // For iOS-style back button.
import 'package:flutter_svg/flutter_svg.dart'; // For SVG support.
import 'package:neighborly/UserSelectionPage.dart';
import 'package:neighborly/crimeanalytics.dart';
import 'package:neighborly/disasteranalytics.dart';
import 'package:neighborly/manageAuthorities.dart';
import 'package:neighborly/manageVolunteer.dart';
import 'package:neighborly/publicissuesanalytics.dart';
import 'package:neighborly/viewfeedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Page to view all users from the 'users' collection.
class ViewUsersPage extends StatefulWidget {
  @override
  _ViewUsersPageState createState() => _ViewUsersPageState();
}

class _ViewUsersPageState extends State<ViewUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with gradient background, rounded corners, and iOS back button.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Color.fromARGB(233, 0, 0, 0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: Text(
              "View Users",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No users found."));
          
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var userData = users[index].data() as Map<String, dynamic>;
              String name = userData['name'] ?? "No Name";
              String email = userData['email'] ?? "No Email";
              String phone = userData['phone'] ?? "No Phone";
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email: $email"),
                    Text("Phone: $phone"),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}

/// Page to view all volunteers from the 'volunteers' collection.
class ViewVolunteersPage extends StatefulWidget {
  @override
  _ViewVolunteersPageState createState() => _ViewVolunteersPageState();
}

class _ViewVolunteersPageState extends State<ViewVolunteersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with gradient background, rounded corners, and iOS back button.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Color.fromARGB(233, 0, 0, 0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: Text(
              "View Volunteers",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('volunteers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No volunteers found."));
          
          final volunteers = snapshot.data!.docs;
          return ListView.builder(
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              var volunteerData = volunteers[index].data() as Map<String, dynamic>;
              String name = volunteerData['name'] ?? "No Name";
              String email = volunteerData['email'] ?? "No Email";
              String phone = volunteerData['phone'] ?? "No Phone";
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email: $email"),
                    Text("Phone: $phone"),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}

/// Page to view all authorities from the 'authorities' collection.
class ViewAuthoritiesPage extends StatefulWidget {
  @override
  _ViewAuthoritiesPageState createState() => _ViewAuthoritiesPageState();
}

class _ViewAuthoritiesPageState extends State<ViewAuthoritiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with gradient background, rounded corners, and iOS back button.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Color.fromARGB(233, 0, 0, 0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: Text(
              "View Authorities",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('authorities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No authorities found."));
          
          final authorities = snapshot.data!.docs;
          return ListView.builder(
            itemCount: authorities.length,
            itemBuilder: (context, index) {
              var authorityData = authorities[index].data() as Map<String, dynamic>;
              String name = authorityData['name'] ?? "No Name";
              String email = authorityData['email'] ?? "No Email";
              String phone = authorityData['phone'] ?? "No Phone";
              String location = authorityData['location'] ?? "No Location";
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email: $email"),
                    Text("Phone: $phone"),
                    Text("Location: $location"),
                  ],
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}

/// New page to view food donations from the 'food_donations' collection.
/// This page displays each donation as a card with images (if available) and details.
class ViewFoodDonationsPage extends StatelessWidget {
  // Helper widget to build a donation card.
  Widget _buildDonationCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    String expiryDateStr = data['expiryDate'] ?? '';
    String expiryTimeStr = data['expiryTime'] ?? '';
    String pickupLocationStr = '';
    if (data['pickupLocation'] != null) {
      var loc = data['pickupLocation'];
      pickupLocationStr =
          '(${(loc['latitude'] as double).toStringAsFixed(4)}, ${(loc['longitude'] as double).toStringAsFixed(4)})';
    }
    List<dynamic> imageUrls = data['imageUrls'] ?? [];
    String orderStatus = data['orderStatus'] ?? 'Pending';

    // Change card background if order is completed.
    Color cardBackgroundColor = orderStatus.toLowerCase() == 'completed'
        ? Colors.green.shade50
        : Colors.white;

    return Card(
      color: cardBackgroundColor,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display images if available.
            imageUrls.isNotEmpty
                ? Container(
                    height: 100,
                    margin: EdgeInsets.only(bottom: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrls[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
            Text('Food Type: ${data['foodType'] ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('Food Name: ${data['foodName'] ?? ''}', style: TextStyle(fontSize: 15)),
            SizedBox(height: 4),
            Text('Description: ${data['description'] ?? ''}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Quantity: ${data['quantity'] ?? ''}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Expiry Date: $expiryDateStr', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Expiry Time: $expiryTimeStr', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Text('Pickup Location: $pickupLocationStr', style: TextStyle(fontSize: 14)),
            SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text('Contact: ${data['contact'] ?? ''}', style: TextStyle(fontSize: 14)),
                ),
                Expanded(
                  child: Text('Donator: ${data['donatorName'] ?? ''}', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text('Instructions: ${data['instructions'] ?? ''}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
            // You can add a status indicator similar to your donation form if needed.
            Text('Status: $orderStatus', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
            backgroundColor: Color.fromARGB(233, 0, 0, 0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: Text(
              'Food Donations',
              style: TextStyle(
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 240, 242, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('food_donations')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No food donations found.',
                  textAlign: TextAlign.center,
                ),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return _buildDonationCard(snapshot.data!.docs[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

/// Updated Admin Dashboard (Landing Page) with the SVG icon in the AppBar.
class AdminHome extends StatelessWidget {
  AdminHome({Key? key}) : super(key: key);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('role');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserSelectionPage()),
    );
  }

  void _navigateToViewUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewUsersPage()),
    );
  }

  void _navigateToViewVolunteers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewVolunteersPage()),
    );
  }

  void _navigateToViewAuthorities(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewAuthoritiesPage()),
    );
  }

  void _navigateToViewFeedbacks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewFeedbacksPage()),
    );
  }

  void _navigateToManageVolunteers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManageVolunteersPage()),
    );
  }

  void _navigateToManageAuthorities(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManageAuthoritiesPage()),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Sign Out"),
          content: Text("Are you sure you want to sign out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _signOut(context);
              },
              child: Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Color.fromARGB(255, 9, 60, 83),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AdminHome AppBar includes the SVG icon.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: Color.fromARGB(233, 0, 0, 0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142)
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
                    colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
                Transform.translate(
                  offset: Offset(-13, 0),
                  child: Text(
                    "Admin Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'proxima',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildOptionCard(
              context: context,
              title: "View Users",
              icon: Icons.people,
              onTap: () => _navigateToViewUsers(context),
            ),
            _buildOptionCard(
              context: context,
              title: "View Volunteers",
              icon: Icons.volunteer_activism,
              onTap: () => _navigateToViewVolunteers(context),
            ),
            _buildOptionCard(
              context: context,
              title: "View Authorities",
              icon: Icons.account_balance,
              onTap: () => _navigateToViewAuthorities(context),
            ),
            _buildOptionCard(
              context: context,
              title: "View Feedbacks",
              icon: Icons.feedback,
              onTap: () => _navigateToViewFeedbacks(context),
            ),
            _buildOptionCard(
              context: context,
              title: "Manage Volunteers",
              icon: Icons.volunteer_activism,
              onTap: () => _navigateToManageVolunteers(context),
              subtitle: "Approval required",
            ),
            _buildOptionCard(
              context: context,
              title: "Manage Authorities",
              icon: Icons.admin_panel_settings,
              onTap: () => _navigateToManageAuthorities(context),
            ),
            // New Admin Analytics card with popup option.
            _buildOptionCard(
              context: context,
              title: "Admin Analytics",
              icon: Icons.analytics,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AdminAnalyticsPopup(),
                );
              },
            ),
            // New card: View Food Donations.
            _buildOptionCard(
              context: context,
              title: "View Food Donations",
              icon: Icons.food_bank,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewFoodDonationsPage()),
                );
              },
            ),
            _buildOptionCard(
              context: context,
              title: "Sign Out",
              icon: Icons.logout,
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Popup screen for Admin Analytics – similar to the Report Analytics popup.
class AdminAnalyticsPopup extends StatelessWidget {
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
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Admin Analytics Options",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'proxima'),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOption(
                context,
                label: "Overview",
                icon: Icons.pie_chart,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => OverviewAnalyticsPage()));
                },
              ),
              _buildOption(
                context,
                label: "Trend",
                icon: Icons.show_chart,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TrendAnalyticsPage()));
                },
              ),
              _buildOption(
                context,
                label: "Detailed",
                icon: Icons.details,
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedAnalyticsPage()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required String label, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 35, color: Color.fromARGB(255, 9, 60, 83)),
          ),
          SizedBox(height: 10),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'proxima')),
        ],
      ),
    );
  }
}

/// Placeholder page for Overview Analytics.
class OverviewAnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Overview Analytics", style: TextStyle(fontFamily: 'proxima')),
      ),
      body: Center(child: Text("Overview Analytics Page", style: TextStyle(fontFamily: 'proxima'))),
    );
  }
}

/// Placeholder page for Trend Analytics.
class TrendAnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trend Analytics", style: TextStyle(fontFamily: 'proxima')),
      ),
      body: Center(child: Text("Trend Analytics Page", style: TextStyle(fontFamily: 'proxima'))),
    );
  }
}

/// Placeholder page for Detailed Analytics.
class DetailedAnalyticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detailed Analytics", style: TextStyle(fontFamily: 'proxima')),
      ),
      body: Center(child: Text("Detailed Analytics Page", style: TextStyle(fontFamily: 'proxima'))),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminHome(),
  ));
}
