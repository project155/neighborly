import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageVolunteersPage extends StatefulWidget {
  @override
  _ManageVolunteersPageState createState() => _ManageVolunteersPageState();
}

class _ManageVolunteersPageState extends State<ManageVolunteersPage> {
  final CollectionReference volunteersCollection =
      FirebaseFirestore.instance.collection('volunteers');

  // Function to update the isApproved field in Firestore
  Future<void> updateApprovalStatus(String docId, bool isApproved) async {
    try {
      await volunteersCollection.doc(docId).update({
        'isApproved': isApproved,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Volunteers"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: volunteersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No volunteer requests found."));
          }

          // Filter pending volunteer requests (isApproved not true)
          List<DocumentSnapshot> pendingVolunteers = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data['isApproved'] != true;
          }).toList();

          if (pendingVolunteers.isEmpty) {
            return Center(child: Text("No pending volunteer requests."));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: pendingVolunteers.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = pendingVolunteers[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String name = data['name'] ?? 'No Name';
              String email = data['email'] ?? 'No Email';
              // Fetch the id card image URL from Firestore
              String? idCardImageUrl = data['idCardImage'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(email),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Display the ID card image if available
                          if (idCardImageUrl != null && idCardImageUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "ID Card:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      idCardImageUrl,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Display every key-value pair (excluding the idCardImage to avoid redundancy)
                          ...data.entries
                              .where((entry) => entry.key != 'idCardImage')
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "${entry.key}:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            "${entry.value}",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => updateApprovalStatus(doc.id, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Accept"),
                              ),
                              ElevatedButton(
                                onPressed: () => updateApprovalStatus(doc.id, false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Reject"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
