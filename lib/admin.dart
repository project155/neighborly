import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

// Entry point for the admin dashboard.
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Dummy data for volunteer requests.
  List<Volunteer> _volunteers = [
    Volunteer(id: 1, name: 'John Doe', email: 'john@example.com', approved: false),
    Volunteer(id: 2, name: 'Jane Smith', email: 'jane@example.com', approved: false),
    Volunteer(id: 3, name: 'Alex Johnson', email: 'alex@example.com', approved: false),
  ];

  // Update the approval status of a volunteer.
  void _acceptVolunteer(int volunteerId) {
    setState(() {
      _volunteers = _volunteers.map((volunteer) {
        if (volunteer.id == volunteerId) {
          return Volunteer(
            id: volunteer.id,
            name: volunteer.name,
            email: volunteer.email,
            approved: true,
          );
        }
        return volunteer;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            // Card for Overall Details/Reports.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OverallReportsPage()),
                );
              },
              child: Card(
                elevation: 4,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.bar_chart, size: 50, color: Colors.blue),
                      SizedBox(height: 10),
                      Text(
                        "Details",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Card for All Users.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllUsersPage()),
                );
              },
              child: Card(
                elevation: 4,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.people, size: 50, color: Colors.blue),
                      SizedBox(height: 10),
                      Text(
                        "All Users",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Card for All Volunteers.
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllVolunteersPage(
                      volunteers: _volunteers,
                      onAccept: _acceptVolunteer,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.volunteer_activism, size: 50, color: Colors.blue),
                      SizedBox(height: 10),
                      Text(
                        "All Volunteers",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for Volunteer.
class Volunteer {
  final int id;
  final String name;
  final String email;
  final bool approved;

  Volunteer({
    required this.id,
    required this.name,
    required this.email,
    required this.approved,
  });
}

// Overall Reports/Details page.
class OverallReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Overall Reports\n\nDisplay charts, stats, and metrics here.',
            style: const TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

// All Users page fetching details from Firestore.
class AllUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using StreamBuilder to fetch user details from Firestore.
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final userData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final userName = userData['name'] ?? 'No name';
              final userEmail = userData['email'] ?? 'No email';
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(userName),
                subtitle: Text(userEmail),
              );
            },
          );
        },
      ),
    );
  }
}

// Volunteers page listing volunteer requests with approval option.
class AllVolunteersPage extends StatelessWidget {
  final List<Volunteer> volunteers;
  final Function(int) onAccept;

  const AllVolunteersPage({
    Key? key,
    required this.volunteers,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Requests'),
      ),
      body: volunteers.isEmpty
          ? const Center(child: Text('No volunteer requests at the moment.'))
          : ListView.builder(
              itemCount: volunteers.length,
              itemBuilder: (context, index) {
                final volunteer = volunteers[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(volunteer.name),
                    subtitle: Text("Request from: ${volunteer.email}"),
                    trailing: volunteer.approved
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                            child: const Text('Accept'),
                            onPressed: () => onAccept(volunteer.id),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
