import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neighborly/manageAuthorities.dart';
import 'package:neighborly/manageVolunteer.dart';

// Page to view all users from the 'users' collection.
class ViewUsersPage extends StatefulWidget {
  @override
  _ViewUsersPageState createState() => _ViewUsersPageState();
}

class _ViewUsersPageState extends State<ViewUsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Users"),
        backgroundColor: Colors.teal,
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
              //String location = userData['location'] ?? "No Location";
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

// Page to view all volunteers from the 'volunteers' collection.
class ViewVolunteersPage extends StatefulWidget {
  @override
  _ViewVolunteersPageState createState() => _ViewVolunteersPageState();
}

class _ViewVolunteersPageState extends State<ViewVolunteersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Volunteers"),
        backgroundColor: Colors.teal,
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
             // String location = volunteerData['location'] ?? "No Location";
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Email: $email"),
                    Text("Phone: $phone"),
                   // Text("Location: $location"),
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

// Page to view all authorities from the 'authorities' collection.
class ViewAuthoritiesPage extends StatefulWidget {
  @override
  _ViewAuthoritiesPageState createState() => _ViewAuthoritiesPageState();
}

class _ViewAuthoritiesPageState extends State<ViewAuthoritiesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Authorities"),
        backgroundColor: Colors.teal,
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

// Dummy management pages – replace these with your actual pages.
class ManageAuthoritiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Authorities"),
        backgroundColor: Colors.teal,
      ),
      body: Center(child: Text("Authorities management page.")),
    );
  }
}

class ManageVolunteersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Volunteers"),
        backgroundColor: Colors.teal,
      ),
      body: Center(child: Text("Volunteers management page.")),
    );
  }
}

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  // Navigation functions.
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

  // Build a card for a given option.
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
              Icon(icon, size: 40, color: Colors.blue),
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
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.teal,
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
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminHome(),
  ));
}
