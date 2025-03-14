import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'peopledetails.dart';
import 'add_person_page.dart';

class CampDetailPage extends StatefulWidget {
  final String campId;
  CampDetailPage({required this.campId});

  @override
  _CampDetailPageState createState() => _CampDetailPageState();
}

class _CampDetailPageState extends State<CampDetailPage> {
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
      print("Loaded role in CampDetailPage: $localRole");
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference camps = FirebaseFirestore.instance.collection('camps');

    return Scaffold(
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
              'Camp Detail',
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
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddPersonPage(campId: widget.campId),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: camps.doc(widget.campId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var campData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Image carousel with rounded borders and reduced width
                SizedBox(
                  height: 200,
                  child: PageView(
                    controller: PageController(viewportFraction: 0.85),
                    children: (campData['imageUrls'] as List)
                        .map<Widget>(
                          (url) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campData['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'proxima',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Address: ${campData['address']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'proxima',
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Embedded Google Map
                      Container(
                        height: 200,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              campData['latitude'],
                              campData['longitude'],
                            ),
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId(widget.campId),
                              position: LatLng(
                                campData['latitude'],
                                campData['longitude'],
                              ),
                              infoWindow:
                                  InfoWindow(title: campData['name']),
                            ),
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "People Count: ${campData['peopleCount']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'proxima',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Button to view people details on a separate page
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PeopleDetailPage(campId: widget.campId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people, color: Colors.white),
                        label: const Text(
                          "View People in Camp",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'proxima',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 9, 60, 83),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
