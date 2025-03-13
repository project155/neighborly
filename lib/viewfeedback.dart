import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Page to view all feedbacks from the 'feedbacks' collection.
class ViewFeedbacksPage extends StatefulWidget {
  @override
  _ViewFeedbacksPageState createState() => _ViewFeedbacksPageState();
}

class _ViewFeedbacksPageState extends State<ViewFeedbacksPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to build star rating widget.
  Widget _buildStarRating(int rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      stars.add(Icon(
        i <= rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 16,
      ));
    }
    return Row(children: stars);
  }

  /// Fetch user info from "users", "volunteers", or "authorities" using uid.
  Future<Map<String, dynamic>?> _fetchUserInfo(String uid) async {
    if (uid.isEmpty) {
      print("Feedback doc has an empty UID.");
      return null;
    }
    try {
      // Try the 'users' collection.
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        print("User found in 'users' for uid $uid: ${userDoc.data()}");
        return userDoc.data() as Map<String, dynamic>;
      }
      // Try the 'volunteers' collection.
      DocumentSnapshot volunteerDoc = await _firestore.collection('volunteers').doc(uid).get();
      if (volunteerDoc.exists) {
        print("User found in 'volunteers' for uid $uid: ${volunteerDoc.data()}");
        return volunteerDoc.data() as Map<String, dynamic>;
      }
      // Try the 'authorities' collection.
      DocumentSnapshot authorityDoc = await _firestore.collection('authorities').doc(uid).get();
      if (authorityDoc.exists) {
        print("User found in 'authorities' for uid $uid: ${authorityDoc.data()}");
        return authorityDoc.data() as Map<String, dynamic>;
      }
      print("No user document found for uid: $uid");
    } catch (e) {
      print("Error fetching user info for uid $uid: $e");
    }
    return null;
  }

  /// Build a widget to display user info based on uid.
  Widget _buildUserInfo(String uid) {
    if (uid.isEmpty) {
      return Text(
        "Posted by: Unknown (empty UID)",
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserInfo(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "Loading user info...",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }
        if (snapshot.hasError) {
          return Text(
            "Error loading user info (uid: $uid)",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            "Posted by: Anonymous",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }
        var userData = snapshot.data!;
        String userName = userData['name'] ?? "Anonymous";
        String userEmail = userData['email'] ?? "No email provided";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Posted by: $userName",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              userEmail,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with gradient background, rounded corners, and iOS back button.
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: AppBar(
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: Color.fromARGB(233, 0, 0, 0),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 9, 60, 83),
                    Color.fromARGB(255, 0, 97, 142)
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            title: Text(
              "View Feedbacks",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'proxima',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('feedbacks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("No feedbacks found."));

          final feedbackDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              var data = feedbackDocs[index].data() as Map<String, dynamic>;
              String feedbackText = data['feedback'] ?? "No feedback provided";
              int rating = (data['rating'] as num).toInt();
              String uid = data['uid'] ?? "";
              print("Feedback document at index $index has uid: $uid");
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStarRating(rating),
                      SizedBox(height: 8),
                      Text(
                        feedbackText,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      _buildUserInfo(uid),
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
