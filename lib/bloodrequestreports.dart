import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodRequestListPage extends StatelessWidget {
  const BloodRequestListPage({Key? key}) : super(key: key);

  // Helper to update the status of a request.
  Future<void> _updateStatus(
      BuildContext context, DocumentSnapshot doc, String newStatus) async {
    try {
      await doc.reference.update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status updated to $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status")),
      );
    }
  }

  // Helper to delete a request with confirmation.
  Future<void> _deleteRequest(BuildContext context, DocumentSnapshot doc) async {
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Delete Request"),
            content: Text("Are you sure you want to delete this request?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text("Delete", style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await doc.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting request")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'proxima',
            ),
      ),
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          title: Text(
            'Blood Requests',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('blood_requests')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Something went wrong: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No blood requests available."));
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;
                // Default to "Pending" if no status is set.
                String status = data['status'] ?? 'Pending';
                bool isOwner = (data['userId'] == currentUserId);

                // Set an accent color based on the status.
                Color accentColor;
                switch (status) {
                  case 'Found Donor':
                    accentColor = Colors.green;
                    break;
                  case 'Cancelled':
                    accentColor = Colors.red;
                    break;
                  default:
                    accentColor = Color.fromARGB(255, 9, 60, 83);
                }

                return Card(
                  elevation: 3,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: accentColor,
                      width: 1,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      // Accent stripe on the left based on status.
                      border: Border(
                        left: BorderSide(
                          color: accentColor,
                          width: 5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: Patient Name and action menu (update status & delete) for owner.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Patient Name: ${data['patient_name'] ?? 'N/A'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isOwner)
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: Colors.black54),
                                onSelected: (value) {
                                  if (value == 'Delete') {
                                    _deleteRequest(context, doc);
                                  } else {
                                    _updateStatus(context, doc, value);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'Pending',
                                    child: Text("Pending"),
                                  ),
                                  PopupMenuItem(
                                    value: 'Found Donor',
                                    child: Text("Found Donor"),
                                  ),
                                  PopupMenuItem(
                                    value: 'Cancelled',
                                    child: Text("Cancelled"),
                                  ),
                                  PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 'Delete',
                                    child: Text(
                                      "Delete Request",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text("Hospital: ${data['hospital'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text("Hospital Name: ${data['hospital_name'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text("Bystander Name: ${data['bystander_name'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text("Bystander Contact: ${data['bystander_contact'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text("Blood Group: ${data['blood_group'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text("Blood Unit: ${data['blood_unit'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text("District: ${data['district'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text("Date and Time: ${data['date_time'] ?? 'N/A'}"),
                        SizedBox(height: 6),
                        Text(
                          "Status: $status",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
