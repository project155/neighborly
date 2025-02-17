import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';

class FloodPage extends StatefulWidget {
  @override
  _FloodPageState createState() => _FloodPageState();
}

class _FloodPageState extends State<FloodPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flood Reports"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('reports')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error fetching reports"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No reports available"));
          }

          var reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              var report = reports[index];
              var data = report.data() as Map<String, dynamic>? ?? {};

              // If the 'imageUrl' is stored as a string in Firestore
              String imageUrl = data['imageUrl'] ?? "";
              String title = data['title'] ?? "No Title";
              String description = data['description'] ?? "No Description";
              String category = data['category'] ?? "Unknown";
              String urgency = data['urgency'] ?? "Normal";
              var location = data['location'] ?? {};
              String? latitude = location['latitude']?.toString();
              String? longitude = location['longitude']?.toString();
              int likes = data['likes'] ?? 0;
              List comments = data['comments'] ?? [];
              String reportId = report.id;

              String userId = _auth.currentUser?.uid ?? "";
              List likedBy = List<String>.from(data['likedBy'] ?? []);
              bool isLiked = likedBy.contains(userId);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the image directly if imageUrl is not empty
                    if (imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250,
                        ),
                      ),

                    // Report Details
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text(description,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700])),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Category: $category",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("Urgency: $urgency",
                                  style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                          if (latitude != null && longitude != null)
                            Text("Location: $latitude, $longitude",
                                style: TextStyle(color: Colors.blueGrey)),
                          SizedBox(height: 10),

                          // Like, Comment, Share Buttons
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _handleLike(reportId, isLiked),
                              ),
                              Text("$likes Likes",
                                  style: TextStyle(color: Colors.blue)),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.comment_outlined,
                                    color: Colors.green),
                                onPressed: () =>
                                    _showComments(context, reportId, comments),
                              ),
                              IconButton(
                                icon: Icon(Icons.share_outlined,
                                    color: Colors.orange),
                                onPressed: () =>
                                    _shareReport(title, description),
                              ),
                            ],
                          )
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

  // Handle Like Button (One per User)
  void _handleLike(String docId, bool isLiked) {
    String userId = _auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    if (isLiked) {
      _firestore.collection('reports').doc(docId).update({
        'likes': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    } else {
      _firestore.collection('reports').doc(docId).update({
        'likes': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // Share Report
  void _shareReport(String title, String description) {
    Share.share('$title\n\n$description');
  }

  // Show Comments
  void _showComments(BuildContext context, String docId, List comments) {
    TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView(
                  children:
                      comments.map((comment) => ListTile(title: Text(comment))).toList(),
                ),
              ),
              TextField(
                controller: commentController,
                decoration: InputDecoration(hintText: "Add a comment..."),
                onSubmitted: (text) {
                  if (text.isNotEmpty) {
                    _firestore.collection('reports').doc(docId).update({
                      'comments': FieldValue.arrayUnion([text]),
                    });
                    commentController.clear();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
