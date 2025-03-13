// feed_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'camp_detail_page.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String? localRole;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      localRole = prefs.getString('role');
      print("Loaded role in FeedPage: $localRole");
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference camps = FirebaseFirestore.instance.collection('camps');

    return Scaffold(
      appBar: AppBar(
        title: Text('Relief Camps Dashboard'),
        actions: [
          // Only display the add button if the role is volunteer or authority.
          if (localRole != null &&
              (localRole!.toLowerCase() == 'volunteer' ||
                  localRole!.toLowerCase() == 'authority'))
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                print("Plus button pressed");
                Navigator.pushNamed(context, '/addCamp');
              },
            )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: camps.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final campDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: campDocs.length,
            itemBuilder: (context, index) {
              var camp = campDocs[index];
              // Extract fields from the document
              String name = camp['name'] ?? '';
              String address = camp['address'] ?? '';
              int capacity = camp['capacity'] ?? 0;
              String contactNumber = camp['contactNumber'] ?? '';
              String description = camp['description'] ?? '';
              int peopleCount = camp['peopleCount'] ?? 0;
              List<dynamic> imageUrls = camp['imageUrls'] ?? [];

              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: imageUrls.isNotEmpty
                      ? Image.network(
                          imageUrls[0],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          'https://via.placeholder.com/150',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                  title: Text(name),
                  subtitle: Text(
                    "Address: $address\n"
                    "Capacity: $capacity\n"
                    "Contact: $contactNumber\n"
                    "Description: $description\n"
                    "People Count: $peopleCount",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampDetailPage(campId: camp.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
