import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAuthoritiesPage extends StatefulWidget {
  @override
  _ManageAuthoritiesPageState createState() => _ManageAuthoritiesPageState();
}

class _ManageAuthoritiesPageState extends State<ManageAuthoritiesPage> {
  final CollectionReference authoritiesCollection =
      FirebaseFirestore.instance.collection('authorities');

  // Function to update the isApproved field in Firestore
  Future<void> updateApprovalStatus(String docId, bool isApproved) async {
    try {
      await authoritiesCollection.doc(docId).update({
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
        title: Text("Manage Authorities"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: authoritiesCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No authority requests found."));
          }

          // Filter only pending authority requests.
          List<DocumentSnapshot> pendingAuthorities = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return data['isApproved'] != true;
          }).toList();

          if (pendingAuthorities.isEmpty) {
            return Center(child: Text("No pending authority requests."));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: pendingAuthorities.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = pendingAuthorities[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String name = data['name'] ?? 'No Name';
              String email = data['email'] ?? 'No Email';

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
                        children: [
                          // Display every key-value pair with a minimal layout
                          ...data.entries.map((entry) => Padding(
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
                                onPressed: () =>
                                    updateApprovalStatus(doc.id, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text("Accept"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    updateApprovalStatus(doc.id, false),
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
