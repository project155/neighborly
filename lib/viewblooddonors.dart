import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodDonorsPage extends StatefulWidget {
  const BloodDonorsPage({Key? key}) : super(key: key);

  @override
  _BloodDonorsPageState createState() => _BloodDonorsPageState();
}

class _BloodDonorsPageState extends State<BloodDonorsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 242, 255),
      appBar: AppBar(
        title: Text(
          'Blood Donors',
          style: TextStyle(
            fontFamily: 'proxima',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('blood_donors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No donors available."));
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var donor = snapshot.data!.docs[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Donor name
                      Text(
                        donor['name'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'proxima',
                        ),
                      ),
                      SizedBox(height: 8),
                      // Blood group
                      Row(
                        children: [
                          Icon(Icons.bloodtype, color: Color.fromARGB(255, 9, 60, 83)),
                          SizedBox(width: 8),
                          Text(
                            "Blood Group: ${donor['blood_group'] ?? ''}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Contact
                      Row(
                        children: [
                          Icon(Icons.phone, color: Color.fromARGB(255, 9, 60, 83)),
                          SizedBox(width: 8),
                          Text(
                            "Contact: ${donor['contact'] ?? ''}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Last donation date
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Color.fromARGB(255, 9, 60, 83)),
                          SizedBox(width: 8),
                          Text(
                            "Last Donation: ${donor['last_donation'] ?? ''}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Preferred location
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Color.fromARGB(255, 9, 60, 83)),
                          SizedBox(width: 8),
                          Text(
                            "Location: ${donor['preferred_location'] ?? ''}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
