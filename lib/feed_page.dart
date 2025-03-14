import 'package:flutter/cupertino.dart';
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 115, 168),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: const Text(
              'Relief Camps Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (localRole != null &&
                  (localRole!.toLowerCase() == 'volunteer' ||
                      localRole!.toLowerCase() == 'authority'))
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addCamp');
                  },
                )
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: camps.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final campDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: campDocs.length,
            itemBuilder: (context, index) {
              var camp = campDocs[index];
              String name = camp['name'] ?? '';
              String address = camp['address'] ?? '';
              int capacity = camp['capacity'] ?? 0;
              String contactNumber = camp['contactNumber'] ?? '';
              String description = camp['description'] ?? '';
              int peopleCount = camp['peopleCount'] ?? 0;
              List<dynamic> imageUrls = camp['imageUrls'] ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.3),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrls.isNotEmpty
                          ? imageUrls[0]
                          : 'https://via.placeholder.com/150',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'proxima',
                    ),
                  ),
                  subtitle: Text(
                    "Address: $address\n"
                    "Capacity: $capacity\n"
                    "Contact: $contactNumber\n"
                    "People Count: $peopleCount",
                    style: const TextStyle(fontFamily: 'proxima'),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color.fromARGB(255, 9, 60, 83),
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
