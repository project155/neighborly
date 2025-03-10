import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  NotificationPage({Key? key}) : super(key: key);

  // Formats the time difference between now and the notification's timestamp.
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hrs ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the timestamp for 7 days ago.
    final sevenDaysAgo = Timestamp.fromDate(
      DateTime.now().subtract(Duration(days: 7)),
    );

    return DefaultTextStyle(
      style: TextStyle(fontFamily: 'proxima'),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: AppBar(
              title: Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'proxima',
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('timestamp', isGreaterThan: sevenDaysAgo)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No notifications available."));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var data = doc.data() as Map<String, dynamic>;

                String title = data['title'] ?? 'No Title';
                String message = data['description'] ?? 'No Message';
                String sender = data['sender'] ?? 'Authority';
                Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
                DateTime dateTime = timestamp.toDate();

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: Icon(
                      sender == "Volunteer"
                          ? Icons.volunteer_activism
                          : Icons.account_balance,
                      color: sender == "Volunteer" ? Colors.green : Colors.blue,
                      size: 30,
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'proxima',
                      ),
                    ),
                    subtitle: Text(
                      message,
                      style: TextStyle(fontFamily: 'proxima'),
                    ),
                    trailing: Text(
                      _formatDateTime(dateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'proxima'),
                    ),
                    onTap: () {
                      // Optional: Navigate to a detailed notification view.
                    },
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
