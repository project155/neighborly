import 'package:flutter/material.dart';

// Dummy pages – replace these with your actual pages.
class ViewUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Users"),
        backgroundColor: Colors.teal,
      ),
      body: Center(child: Text("List of users will be displayed here.")),
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
      body: Center(
          child: Text(
              "Volunteer management and approval process will be shown here.\n\nNote: Volunteers must be approved by an admin before they can log in.")),
    );
  }
}

class ManageAuthoritiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Authorities"),
        backgroundColor: Colors.teal,
      ),
      body: Center(child: Text("Authority management will be displayed here.")),
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
      // Standard AppBar with a centered title.
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
            // Add more cards here if needed.
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
