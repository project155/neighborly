import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:neighborly/clodinary_upload.dart';
import 'package:neighborly/incidentlocation.dart';
import 'package:neighborly/notification.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateReportPage extends StatefulWidget {
  final XFile? attachment; // Optional image attachment

  const CreateReportPage({Key? key, this.attachment}) : super(key: key);

  @override
  _CreateReportPageState createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _urgencyLevel;
  DateTime? _dateTime;
  TimeOfDay? _timeOfDay;
  // Holds the fetched current location (as a Position)
  Position? _currentLocation;
  // Holds the location selected from the map (as a LatLng)
  LatLng? _selectedLatLng;
  List<XFile> _images = [];

  // New variable to track submission status.
  bool _isSubmitting = false;

  final List<String> _categories = [
    'flood',
    'Landslide',
    'Drought',
    'Fire',
    'Sexual Abuse',
    'Narcotics',
    'Road Incidents',
    'Eco Hazard',
    'Alcohol',
    'Animal Abuse',
    'Bribery',
    'Food Safety',
    'Hygiene Issues',
    'Infrastructure Issues',
    'Transportation',
    'Theft',
    'Child Abuse'
  ];

  final List<String> _urgencyLevels = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // If an attachment is provided, add it to the images list.
    if (widget.attachment != null) {
      _images.add(widget.attachment!);
    }
  }

  // Helper function to map each category to an icon.
  Icon _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'flood':
        return Icon(Icons.opacity, color: Colors.blue);
      case 'landslide':
        return Icon(Icons.terrain, color: Colors.brown);
      case 'drought':
        return Icon(Icons.wb_sunny, color: Colors.orange);
      case 'fire':
        return Icon(Icons.local_fire_department, color: Colors.red);
      case 'sexual abuse':
        return Icon(Icons.report, color: Colors.pink);
      case 'narcotics':
        return Icon(Icons.medication, color: Colors.green);
      case 'road incidents':
        return Icon(Icons.traffic, color: Colors.deepPurple);
      case 'eco hazard':
        return Icon(Icons.eco, color: Colors.green);
      case 'alcohol':
        return Icon(Icons.local_bar, color: Colors.brown);
      case 'animal abuse':
        return Icon(Icons.pets, color: Colors.orange);
      case 'bribery':
        return Icon(Icons.money, color: Colors.green);
      case 'food safety':
        return Icon(Icons.restaurant, color: Colors.orange);
      case 'hygiene issues':
        return Icon(Icons.clean_hands, color: Colors.blue);
      case 'infrastructure issues':
        return Icon(Icons.build, color: Colors.grey);
      case 'transportation':
        return Icon(Icons.directions_car, color: Colors.teal);
      case 'theft':
        return Icon(Icons.security_rounded, color: Colors.black);
        case 'Child Abuse':
        return Icon(Icons.security_rounded, color: Colors.black);
      default:
        return Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = position;
      // If no location has been selected yet, use the current location.
      _selectedLatLng ??= LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    // Allow selecting multiple images.
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles;
      });
    }
  }

  Future<List<String>> getAllPlayerIds() async {
    try {
      // Fetch player IDs from 'users' collection.
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Fetch player IDs from 'volunteers' collection.
      QuerySnapshot volunteersSnapshot =
          await FirebaseFirestore.instance.collection('volunteers').get();

      // Fetch player IDs from 'authorities' collection.
      QuerySnapshot authoritiesSnapshot =
          await FirebaseFirestore.instance.collection('authorities').get();

      print('Total users: ${usersSnapshot.docs.length}');
      print('Total volunteers: ${volunteersSnapshot.docs.length}');
      print('Total authorities: ${authoritiesSnapshot.docs.length}');

      // Function to extract and filter player IDs.
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

      // Extract player IDs from each collection.
      List<String> userPlayerIds = extractPlayerIds(usersSnapshot);
      List<String> volunteerPlayerIds = extractPlayerIds(volunteersSnapshot);
      List<String> authorityPlayerIds = extractPlayerIds(authoritiesSnapshot);

      // Combine all lists and remove duplicates.
      Set<String> playerIds = {
        ...userPlayerIds,
        ...volunteerPlayerIds,
        ...authorityPlayerIds
      };

      print('Filtered Player IDs: $playerIds');

      return playerIds.toList();
    } catch (e) {
      print('Error fetching player IDs: $e');
      return [];
    }
  }

  Future<void> _submitReport() async {
    // Start submission: disable the button.
    setState(() {
      _isSubmitting = true;
    });
    List<String> pidlist = await getAllPlayerIds();
    print(pidlist);

    if (_formKey.currentState!.validate()) {
      // Upload each image and collect the returned URLs.
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        for (XFile image in _images) {
          // getClodinaryUrl is assumed to return a String? (nullable).
          String? url = await getClodinaryUrl(image.path);
          if (url != null) {
            imageUrls.add(url);
          }
        }
      }

      await FirebaseFirestore.instance.collection('reports').add({
        'category': _selectedCategory,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _dateTime?.toIso8601String(),
        'time': _timeOfDay != null ? _timeOfDay!.format(context) : null,
        // Use the selected location if available, otherwise use the current location.
        'location': _selectedLatLng != null
            ? {
                'latitude': _selectedLatLng!.latitude,
                'longitude': _selectedLatLng!.longitude,
              }
            : null,
        'urgency': _urgencyLevel,
        // Store the list of image URLs; if none, it will be an empty list.
        'imageUrl': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
        // Updated: storing the UID under 'userId'
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });

      // Send a notification with:
      // Notification title: "<type of report> reported"
      // Notification description: "<report title>"
      sendNotificationToSpecificUsers(
          pidlist,
          _titleController.text,
          '${_selectedCategory ?? "Report"} reported');

      // Show success message.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted successfully!')),
      );

      // End submission: re-enable the button.
      setState(() {
        _isSubmitting = false;
      });
      // Return to the previous page.
      Navigator.of(context).pop();
    } else {
      // If form is not valid, re-enable the button.
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build location text from _selectedLatLng.
    String locationText = _selectedLatLng != null
        ? 'Selected Location: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
        : 'No location selected';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Category Dropdown with icons and a max height for the dropdown menu.
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  hintText: 'Select Category',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                menuMaxHeight: 500.0,
                items: _categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Row(
                          children: [
                            _getIconForCategory(category),
                            SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _urgencyLevel,
                decoration: InputDecoration(
                  hintText: 'Select Urgency Level',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _urgencyLevels
                    .map(
                      (level) => DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _urgencyLevel = value),
                validator: (value) =>
                    value == null ? 'Please select urgency level' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter Title',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter Description',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please provide a description'
                    : null,
              ),
              SizedBox(height: 12),
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading:
                    Icon(Icons.lock_clock_rounded, color: Colors.blueAccent),
                title: Text(_dateTime == null
                    ? 'Select Date'
                    : '${_dateTime!.toLocal()}'.split(' ')[0]),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) setState(() => _dateTime = picked);
                },
              ),
              SizedBox(height: 12),
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(Icons.access_time, color: Colors.blueAccent),
                title: Text(_timeOfDay == null
                    ? 'Select Time'
                    : _timeOfDay!.format(context)),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _timeOfDay = picked);
                },
              ),
              SizedBox(height: 12),
              ListTile(
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                leading: Icon(Icons.location_on, color: Colors.blueAccent),
                title: Text(
                  _currentLocation == null
                      ? 'Fetch Current Location'
                      : 'Current Location: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
                ),
                onTap: _getCurrentLocation,
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickLocationPage(),
                    ),
                  );
                  if (result != null && result is LatLng) {
                    setState(() {
                      _selectedLatLng = result;
                    });
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_history,
                          color: Colors.blueAccent, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedLatLng != null
                              ? 'Incident Location: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
                              : "Incident Location",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _selectedLatLng != null
                                ? Colors.black
                                : Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey, size: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 20),
                    SizedBox(width: 8),
                    Text('Attach Images'),
                  ],
                ),
              ),
              SizedBox(height: 12),
              if (_images.isNotEmpty)
                Container(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_images[index].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
