import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neighborly/notification.dart'; // Assumes your sendNotificationToSpecificUsers function is defined here.

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Demo',
      home: SendNotificationPage(),
    );
  }
}

class SendNotificationPage extends StatefulWidget {
  @override
  _SendNotificationPageState createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<List<String>> getAllPlayerIds() async {
    try {
      // Fetch player IDs from 'users' collection
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Fetch player IDs from 'volunteers' collection
      QuerySnapshot volunteersSnapshot =
          await FirebaseFirestore.instance.collection('volunteers').get();

      List<String> extractPlayerIds(QuerySnapshot snapshot) {
        return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where((data) =>
                data.containsKey('playerid') &&
                data['playerid'] != null &&
                data['playerid'].toString().trim().isNotEmpty)
            .map((data) => data['playerid'] as String)
            .toList();
      }

      // Extract player IDs from both collections
      List<String> userPlayerIds = extractPlayerIds(usersSnapshot);
      List<String> volunteerPlayerIds = extractPlayerIds(volunteersSnapshot);

      // Combine lists and remove duplicates
      Set<String> playerIds = {
        ...userPlayerIds,
        ...volunteerPlayerIds,
      };

      print('Filtered Player IDs: $playerIds');
      return playerIds.toList();
    } catch (e) {
      print('Error fetching player IDs: $e');
      return [];
    }
  }

  void _sendNotification() async {
    if (_formKey.currentState!.validate()) {
      String title = _titleController.text;
      String description = _descriptionController.text;

      // Retrieve player IDs
      List<String> pidlist = await getAllPlayerIds();

      // Send the notification using your existing function
      sendNotificationToSpecificUsers(pidlist, description, title);

      // Save a copy of the notification in Firestore
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification Sent!')),
      );

      // Optionally clear the form fields
      _titleController.clear();
      _descriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title input field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 16.0),
              
              // Description input field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              SizedBox(height: 32.0),
              // Send Notification button
              ElevatedButton(
                onPressed: _sendNotification,
                child: Text('Send Notification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
