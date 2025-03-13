import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'add_person_page.dart';

class CampDetailPage extends StatelessWidget {
  final String campId;
  CampDetailPage({required this.campId});

  @override
  Widget build(BuildContext context) {
    CollectionReference camps =
        FirebaseFirestore.instance.collection('camps');
    return Scaffold(
      appBar: AppBar(
        title: Text('Camp Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPersonPage(campId: campId),
                ),
              );
            },
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: camps.doc(campId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          var campData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Image carousel
                Container(
                  height: 200,
                  child: PageView(
                    children: (campData['imageUrls'] as List)
                        .map<Widget>(
                            (url) => Image.network(url, fit: BoxFit.cover))
                        .toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campData['description'],
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      Text("Address: ${campData['address']}",
                          style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
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
                              markerId: MarkerId(campId),
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
                      SizedBox(height: 10),
                      Text("People Count: ${campData['peopleCount']}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("People in Camp:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      StreamBuilder<QuerySnapshot>(
                        stream: camps
                            .doc(campId)
                            .collection('people')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Text("Error: ${snapshot.error}");
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return CircularProgressIndicator();
                          final peopleDocs = snapshot.data!.docs;
                          return Column(
                            children: peopleDocs.map((person) {
                              var personData =
                                  person.data() as Map<String, dynamic>;
                              return ListTile(
                                title: Text(personData['name']),
                                subtitle: Text(
                                    "Age: ${personData['age']} | ${personData['additionalInfo']}"),
                              );
                            }).toList(),
                          );
                        },
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
