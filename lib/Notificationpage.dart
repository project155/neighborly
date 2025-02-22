import 'package:flutter/material.dart';
import 'package:neighborly/Notificationpage.dart';

// A simple model for a notification.
class NotificationItem {
  final String title;
  final String message;
  final String sender; // "Volunteer" or "Authority"
  final DateTime dateTime;

  NotificationItem({
    required this.title,
    required this.message,
    required this.sender,
    required this.dateTime,
  });
}

class NotificationPage extends StatelessWidget {
  // Sample list of notifications.
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: "Volunteer Message",
      message: "A volunteer has updated you regarding your report. Please check the details.",
      sender: "Volunteer",
      dateTime: DateTime.now().subtract(Duration(minutes: 5)),
    ),
    NotificationItem(
      title: "Authority Update",
      message: "Authorities have updated the status of your report.",
      sender: "Authority",
      dateTime: DateTime.now().subtract(Duration(hours: 1)),
    ),
    NotificationItem(
      title: "Volunteer Reminder",
      message: "Don't forget to follow up on your recent report.",
      sender: "Volunteer",
      dateTime: DateTime.now().subtract(Duration(hours: 2)),
    ),
    NotificationItem(
      title: "Authority Notice",
      message: "Local authority has posted a new alert in your area.",
      sender: "Authority",
      dateTime: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: const Color.fromARGB(255, 95, 156, 255),
      ),
      body: notifications.isEmpty
          ? Center(child: Text("No notifications available."))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: Icon(
                      notification.sender == "Volunteer"
                          ? Icons.volunteer_activism
                          : Icons.account_balance,
                      color: notification.sender == "Volunteer" ? Colors.green : Colors.blue,
                      size: 30,
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(notification.message),
                    trailing: Text(
                      _formatDateTime(notification.dateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      // You can add navigation to a detailed notification page if needed.
                    },
                  ),
                );
              },
            ),
    );
  }
}
